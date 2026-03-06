package controller

import (
	"context"
	"fmt"
	"log"
	"time"

	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/dynamic/dynamicinformer"
	"k8s.io/client-go/informers"
	batchv1informers "k8s.io/client-go/informers/batch/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/util/workqueue"

	jrtypes "github.com/samsimpson/job-requests/internal/types"
)

type Controller struct {
	dynamicClient dynamic.Interface
	typedClient   kubernetes.Interface
	queue         workqueue.TypedRateLimitingInterface[string]
	typedFactory  informers.SharedInformerFactory
	jobInformer   batchv1informers.JobInformer
}

func New(dynamicClient dynamic.Interface, typedClient kubernetes.Interface) *Controller {
	typedFactory := informers.NewSharedInformerFactory(typedClient, 30*time.Second)
	return &Controller{
		dynamicClient: dynamicClient,
		typedClient:   typedClient,
		queue: workqueue.NewTypedRateLimitingQueue(
			workqueue.DefaultTypedControllerRateLimiter[string](),
		),
		typedFactory: typedFactory,
		jobInformer:  typedFactory.Batch().V1().Jobs(),
	}
}

func (c *Controller) Run(ctx context.Context) error {
	factory := dynamicinformer.NewDynamicSharedInformerFactory(c.dynamicClient, 30*time.Second)

	informer := factory.ForResource(jrtypes.JobRequestGVR).Informer()
	informer.AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc: func(obj interface{}) {
			c.enqueue(obj)
		},
		UpdateFunc: func(_, obj interface{}) {
			c.enqueue(obj)
		},
	})

	c.jobInformer.Informer().AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc: func(obj interface{}) {
			c.enqueueJobParent(obj)
		},
		UpdateFunc: func(_, obj interface{}) {
			c.enqueueJobParent(obj)
		},
	})

	factory.Start(ctx.Done())
	factory.WaitForCacheSync(ctx.Done())
	c.typedFactory.Start(ctx.Done())
	c.typedFactory.WaitForCacheSync(ctx.Done())

	log.Println("controller started, watching for JobRequests")

	for {
		select {
		case <-ctx.Done():
			c.queue.ShutDown()
			return nil
		default:
			c.processNextItem(ctx)
		}
	}
}

func (c *Controller) enqueue(obj interface{}) {
	u, ok := obj.(*unstructured.Unstructured)
	if !ok {
		return
	}
	key := u.GetNamespace() + "/" + u.GetName()
	c.queue.Add(key)
}

func (c *Controller) enqueueJobParent(obj interface{}) {
	job, ok := obj.(*batchv1.Job)
	if !ok {
		return
	}
	for _, ref := range job.GetOwnerReferences() {
		if ref.Kind == "JobRequest" && ref.Controller != nil && *ref.Controller {
			c.queue.Add(job.GetNamespace() + "/" + ref.Name)
			return
		}
	}
}

func (c *Controller) processNextItem(ctx context.Context) {
	key, shutdown := c.queue.Get()
	if shutdown {
		return
	}
	defer c.queue.Done(key)

	if err := c.reconcile(ctx, key); err != nil {
		log.Printf("error reconciling %s: %v", key, err)
		c.queue.AddRateLimited(key)
		return
	}
	c.queue.Forget(key)
}

func (c *Controller) reconcile(ctx context.Context, key string) error {
	namespace, name, err := cache.SplitMetaNamespaceKey(key)
	if err != nil {
		return err
	}

	jr, err := c.dynamicClient.Resource(jrtypes.JobRequestGVR).Namespace(namespace).Get(ctx, name, metav1.GetOptions{})
	if err != nil {
		return fmt.Errorf("failed to get JobRequest: %w", err)
	}

	status := jrtypes.GetStatusField(jr, "requestStatus")

	// Initialise status for new JobRequests. The mutating webhook stores the
	// creator's username in an annotation because the API server strips .status
	// from CREATE requests when the status subresource is enabled.
	if status == "" {
		annotations := jr.GetAnnotations()
		createdBy := ""
		if annotations != nil {
			createdBy = annotations["platform.gov.uk/created-by"]
		}
		if createdBy == "" {
			return fmt.Errorf("JobRequest %s has no created-by annotation", key)
		}
		jrtypes.SetStatusField(jr, "createdBy", createdBy)
		jrtypes.SetStatusField(jr, "requestStatus", jrtypes.StatusPending)
		if _, err := c.dynamicClient.Resource(jrtypes.JobRequestGVR).Namespace(namespace).UpdateStatus(ctx, jr, metav1.UpdateOptions{}); err != nil {
			return fmt.Errorf("failed to initialise JobRequest status: %w", err)
		}
		log.Printf("initialised status for JobRequest %s (createdBy: %s)", key, createdBy)
		return nil
	}

	if status == jrtypes.StatusInProgress {
		return c.reconcileInProgress(ctx, jr, namespace)
	}

	if status != jrtypes.StatusApproved {
		return nil
	}

	// Already has a job created
	if jrtypes.GetStatusField(jr, "jobName") != "" {
		return nil
	}

	image := jrtypes.GetSpecField(jr, "image")
	command := jrtypes.GetSpecField(jr, "command")

	if image == "" || command == "" {
		return fmt.Errorf("JobRequest %s missing image or command", key)
	}

	// Create the Job
	job := &batchv1.Job{
		ObjectMeta: metav1.ObjectMeta{
			GenerateName: fmt.Sprintf("jr-%s-", name),
			Namespace:    namespace,
			OwnerReferences: []metav1.OwnerReference{
				{
					APIVersion: fmt.Sprintf("%s/%s", jrtypes.JobRequestGVR.Group, jrtypes.JobRequestGVR.Version),
					Kind:       "JobRequest",
					Name:       jr.GetName(),
					UID:        jr.GetUID(),
					Controller: boolPtr(true),
				},
			},
		},
		Spec: batchv1.JobSpec{
			Template: corev1.PodTemplateSpec{
				Spec: corev1.PodSpec{
					RestartPolicy: corev1.RestartPolicyNever,
					Containers: []corev1.Container{
						{
							Name:    "job",
							Image:   image,
							Command: []string{"sh", "-c", command},
						},
					},
				},
			},
		},
	}

	createdJob, err := c.typedClient.BatchV1().Jobs(namespace).Create(ctx, job, metav1.CreateOptions{})
	if err != nil {
		// Update status to Failed
		jrtypes.SetStatusField(jr, "requestStatus", jrtypes.StatusFailed)
		if _, updateErr := c.dynamicClient.Resource(jrtypes.JobRequestGVR).Namespace(namespace).UpdateStatus(ctx, jr, metav1.UpdateOptions{}); updateErr != nil {
			log.Printf("failed to update status to Failed: %v", updateErr)
		}
		return fmt.Errorf("failed to create Job: %w", err)
	}

	log.Printf("created Job %s for JobRequest %s", createdJob.Name, key)

	// Update JobRequest status
	jrtypes.SetStatusField(jr, "jobName", createdJob.Name)
	jrtypes.SetStatusField(jr, "requestStatus", jrtypes.StatusInProgress)

	if _, err := c.dynamicClient.Resource(jrtypes.JobRequestGVR).Namespace(namespace).UpdateStatus(ctx, jr, metav1.UpdateOptions{}); err != nil {
		return fmt.Errorf("failed to update JobRequest status: %w", err)
	}

	return nil
}

func (c *Controller) reconcileInProgress(ctx context.Context, jr *unstructured.Unstructured, namespace string) error {
	jobName := jrtypes.GetStatusField(jr, "jobName")
	if jobName == "" {
		return nil
	}

	job, err := c.jobInformer.Lister().Jobs(namespace).Get(jobName)
	if err != nil {
		return fmt.Errorf("failed to get Job %s: %w", jobName, err)
	}

	newStatus := jobTerminalStatus(job)
	if newStatus == "" {
		return nil
	}

	jrtypes.SetStatusField(jr, "requestStatus", newStatus)
	if _, err := c.dynamicClient.Resource(jrtypes.JobRequestGVR).Namespace(namespace).UpdateStatus(ctx, jr, metav1.UpdateOptions{}); err != nil {
		return fmt.Errorf("failed to update JobRequest status to %s: %w", newStatus, err)
	}
	log.Printf("JobRequest %s/%s status updated to %s", namespace, jr.GetName(), newStatus)
	return nil
}

func jobTerminalStatus(job *batchv1.Job) string {
	for _, cond := range job.Status.Conditions {
		if cond.Status != corev1.ConditionTrue {
			continue
		}
		switch cond.Type {
		case batchv1.JobComplete:
			return jrtypes.StatusComplete
		case batchv1.JobFailed:
			return jrtypes.StatusFailed
		}
	}
	return ""
}

func boolPtr(b bool) *bool { return &b }

// Ensure the GVR is valid at compile time
var _ = schema.GroupVersionResource(jrtypes.JobRequestGVR)
