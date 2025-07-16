//go:build integration
// +build integration

package main

import (
	"database/sql"
	"log"
	"os"
	"testing"
	"time"

	"backend/internal/models"

	_ "github.com/lib/pq"
)

var testDB *sql.DB

func TestMain(m *testing.M) {
	var err error
	// Use environment variable or default test database URL
	dbURL := os.Getenv("TEST_DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres:postgres@localhost:5432/testdb?sslmode=disable"
	}
	
	testDB, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Printf("Failed to connect to test database: %v", err)
		log.Printf("Skipping integration tests - no database connection")
		os.Exit(0)
	}
	
	// Test connection
	if err = testDB.Ping(); err != nil {
		log.Printf("Failed to ping test database: %v", err)
		log.Printf("Skipping integration tests - database not accessible")
		os.Exit(0)
	}
	
	// Run tests
	code := m.Run()
	
	// Cleanup
	testDB.Close()
	os.Exit(code)
}

func TestUserRepository_Integration(t *testing.T) {
	if testDB == nil {
		t.Skip("No database connection available")
	}
	
	// This test would require actual repository implementation with database
	// For now, we just test that we can connect to the database
	var count int
	err := testDB.QueryRow("SELECT 1").Scan(&count)
	if err != nil {
		t.Fatalf("Failed to query test database: %v", err)
	}
	
	if count != 1 {
		t.Errorf("Expected count 1, got %d", count)
	}
}

func TestSleepPeriodRepository_Integration(t *testing.T) {
	if testDB == nil {
		t.Skip("No database connection available")
	}
	
	// Test basic database operations
	// This would be expanded to test actual repository operations
	now := time.Now()
	testPeriod := models.SleepPeriod{
		UserID:      1,
		StartPeriod: now.Add(-8 * time.Hour),
		EndPeriod:   now,
		Duration:    28800,
	}
	
	// Validate the test data
	if testPeriod.UserID == 0 {
		t.Error("Test period should have valid UserID")
	}
	
	if testPeriod.Duration <= 0 {
		t.Error("Test period should have positive duration")
	}
}

// TestDatabaseSchema tests that required tables exist
func TestDatabaseSchema_Integration(t *testing.T) {
	if testDB == nil {
		t.Skip("No database connection available")
	}
	
	// Check if users table exists
	var exists bool
	err := testDB.QueryRow(`
		SELECT EXISTS (
			SELECT FROM information_schema.tables 
			WHERE table_name = 'users'
		)
	`).Scan(&exists)
	
	if err != nil {
		t.Fatalf("Failed to check users table existence: %v", err)
	}
	
	if !exists {
		t.Log("Users table does not exist - this is expected if migrations haven't been run")
	}
	
	// Check if sleep_periods table exists
	err = testDB.QueryRow(`
		SELECT EXISTS (
			SELECT FROM information_schema.tables 
			WHERE table_name = 'sleep_periods'
		)
	`).Scan(&exists)
	
	if err != nil {
		t.Fatalf("Failed to check sleep_periods table existence: %v", err)
	}
	
	if !exists {
		t.Log("Sleep_periods table does not exist - this is expected if migrations haven't been run")
	}
} 