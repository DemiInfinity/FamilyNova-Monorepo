#!/bin/bash

# Test Parents Dashboard Endpoint
# Usage: ./test_dashboard.sh <parent_email> <password> [base_url]

PARENT_EMAIL="${1:-YOUR_EMAIL@example.com}"
PASSWORD="${2:-YOUR_PASSWORD}"
BASE_URL="${3:-https://family-nova-monorepo.vercel.app}"

echo "🔐 Logging in as parent: $PARENT_EMAIL"
echo "📍 Base URL: $BASE_URL"
echo ""

# Step 1: Login and get token
echo "Step 1: Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$PARENT_EMAIL\",
    \"password\": \"$PASSWORD\"
  }")

echo "Login Response:"
echo "$LOGIN_RESPONSE" | jq '.' 2>/dev/null || echo "$LOGIN_RESPONSE"
echo ""

# Extract token
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // .access_token // empty' 2>/dev/null)

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Failed to get token. Please check your credentials."
  exit 1
fi

echo "✅ Token obtained: ${TOKEN:0:50}..."
echo ""

# Step 2: Get Dashboard
echo "Step 2: Getting parents dashboard..."
DASHBOARD_RESPONSE=$(curl -s -X GET "$BASE_URL/api/parents/dashboard" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo "Dashboard Response:"
echo "$DASHBOARD_RESPONSE" | jq '.' 2>/dev/null || echo "$DASHBOARD_RESPONSE"
echo ""

# Extract and display children count
CHILDREN_COUNT=$(echo "$DASHBOARD_RESPONSE" | jq '.parent.children | length' 2>/dev/null)

if [ -z "$CHILDREN_COUNT" ] || [ "$CHILDREN_COUNT" = "null" ]; then
  echo "⚠️  Could not parse children count"
else
  echo "📊 Children Found: $CHILDREN_COUNT"
  
  if [ "$CHILDREN_COUNT" -eq 0 ]; then
    echo "⚠️  NO CHILDREN FOUND!"
    echo ""
    echo "Possible issues:"
    echo "  1. No entries in parent_children table"
    echo "  2. Children don't have parent_account_id set"
    echo "  3. Check backend logs for detailed debugging"
  else
    echo ""
    echo "Children Details:"
    echo "$DASHBOARD_RESPONSE" | jq '.parent.children[] | {id, displayName: .profile.displayName, school: .profile.school, grade: .profile.grade}' 2>/dev/null
  fi
fi

echo ""
echo "✅ Test complete!"

