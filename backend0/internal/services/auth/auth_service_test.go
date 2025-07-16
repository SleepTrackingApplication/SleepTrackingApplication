package auth

import (
	"testing"
)

type mockAuthService struct{}

func (m *mockAuthService) Authenticate(username, password string) bool {
	return username == "admin" && password == "adminpass"
}

func TestAuthenticate(t *testing.T) {
	service := &mockAuthService{}
	if !service.Authenticate("admin", "adminpass") {
		t.Errorf("expected authentication to succeed")
	}
	if service.Authenticate("user", "wrongpass") {
		t.Errorf("expected authentication to fail")
	}
} 