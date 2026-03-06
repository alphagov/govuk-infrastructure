package webhooks

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"

	admissionv1 "k8s.io/api/admission/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"

	jrtypes "github.com/samsimpson/job-requests/internal/types"
)

func HandleValidate(w http.ResponseWriter, r *http.Request) {
	review, err := decodeAdmissionReview(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	resp := &admissionv1.AdmissionResponse{
		UID:     review.Request.UID,
		Allowed: true,
	}

	obj := &unstructured.Unstructured{}
	if err := json.Unmarshal(review.Request.Object.Raw, obj); err != nil {
		log.Printf("failed to unmarshal object: %v", err)
		resp.Allowed = false
		resp.Result = &metav1.Status{Message: "failed to parse object"}
		writeAdmissionResponse(w, review, resp)
		return
	}

	createdBy := jrtypes.GetStatusField(obj, "createdBy")
	approvedBy := jrtypes.GetStatusField(obj, "approvedBy")

	if createdBy != "" && approvedBy != "" && createdBy == approvedBy {
		if strings.EqualFold(os.Getenv("DISABLE_APPROVER_CHECK"), "true") {
			log.Printf("WARNING: approver %q is the same as creator %q, but DISABLE_APPROVER_CHECK is set — allowing", approvedBy, createdBy)
		} else {
			resp.Allowed = false
			resp.Result = &metav1.Status{
				Message: "approver must be different from creator",
				Reason:  metav1.StatusReasonForbidden,
				Code:    403,
			}
		}
	}

	writeAdmissionResponse(w, review, resp)
}
