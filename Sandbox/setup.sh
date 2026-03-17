#!/bin/sh
set -e

MM_URL="http://mattermost:8065"
ADMIN_EMAIL="admin@test.local"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="Admin123456!"
ADMIN_FIRSTNAME="Admin"
ADMIN_LASTNAME="User"

TEAM_NAME="testteam"
TEAM_DISPLAY="Test Team"

TEST_EMAIL="testuser@test.local"
TEST_USERNAME="testuser"
TEST_PASSWORD="Test123456!"
TEST_FIRSTNAME="Test"
TEST_LASTNAME="User"

echo "Waiting for MatterMost..."
until curl -sf "$MM_URL/api/v4/system/ping" > /dev/null; do
  sleep 2
done
echo "MatterMost is up."

# Проверяем, уже ли настроен MM — пробуем залогиниться
echo "Checking if already configured..."
TOKEN=$(curl -s -i -X POST "$MM_URL/api/v4/users/login" \
  -H "Content-Type: application/json" \
  -d "{\"login_id\": \"$ADMIN_USERNAME\", \"password\": \"$ADMIN_PASSWORD\"}" \
  | grep -i "^token:" | tr -d '[:space:]' | cut -d':' -f2)

if [ -n "$TOKEN" ]; then
  echo "Already configured, skipping setup."
  echo "  Admin:    $ADMIN_USERNAME / $ADMIN_PASSWORD"
  echo "  TestUser: $TEST_USERNAME / $TEST_PASSWORD"
  echo "  URL:      http://localhost:8065"
  exit 0
fi

# Создаём admin (первый пользователь автоматически становится system admin)
echo "Creating admin user..."
curl -sf -X POST "$MM_URL/api/v4/users" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$ADMIN_EMAIL\",
    \"username\": \"$ADMIN_USERNAME\",
    \"password\": \"$ADMIN_PASSWORD\",
    \"first_name\": \"$ADMIN_FIRSTNAME\",
    \"last_name\": \"$ADMIN_LASTNAME\"
  }" > /dev/null

# Логинимся под admin, получаем токен
echo "Logging in as admin..."
TOKEN=$(curl -sf -i -X POST "$MM_URL/api/v4/users/login" \
  -H "Content-Type: application/json" \
  -d "{\"login_id\": \"$ADMIN_USERNAME\", \"password\": \"$ADMIN_PASSWORD\"}" \
  | grep -i "^token:" | tr -d '[:space:]' | cut -d':' -f2)

echo "Token: $TOKEN"

# Создаём команду (team)
echo "Creating team..."
curl -sf -X POST "$MM_URL/api/v4/teams" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$TEAM_NAME\",
    \"display_name\": \"$TEAM_DISPLAY\",
    \"type\": \"O\"
  }" > /dev/null

# Создаём тестового пользователя
echo "Creating test user..."
curl -sf -X POST "$MM_URL/api/v4/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"username\": \"$TEST_USERNAME\",
    \"password\": \"$TEST_PASSWORD\",
    \"first_name\": \"$TEST_FIRSTNAME\",
    \"last_name\": \"$TEST_LASTNAME\"
  }" > /dev/null

# Включаем кастомные статусы и вебхуки
echo "Configuring system settings..."
curl -sf -X PUT "$MM_URL/api/v4/config/patch" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "TeamSettings": { "EnableCustomUserStatuses": true },
    "ServiceSettings": {
      "EnableIncomingWebhooks": true,
      "EnableOutgoingWebhooks": true,
      "EnableUserAccessTokens": true,
      "EnableBotAccountCreation": true
    }
  }' > /dev/null

echo "Setup complete!"
echo "  Admin:    $ADMIN_USERNAME / $ADMIN_PASSWORD"
echo "  TestUser: $TEST_USERNAME / $TEST_PASSWORD"
echo "  URL:      http://localhost:8065"
