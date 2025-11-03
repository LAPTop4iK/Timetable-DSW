#!/bin/bash

echo "🧪 Running all tests for Timetable DSW..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCHEME="Timetable DSW"
DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro,OS=latest"

# Проверка установки xcpretty
if ! command -v xcpretty &> /dev/null; then
    echo -e "${YELLOW}⚠️  xcpretty not installed. Installing...${NC}"
    gem install xcpretty
fi

# Функция для запуска тестов
run_tests() {
    local test_target=$1
    local test_name=$2

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Running ${test_name}...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"$test_target" \
        2>&1 | xcpretty --test --color

    local result=${PIPESTATUS[0]}

    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✅ ${test_name} passed!${NC}\n"
        return 0
    else
        echo -e "${RED}❌ ${test_name} failed!${NC}\n"
        return 1
    fi
}

# Начало тестирования
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Timetable DSW Test Suite          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

start_time=$(date +%s)

# Запуск unit-тестов
run_tests "Timetable DSWTests" "Unit Tests"
unit_result=$?

# Запуск UI-тестов
run_tests "Timetable DSW UITests" "UI Tests"
ui_result=$?

# Подсчет времени выполнения
end_time=$(date +%s)
duration=$((end_time - start_time))

# Итоговый результат
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}              Test Summary              ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $unit_result -eq 0 ]; then
    echo -e "Unit Tests:   ${GREEN}✅ PASSED${NC}"
else
    echo -e "Unit Tests:   ${RED}❌ FAILED${NC}"
fi

if [ $ui_result -eq 0 ]; then
    echo -e "UI Tests:     ${GREEN}✅ PASSED${NC}"
else
    echo -e "UI Tests:     ${RED}❌ FAILED${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Total time:   ${duration}s"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

if [ $unit_result -eq 0 ] && [ $ui_result -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     🎉 All tests passed! 🎉            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     💥 Some tests failed 💥            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    exit 1
fi
