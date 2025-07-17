package repository

import (
	"backend/internal/models"
	"testing"
)

type mockUserRepository struct{}

func (m *mockUserRepository) GetUserByID(id uint64) (*models.User, error) {
	return &models.User{ID: id, Username: "mockuser"}, nil
}

func TestGetUserByID(t *testing.T) {
	repo := &mockUserRepository{}
	user, err := repo.GetUserByID(1)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if user.ID != 1 {
		t.Errorf("expected user ID 1, got %d", user.ID)
	}
}
