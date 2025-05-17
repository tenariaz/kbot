# kbot
t.me/tenariaz_bot

## Огляд
kbot — це телеграм бот, написаний на Go, який можна збирати та запускати на різних платформах, включаючи Linux, macOS та Windows, на архітектурах amd64 та arm64. Проект використовує Makefile для автоматизації збірки та Dockerfile для контейнеризації.

## Вимоги
-   Go 1.17+
-   Docker
-   Git
-   Make

## Швидкий старт
### Клонування репозиторію
```bash
git clone https://github.com/tenariaz/kbot.git
cd kbot
```

### Збірка для вашої поточної платформи

```bash
make build
```

### Запуск програми

```bash
./kbot
```

## Крос-компіляція

### Збірка для різних платформ

```bash
# Для Linux AMD64
make linux

# Для Linux ARM64
make linux-arm

# Для macOS AMD64
make darwin

# Для macOS ARM64
make darwin-arm

# Для Windows AMD64
make windows
```

## Docker

### Побудова Docker образу

```bash
# Для поточної платформи
make image
# Для Linux
make image TARGETOS=linux TARGETARCH=amd64
# Для Linux arm64
make image TARGETOS=linux TARGETARCH=arm64
# Для macOS arm64
make image TARGETOS=darwin TARGETARCH=arm64
# Для Windows
make image TARGETOS=windows TARGETARCH=amd64

```

### Запуск тестів у Docker

```bash
docker build --target test .
```

### Публікація Docker образу

```bash
make push
```

### Запуск програми з Docker

```bash
docker run --rm ghcr.io/tenariaz/kbot:$(VERSION)-$(TARGETOS)-$(TARGETARCH)
```

## Тестування

```bash
make test
```

## Очищення

```bash
make clean
```

## Структура проекту

-   `cmd/` - Команди додатку
-   `pkg/` - Пакети бібліотек
-   `Makefile` - Автоматизація завдань
-   `Dockerfile` - Контейнеризація

## Особливості

-   Крос-компіляція для різних платформ (Linux, macOS, Windows)
-   Підтримка архітектур AMD64 та ARM64
-   Docker контейнери з підтримкою різних платформ без використання buildx
-   Автоматизація збірки та тестування
-   Інтеграція з GitHub Container Registry

## Ліцензія

MIT
