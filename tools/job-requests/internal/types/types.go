package types

import (
	"fmt"

	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

var JobRequestGVR = schema.GroupVersionResource{
	Group:    "platform.gov.uk",
	Version:  "v1alpha1",
	Resource: "jobrequests",
}

const (
	StatusPending    = "Pending"
	StatusApproved   = "Approved"
	StatusInProgress = "InProgress"
	StatusComplete   = "Complete"
	StatusFailed     = "Failed"
)

// GetStatusField reads a string field from .status.<field>.
func GetStatusField(obj *unstructured.Unstructured, field string) string {
	status, ok := obj.Object["status"].(map[string]interface{})
	if !ok {
		return ""
	}
	val, _ := status[field].(string)
	return val
}

// SetStatusField sets a string field on .status.<field>, creating .status if needed.
func SetStatusField(obj *unstructured.Unstructured, field, value string) {
	status, ok := obj.Object["status"].(map[string]interface{})
	if !ok {
		status = make(map[string]interface{})
		obj.Object["status"] = status
	}
	status[field] = value
}

// GetSpecField reads a string field from .spec.<field>.
func GetSpecField(obj *unstructured.Unstructured, field string) string {
	spec, ok := obj.Object["spec"].(map[string]interface{})
	if !ok {
		return ""
	}
	val, _ := spec[field].(string)
	return val
}

// NewJobRequest builds an unstructured JobRequest object.
func NewJobRequest(namespace, image, command string) *unstructured.Unstructured {
	return &unstructured.Unstructured{
		Object: map[string]interface{}{
			"apiVersion": fmt.Sprintf("%s/%s", JobRequestGVR.Group, JobRequestGVR.Version),
			"kind":       "JobRequest",
			"metadata": map[string]interface{}{
				"generateName": "jr-",
				"namespace":    namespace,
			},
			"spec": map[string]interface{}{
				"image":   image,
				"command": command,
			},
		},
	}
}
