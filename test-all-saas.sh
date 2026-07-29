#!/bin/bash
# Unified test script for all 3 Fox Suite SaaS products
# Tests: server boot, health, API generate, demo page
# Usage: bash test-all-saas.sh

set -e
PASS=0; FAIL=0
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

test_product() {
  local NAME=$1; local DIR=$2; local PORT=$3; local TEST_DATA=$4
  echo ""
  echo "━━━ Testing $NAME (port $PORT) ━━━"
  
  cd "$DIR"
  npm install --silent 2>/dev/null
  
  PORT=$PORT node src/server.js &
  local PID=$!
  sleep 3
  
  # Health check
  local health=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/healthz" 2>/dev/null)
  if [ "$health" = "200" ]; then echo -e "  ${GREEN}✅ Health check${NC}"; PASS=$((PASS+1))
  else echo -e "  ${RED}❌ Health check ($health)${NC}"; FAIL=$((FAIL+1)); fi
  
  # Generate endpoint
  local gen=$(curl -s -X POST "http://localhost:$PORT/api/generate" -H "Content-Type: application/json" -d "$TEST_DATA" 2>/dev/null | head -c 100)
  if echo "$gen" | grep -qv "error"; then echo -e "  ${GREEN}✅ Generate endpoint${NC}"; PASS=$((PASS+1))
  else echo -e "  ${RED}❌ Generate endpoint${NC}"; FAIL=$((FAIL+1)); fi
  
  # Demo page
  local demo=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/demo" 2>/dev/null)
  if [ "$demo" = "200" ]; then echo -e "  ${GREEN}✅ Demo page${NC}"; PASS=$((PASS+1))
  else echo -e "  ${RED}❌ Demo page ($demo)${NC}"; FAIL=$((FAIL+1)); fi
  
  kill $PID 2>/dev/null
  cd - > /dev/null
}

test_product "ReplyFox" "/Users/ghali/money-fleet/replyfox" 4601 \
  '{"businessKey":"demo-key-0001","message":"What are your hours?"}'

test_product "PostPilot" "/Users/ghali/money-fleet/postpilot" 4602 \
  '{"businessKey":"demo-key-0001"}'

test_product "DescFox" "/Users/ghali/money-fleet/descfox" 4603 \
  '{"businessKey":"demo-key-0001","productName":"Test","features":["f1"],"price":29,"platform":"amazon"}'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${GREEN}PASS: $PASS${NC}  ${RED}FAIL: $FAIL${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
