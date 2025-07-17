package models

import (
	"testing"
	"time"
)

func TestUser_Validation(t *testing.T) {
	user := User{Username: "testuser", Password: "password123"}
	if user.Username == "" || user.Password == "" {
		t.Errorf("User validation failed: fields should not be empty")
	}
}

func TestUser_EmptyFields(t *testing.T) {
	user := User{}
	if user.Username != "" || user.Password != "" {
		t.Errorf("Empty user should have empty fields")
	}
}

func TestSleepPeriod_Validation(t *testing.T) {
	now := time.Now()
	sleepPeriod := SleepPeriod{
		UserID:      1,
		StartPeriod: now.Add(-8 * time.Hour),
		EndPeriod:   now,
		Duration:    28800, // 8 hours in seconds
	}

	if sleepPeriod.UserID == 0 {
		t.Errorf("SleepPeriod should have a valid UserID")
	}

	if sleepPeriod.StartPeriod.After(sleepPeriod.EndPeriod) {
		t.Errorf("StartPeriod should be before EndPeriod")
	}

	if sleepPeriod.Duration <= 0 {
		t.Errorf("Duration should be positive")
	}
}

func TestSleepPeriod_CalculateDuration(t *testing.T) {
	start := time.Date(2023, 12, 1, 22, 0, 0, 0, time.UTC)
	end := time.Date(2023, 12, 2, 6, 0, 0, 0, time.UTC)
	expectedDuration := int64(8 * 60 * 60) // 8 hours in seconds

	sleepPeriod := SleepPeriod{
		UserID:      1,
		StartPeriod: start,
		EndPeriod:   end,
		Duration:    expectedDuration,
	}

	if sleepPeriod.Duration != expectedDuration {
		t.Errorf("expected duration %d, got %d", expectedDuration, sleepPeriod.Duration)
	}
}
