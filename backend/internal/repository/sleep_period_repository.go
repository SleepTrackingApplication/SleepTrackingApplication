package repository

import "backend/internal/models"

type SleepPeriodRepository interface {
	Create(period *models.SleepPeriod) error
	GetByUserID(userID uint64) ([]*models.SleepPeriod, error)
	Update(period *models.SleepPeriod) error
	Delete(id uint64) error
}
