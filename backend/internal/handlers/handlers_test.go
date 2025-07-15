package handlers

import (
	"backend/internal/models"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHomeHandler_Integration(t *testing.T) {
	// Create mock services
	authService := &mockAuthService{}
	sleepRepo := &mockSleepRepo{}
	userRepo := &mockUserRepo{}

	handler := NewHandler(authService, sleepRepo, userRepo)

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	w := httptest.NewRecorder()

	handler.homeHandler(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", w.Code)
	}
	fmt.Println("Response:", w.Body.String())
}

func TestRegisterHandler_Integration(t *testing.T) {
	// Create mock services
	authService := &mockAuthService{}
	sleepRepo := &mockSleepRepo{}
	userRepo := &mockUserRepo{}

	handler := NewHandler(authService, sleepRepo, userRepo)

	// Create JSON payload
	payload := `{"username":"testuser","password":"testpass"}`
	req := httptest.NewRequest(http.MethodPost, "/auth/register", strings.NewReader(payload))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	handler.registerHandler(w, req)

	if w.Code != http.StatusCreated {
		t.Errorf("expected status 201, got %d", w.Code)
	}
	fmt.Println("Register Response:", w.Body.String())
}

// Mock implementations for testing
type mockAuthService struct{}

func (m *mockAuthService) Register(username, password string) (*models.User, error) {
	return &models.User{Username: username}, nil
}

func (m *mockAuthService) Login(username, password string) (string, error) {
	return "mock-jwt-token", nil
}

type mockSleepRepo struct{}

func (m *mockSleepRepo) Create(period *models.SleepPeriod) error {
	return nil
}

func (m *mockSleepRepo) GetByUserID(userID uint64) ([]*models.SleepPeriod, error) {
	return []*models.SleepPeriod{}, nil
}

func (m *mockSleepRepo) Update(period *models.SleepPeriod) error {
	return nil
}

func (m *mockSleepRepo) Delete(id uint64) error {
	return nil
}

type mockUserRepo struct{}

func (m *mockUserRepo) FindByID(id uint64) (*models.User, error) {
	return &models.User{ID: id}, nil
}

func (m *mockUserRepo) Create(user *models.User) error {
	return nil
}

func (m *mockUserRepo) FindByUsername(username string) (*models.User, error) {
	return &models.User{Username: username}, nil
}
