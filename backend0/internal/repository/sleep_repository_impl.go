package repository

import (
	"backend/internal/models"

	"gorm.io/gorm"
)

type sleepPeriodRepository struct {
	db *gorm.DB
}

func NewSleepPeriodRepository(db *gorm.DB) SleepPeriodRepository {
	return &sleepPeriodRepository{db: db}
}

func (r *sleepPeriodRepository) Create(period *models.SleepPeriod) error {
	return r.db.Create(period).Error
}

func (r *sleepPeriodRepository) GetByUserID(userID uint64) ([]*models.SleepPeriod, error) {
	var periods []*models.SleepPeriod
	err := r.db.Where("user_id = ?", userID).Find(&periods).Error
	if err != nil {
		return nil, err
	}
	return periods, nil
}

func (r *sleepPeriodRepository) Update(period *models.SleepPeriod) error {
	return r.db.Save(period).Error
}

func (r *sleepPeriodRepository) Delete(id uint64) error {
	return r.db.Delete(&models.SleepPeriod{}, id).Error
}
