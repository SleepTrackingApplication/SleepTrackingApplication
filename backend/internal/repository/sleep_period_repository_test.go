package repository

import (
	"backend/internal/models"
	"testing"
	"time"
)

type mockSleepPeriodRepository struct{}

func (m *mockSleepPeriodRepository) Create(period *models.SleepPeriod) error {
	// Mock implementation - always succeeds
	return nil
}

func (m *mockSleepPeriodRepository) GetByUserID(userID uint64) ([]*models.SleepPeriod, error) {
	// Mock implementation - returns a sample sleep period
	return []*models.SleepPeriod{
		{
			ID:          1,
			UserID:      userID,
			StartPeriod: time.Now().Add(-8 * time.Hour),
			EndPeriod:   time.Now(),
			Duration:    28800, // 8 hours
		},
	}, nil
}

func (m *mockSleepPeriodRepository) Update(period *models.SleepPeriod) error {
	return nil
}

func (m *mockSleepPeriodRepository) Delete(id uint64) error {
	return nil
}

func TestSleepPeriodRepository_Create(t *testing.T) {
	repo := &mockSleepPeriodRepository{}
	period := &models.SleepPeriod{
		UserID:      1,
		StartPeriod: time.Now().Add(-8 * time.Hour),
		EndPeriod:   time.Now(),
		Duration:    28800,
	}
	
	err := repo.Create(period)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
}

func TestSleepPeriodRepository_GetByUserID(t *testing.T) {
	repo := &mockSleepPeriodRepository{}
	userID := uint64(1)
	
	periods, err := repo.GetByUserID(userID)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	
	if len(periods) == 0 {
		t.Error("expected at least one sleep period")
	}
	
	if periods[0].UserID != userID {
		t.Errorf("expected user ID %d, got %d", userID, periods[0].UserID)
	}
} 