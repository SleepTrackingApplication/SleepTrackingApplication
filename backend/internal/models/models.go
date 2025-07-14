package models

import "time"

type User struct {
	ID        uint64    `gorm:"primaryKey"`
	Username  string    `gorm:"unique;not null"`
	Password  string    `gorm:"not null"`
	Rating    int64     `gorm:"default:0"`
	Balance   int64     `gorm:"default:0"`
	CreatedAt time.Time `gorm:"default:CURRENT_TIMESTAMP"`
	UpdatedAt time.Time `gorm:"default:CURRENT_TIMESTAMP"`
}

type SleepPeriod struct {
	ID          uint64    `gorm:"primaryKey"`
	UserID      uint64    `gorm:"not null;index"`
	StartPeriod time.Time `gorm:"not null;column:start_period"`
	EndPeriod   time.Time `gorm:"column:end_period"`
	CreatedAt   time.Time `gorm:"default:CURRENT_TIMESTAMP"`
	Duration    int64     `gorm:"default:0"`
}
