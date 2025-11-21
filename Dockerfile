FROM ubuntu:latest AS builder

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa

# Установка Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"
RUN flutter doctor
RUN flutter channel stable
RUN flutter upgrade

# Добавление аргумента сборки
ARG MY_MEGA_API_URL
ENV MY_MEGA_API_URL=${MY_MEGA_API_URL}

# Копирование исходного кода приложения
WORKDIR /app
COPY . .

# Получение зависимостей приложения
RUN flutter pub get

# Очистка существующих сборок и сборка для веба
RUN flutter clean
RUN flutter build web --release --verbose --dart-define=MY_MEGA_API_URL=${MY_MEGA_API_URL}

# Этап 2 - Создание финального образа с nginx для обслуживания статических файлов
FROM nginx:alpine

# Копирование сборки из этапа сборки
COPY --from=builder /app/build/web /usr/share/nginx/html

# Копирование конфигурации nginx
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Обработка статических ресурсов с правильными типами MIME \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|json)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
        try_files $uri =404; \
    } \
    \
    # Обработка маршрутизации Flutter веб \
    location / { \
        try_files $uri $uri/ @fallback; \
    } \
    \
    location @fallback { \
        rewrite ^.*$ /index.html last; \
    } \
    \
    # Заголовки безопасности \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
}' > /etc/nginx/conf.d/default.conf

# Открытие порта
EXPOSE 80

# Запуск Nginx
CMD ["nginx", "-g", "daemon off;"]