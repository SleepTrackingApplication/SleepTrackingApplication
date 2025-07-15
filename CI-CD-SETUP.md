# CI/CD Setup для Sleep Tracking Application

## 🚀 Что было настроено

Создан полноценный CI/CD pipeline в GitHub Actions со следующими этапами:

### 1. **Code Quality Check (Линтинг)**

- **golangci-lint** - проверка качества кода
- **gofmt** - проверка форматирования
- **go vet** - статический анализ

### 2. **Unit Tests**

- Запуск всех unit тестов
- Проверка race conditions (`-race`)
- Генерация coverage отчетов
- Загрузка в Codecov

### 3. **Integration Tests**

- Запуск с реальной PostgreSQL базой данных
- Проверка работы всех компонентов вместе
- Тестирование миграций

### 4. **Build Application**

- Кросс-компиляция для Linux, Windows, macOS
- Загрузка артефактов сборки

### 5. **Docker Build & Security**

- Сборка Docker образа
- Проверка уязвимостей с Trivy
- Тестирование контейнера

### 6. **Deploy (Staging)**

- Автоматический деплой на staging при push в main
- Настраивается под ваши нужды

## 📁 Созданные файлы

```
.github/
  workflows/
    ci.yml              # Основной CI/CD pipeline
backend/
  .golangci.yml         # Конфигурация линтера
  .gitignore           # Исключения для Git
```

## ⚙️ Настройка GitHub Repository

### 1. **Создайте Environment**

```bash
# В GitHub UI:
# Settings → Environments → New environment → "staging"
```

### 2. **Добавьте Secrets (опционально)**

```bash
# Settings → Secrets and variables → Actions
CODECOV_TOKEN=your-codecov-token
```

### 3. **Включите Actions**

```bash
# Settings → Actions → General
# Allow all actions and reusable workflows
```

## 🏃‍♂️ Как запустить

### Автоматический запуск:

- **Push в main/Go-Setup** → полный pipeline
- **Pull Request в main** → полный pipeline
- **Manual** → Actions tab → Run workflow

### Локальный запуск линтера:

```bash
cd backend

# Установка golangci-lint
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2

# Запуск
$(go env GOPATH)/bin/golangci-lint run
```

### Локальный запуск тестов:

```bash
cd backend

# Unit тесты
go test -v -race ./internal/models/... ./internal/services/... ./internal/handlers/... ./internal/repository/...

# Integration тесты (нужна база данных)
docker-compose up -d db
go test -v -tags=integration ./...
```

### Локальная сборка Docker:

```bash
cd backend
docker build -t sleep-tracker-backend .
docker run -p 8080:8080 -e JWT_KEY=test sleep-tracker-backend
```

## 📊 Мониторинг

### GitHub Actions UI:

- `Actions` tab → посмотреть статус pipeline
- Зеленый ✅ = все хорошо
- Красный ❌ = есть проблемы

### Artifacts:

- Скомпилированные бинарики доступны в Actions
- Coverage отчеты в Codecov (если настроен)

### Security:

- `Security` tab → Code scanning alerts
- Отчеты Trivy о уязвимостях Docker образа

## 🔧 Кастомизация

### Изменить версию Go:

```yaml
# .github/workflows/ci.yml
env:
  GO_VERSION: "1.23" # Измените здесь
```

### Добавить новые линтеры:

```yaml
# backend/.golangci.yml
linters:
  enable:
    - новый-линтер
```

### Изменить покрытие тестов:

```bash
# Добавить минимальное покрытие
go test -cover -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
```

### Настроить деплой:

```yaml
# .github/workflows/ci.yml, секция deploy
steps:
  - name: Deploy to your server
    run: |
      # Ваши команды деплоя
      ssh user@server "docker-compose pull && docker-compose up -d"
```

## 📈 Best Practices

### 1. **Работа с ветками:**

```bash
# Создайте feature ветку
git checkout -b feature/new-feature

# Сделайте изменения
git add .
git commit -m "feat: add new feature"

# Push и создайте PR
git push origin feature/new-feature
```

### 2. **Перед коммитом:**

```bash
# Проверьте локально
go fmt ./...
go vet ./...
go test ./...
golangci-lint run
```

### 3. **Commit messages:**

```bash
feat: добавить новую функциональность
fix: исправить баг
test: добавить тесты
docs: обновить документацию
refactor: рефакторинг кода
```

## 🐛 Troubleshooting

### Pipeline падает на линтинге:

```bash
# Исправьте форматирование
go fmt ./...

# Запустите линтер локально
golangci-lint run --fix
```

### Тесты не проходят:

```bash
# Проверьте логи в GitHub Actions
# Запустите тесты локально с verbose
go test -v ./...
```

### Docker build fails:

```bash
# Проверьте Dockerfile
# Запустите локально
docker build -t test .
```

### Проблемы с базой данных:

```bash
# Проверьте миграции
# Убедитесь что PostgreSQL 17 поддерживается
```

## 🎯 Следующие шаги

1. **Настройте Codecov** для отслеживания покрытия
2. **Добавьте end-to-end тесты** с настоящими HTTP запросами
3. **Настройте уведомления** в Slack/Discord
4. **Добавьте production деплой** с approval
5. **Настройте мониторинг** с Prometheus/Grafana

## 📞 Поддержка

Если что-то не работает:

1. Проверьте логи в GitHub Actions
2. Запустите команды локально
3. Проверьте версии Go и Docker
4. Убедитесь что все файлы на месте

**Готово! 🎉 Ваш CI/CD pipeline настроен и готов к работе!**
