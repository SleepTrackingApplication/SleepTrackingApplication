package models

import "time"

// User represents a user in the system
// @Description User account information
type User struct {
	ID        uint64    `gorm:"primaryKey" json:"id" example:"1"`
	Username  string    `gorm:"unique;not null" json:"username" example:"john_doe"`
	Password  string    `gorm:"not null" json:"-"`
	Rating    int64     `gorm:"default:0" json:"rating" example:"100"`
	Balance   int64     `gorm:"default:0" json:"balance" example:"50"`
	CreatedAt time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"updated_at"`
}

// SleepPeriod represents a sleep tracking session
// @Description Sleep period tracking information
type SleepPeriod struct {
	ID          uint64    `gorm:"primaryKey" json:"id" example:"1"`
	UserID      uint64    `gorm:"not null;index" json:"user_id" example:"1"`
	StartPeriod time.Time `gorm:"not null;column:start_period" json:"start_period" example:"2023-12-01T22:00:00Z"`
	EndPeriod   time.Time `gorm:"column:end_period" json:"end_period" example:"2023-12-02T06:00:00Z"`
	CreatedAt   time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
	Duration    int64     `gorm:"default:0" json:"duration" example:"28800"`
}
