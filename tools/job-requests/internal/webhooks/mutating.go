package webhooks

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	admissionv1 "k8s.io/api/admission/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"

	jrtypes "github.com/samsimpson/job-requests/internal/types"
)

func HandleMutate(w http.ResponseWriter, r *http.Request) {
	review, err := decodeAdmissionReview(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	resp := &admissionv1.AdmissionResponse{
		UID:     review.Request.UID,
		Allowed: true,
	}

	username := review.Request.UserInfo.Username

	switch review.Request.Operation {
	case admissionv1.Create:
		// With the status subresource enabled, the API server strips .status from
		// CREATE requests before persisting. So we store the creator's identity in
		// an annotation. The controller will copy it into .status.createdBy when
		// it initialises the status.
		patch := []jsonPatchOp{
			{Op: "add", Path: "/metadata/annotations", Value: map[string]string{
				"platform.gov.uk/created-by": username,
			}},
		}
		patchBytes, err := json.Marshal(patch)
		if err != nil {
			log.Printf("failed to marshal patch: %v", err)
			resp.Allowed = false
			resp.Result = &metav1.Status{Message: "internal error"}
			writeAdmissionResponse(w, review, resp)
			return
		}
		patchType := admissionv1.PatchTypeJSONPatch
		resp.Patch = patchBytes
		resp.PatchType = &patchType

	case admissionv1.Update:
		// On status UPDATE: if requestStatus is being set to Approved, set approvedBy
		obj := &unstructured.Unstructured{}
		if err := json.Unmarshal(review.Request.Object.Raw, obj); err != nil {
			log.Printf("failed to unmarshal object: %v", err)
			resp.Allowed = false
			resp.Result = &metav1.Status{Message: "failed to parse object"}
			writeAdmissionResponse(w, review, resp)
			return
		}

		newStatus := jrtypes.GetStatusField(obj, "requestStatus")
		if newStatus == jrtypes.StatusApproved {
			patch := []jsonPatchOp{
				{Op: "add", Path: "/status/approvedBy", Value: username},
			}
			patchBytes, err := json.Marshal(patch)
			if err != nil {
				log.Printf("failed to marshal patch: %v", err)
				resp.Allowed = false
				resp.Result = &metav1.Status{Message: "internal error"}
				writeAdmissionResponse(w, review, resp)
				return
			}
			patchType := admissionv1.PatchTypeJSONPatch
			resp.Patch = patchBytes
			resp.PatchType = &patchType
		}
	}

	writeAdmissionResponse(w, review, resp)
}

type jsonPatchOp struct {
	Op    string      `json:"op"`
	Path  string      `json:"path"`
	Value interface{} `json:"value,omitempty"`
}

func decodeAdmissionReview(r *http.Request) (*admissionv1.AdmissionReview, error) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read request body: %w", err)
	}
	defer r.Body.Close()

	review := &admissionv1.AdmissionReview{}
	if err := json.Unmarshal(body, review); err != nil {
		return nil, fmt.Errorf("failed to unmarshal admission review: %w", err)
	}
	if review.Request == nil {
		return nil, fmt.Errorf("admission review has no request")
	}
	return review, nil
}

func writeAdmissionResponse(w http.ResponseWriter, review *admissionv1.AdmissionReview, resp *admissionv1.AdmissionResponse) {
	review.Response = resp
	review.Request = nil

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(review); err != nil {
		log.Printf("failed to write response: %v", err)
	}
}
