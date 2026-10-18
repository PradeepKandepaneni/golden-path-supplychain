package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHandlers(t *testing.T) {
	cases := []struct {
		name, path, want string
		h                http.HandlerFunc
	}{
		{"root", "/", "golden path", rootHandler},
		{"health", "/healthz", "ok", healthHandler},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			rec := httptest.NewRecorder()
			tc.h(rec, httptest.NewRequest(http.MethodGet, tc.path, nil))
			if rec.Code != http.StatusOK {
				t.Fatalf("status=%d want 200", rec.Code)
			}
			if !strings.Contains(rec.Body.String(), tc.want) {
				t.Fatalf("body=%q want %q", rec.Body.String(), tc.want)
			}
		})
	}
}
