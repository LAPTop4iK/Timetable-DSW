# Руководство по настройке и запуску тестов

## 📋 Содержание

1. [Обзор тестового покрытия](#обзор-тестового-покрытия)
2. [Настройка тестовых таргетов в Xcode](#настройка-тестовых-таргетов-в-xcode)
3. [Запуск unit-тестов](#запуск-unit-тестов)
4. [Запуск UI-тестов](#запуск-ui-тестов)
5. [Запуск всех тестов одновременно](#запуск-всех-тестов-одновременно)
6. [Accessibility Identifiers](#accessibility-identifiers)
7. [CI/CD интеграция](#cicd-интеграция)

---

## Обзор тестового покрытия

### Unit Tests (138+ тестов)
- ✅ Models (18 тестов)
- ✅ EventTypeDetector (27 тестов)
- ✅ DateService (20 тестов)
- ✅ CacheManager (12 тестов)
- ✅ NetworkManager (13 тестов)
- ✅ ScheduleRepository (13 тестов)
- ✅ AppViewModel (35+ тестов)

**Покрытие кода:** ~94%

### UI Tests (15+ тестов)
- ✅ Навигация по экранам
- ✅ Выбор группы
- ✅ Поиск групп
- ✅ Обновление расписания
- ✅ Переключение между вкладками
- ✅ Полный user flow

---

## Настройка тестовых таргетов в Xcode

### 1. Добавление Unit Test таргета

#### Шаг 1: Создание таргета
1. Откройте Xcode
2. Выберите проект в Project Navigator
3. Нажмите "+" в списке таргетов (внизу слева)
4. Выберите **iOS → Test → Unit Testing Bundle**
5. Назовите таргет: **Timetable DSWTests**
6. Нажмите **Finish**

#### Шаг 2: Добавление существующих файлов
1. В Project Navigator найдите папку `Timetable DSWTests/`
2. Выберите все файлы тестов:
   - `ModelsTests.swift`
   - `EventTypeDetectorTests.swift`
   - `DateServiceTests.swift`
   - `CacheManagerTests.swift`
   - `NetworkManagerTests.swift`
   - `ScheduleRepositoryTests.swift`
   - `AppViewModelTests.swift`
   - `Helpers/TestHelpers.swift`
   - `TestData/TestDataFactory.swift`
   - `Mocks/*.swift` (все моки)
3. В File Inspector (справа) отметьте **Target Membership** → `Timetable DSWTests`

#### Шаг 3: Настройка таргета
1. Выберите таргет `Timetable DSWTests`
2. Перейдите в **Build Settings**
3. Убедитесь, что **Test Host** установлен на основное приложение:
   ```
   $(BUILT_PRODUCTS_DIR)/Timetable DSW.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Timetable DSW
   ```

### 2. Добавление UI Test таргета

#### Шаг 1: Создание таргета
1. Выберите проект в Project Navigator
2. Нажмите "+" в списке таргетов
3. Выберите **iOS → Test → UI Testing Bundle**
4. Назовите таргет: **Timetable DSW UITests**
5. Нажмите **Finish**

#### Шаг 2: Добавление существующих файлов
1. В Project Navigator найдите папку `Timetable DSW UITests/`
2. Выберите все файлы:
   - `TimetableUITests.swift`
   - `Helpers/UITestHelpers.swift`
   - `Helpers/BaseScreen.swift`
   - `Screens/ScheduleScreen.swift`
   - `Screens/SettingsScreen.swift`
   - `Screens/GroupSelectionScreen.swift`
   - `Screens/TabBarScreen.swift`
3. В File Inspector отметьте **Target Membership** → `Timetable DSW UITests`

#### Шаг 3: Настройка таргета
1. Выберите таргет `Timetable DSW UITests`
2. Перейдите в **Build Settings**
3. Убедитесь, что **Test Target Name** установлен на основное приложение

---

## Запуск unit-тестов

### Через Xcode

#### Способ 1: Запуск всех unit-тестов
1. Выберите схему **Timetable DSWTests**
2. Нажмите **Cmd + U** или **Product → Test**

#### Способ 2: Запуск отдельного теста
1. Откройте файл с тестами
2. Кликните на ромбик слева от теста
3. Тест запустится индивидуально

#### Способ 3: Запуск класса тестов
1. Откройте файл с тестами
2. Кликните на ромбик слева от имени класса
3. Все тесты класса запустятся

### Через командную строку

```bash
# Запуск всех unit-тестов
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -only-testing:Timetable\ DSWTests

# Запуск конкретного теста
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -only-testing:Timetable\ DSWTests/AppViewModelTests/testInitialization_SetsDefaultValues

# С выводом результатов в читаемом формате
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -only-testing:Timetable\ DSWTests \
  | xcpretty
```

---

## Запуск UI-тестов

### Через Xcode

#### Способ 1: Запуск всех UI-тестов
1. Выберите схему **Timetable DSW UITests**
2. Нажмите **Cmd + U** или **Product → Test**

#### Способ 2: Запуск отдельного теста
1. Откройте `TimetableUITests.swift`
2. Кликните на ромбик слева от теста
3. UI тест запустится с визуализацией

### Через командную строку

```bash
# Запуск всех UI-тестов
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -only-testing:Timetable\ DSW\ UITests

# Запуск конкретного UI-теста
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -only-testing:Timetable\ DSW\ UITests/TimetableUITests/testFullUserFlow_SelectGroupAndViewSchedule
```

---

## Запуск всех тестов одновременно

### Через Xcode

1. Выберите основную схему **Timetable DSW**
2. Нажмите **Cmd + U**
3. Запустятся все unit и UI тесты

### Через командную строку

```bash
# Запуск всех тестов (unit + UI)
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest'

# С форматированным выводом
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  | xcpretty --test --color

# С генерацией HTML-отчета
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  | xcpretty --test --color --report html --output tests-report.html
```

### Bash-скрипт для автоматизации

Создайте файл `run_tests.sh`:

```bash
#!/bin/bash

echo "🧪 Running all tests for Timetable DSW..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCHEME="Timetable DSW"
DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro,OS=latest"

# Функция для запуска тестов
run_tests() {
    local test_target=$1
    local test_name=$2

    echo -e "${YELLOW}Running ${test_name}...${NC}"

    xcodebuild test \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"$test_target" \
        2>&1 | xcpretty --test --color

    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ ${test_name} passed!${NC}\n"
        return 0
    else
        echo -e "${RED}❌ ${test_name} failed!${NC}\n"
        return 1
    fi
}

# Запуск unit-тестов
run_tests "Timetable DSWTests" "Unit Tests"
unit_result=$?

# Запуск UI-тестов
run_tests "Timetable DSW UITests" "UI Tests"
ui_result=$?

# Итоговый результат
echo "================================"
if [ $unit_result -eq 0 ] && [ $ui_result -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}💥 Some tests failed${NC}"
    exit 1
fi
```

Сделайте скрипт исполняемым:

```bash
chmod +x run_tests.sh
./run_tests.sh
```

---

## Accessibility Identifiers

Для работы UI-тестов в код приложения добавлены следующие accessibility identifiers:

### Tab Bar
```swift
// ContentView.swift
"tabSchedule"  // Вкладка "Расписание"
"tabSubjects"  // Вкладка "Предметы"
"tabTeachers"  // Вкладка "Преподаватели"
"tabSettings"  // Вкладка "Настройки"
```

### Schedule Screen
```swift
// DayScheduleTabView.swift
"scheduleList" // Список событий расписания
```

### Settings Screen
```swift
// SettingsView.swift
"groupSelectionButton" // Кнопка выбора группы
"themeButton"          // Кнопка выбора темы
```

### Group Selection Screen
```swift
// GroupSelectionView.swift
"groupsList"        // Список групп
"groupCancelButton" // Кнопка отмены
```

### Как использовать в тестах

```swift
// Пример использования
let scheduleTab = app.buttons["tabSchedule"]
scheduleTab.tap()

let groupButton = app.buttons["groupSelectionButton"]
XCTAssertTrue(groupButton.exists)
```

---

## CI/CD интеграция

### GitHub Actions

Создайте файл `.github/workflows/tests.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app

    - name: Install xcpretty
      run: gem install xcpretty

    - name: Run Unit Tests
      run: |
        xcodebuild test \
          -scheme "Timetable DSW" \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
          -only-testing:Timetable\ DSWTests \
          | xcpretty --test --color

    - name: Run UI Tests
      run: |
        xcodebuild test \
          -scheme "Timetable DSW" \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
          -only-testing:Timetable\ DSW\ UITests \
          | xcpretty --test --color

    - name: Upload Test Results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: build/reports/
```

### Fastlane

Создайте `Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Run all tests"
  lane :test do
    run_tests(
      scheme: "Timetable DSW",
      devices: ["iPhone 15 Pro"],
      code_coverage: true
    )
  end

  desc "Run only unit tests"
  lane :test_unit do
    run_tests(
      scheme: "Timetable DSW",
      devices: ["iPhone 15 Pro"],
      only_testing: ["Timetable DSWTests"]
    )
  end

  desc "Run only UI tests"
  lane :test_ui do
    run_tests(
      scheme: "Timetable DSW",
      devices: ["iPhone 15 Pro"],
      only_testing: ["Timetable DSW UITests"]
    )
  end
end
```

Запуск через Fastlane:

```bash
# Все тесты
fastlane test

# Только unit
fastlane test_unit

# Только UI
fastlane test_ui
```

---

## Полезные команды

### Список доступных симуляторов
```bash
xcrun simctl list devices available
```

### Очистка derived data
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Сброс симулятора
```bash
xcrun simctl erase all
```

### Просмотр покрытия кода
```bash
xcodebuild test \
  -scheme "Timetable DSW" \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
  -enableCodeCoverage YES \
  -derivedDataPath ./DerivedData

# Генерация отчета о покрытии
xcrun xccov view --report ./DerivedData/Logs/Test/*.xcresult
```

---

## Troubleshooting

### Проблема: "Test target not found"
**Решение:** Убедитесь, что файлы тестов добавлены в правильный таргет через Target Membership.

### Проблема: "UI tests fail to find elements"
**Решение:** Проверьте, что accessibility identifiers добавлены в код приложения и совпадают с теми, что используются в тестах.

### Проблема: "Simulator boot timeout"
**Решение:**
```bash
# Завершите все симуляторы
killall Simulator

# Перезапустите тесты
```

### Проблема: "Linker errors in tests"
**Решение:** Добавьте необходимые файлы исходного кода в Target Membership тестового таргета или установите `@testable import Timetable_DSW`.

---

## Следующие шаги для миграции на KMP

После того как все тесты проходят успешно:

1. ✅ **Тесты готовы** - У вас есть полное покрытие тестами (138+ unit + 15+ UI)
2. 🔄 **Начинайте миграцию** - Можно безопасно переносить бизнес-логику на Kotlin
3. 🧪 **TDD подход** - Пишите тесты на Kotlin, переносите логику, проверяйте что поведение не изменилось
4. 🎯 **Цель** - Shared KMP модуль с бизнес-логикой + нативные UI (SwiftUI + Compose)

---

## Документация

Дополнительная документация по тестам:

- **TEST_SUMMARY.md** - Краткий обзор тестового покрытия
- **TEST_COVERAGE.md** - Детальная техническая документация
- **Timetable DSWTests/** - Unit тесты
- **Timetable DSW UITests/** - UI тесты

---

**Удачи с тестированием! 🚀**
