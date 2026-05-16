---
name: coding-conventions
description: Kotlin/Android 코드 컨벤션 및 아키텍처 원칙 (Keepiluv/Twix 프로젝트)
---

# 코드 컨벤션

> **적용 대상:** Keepiluv (Twix) 프로젝트의 모든 Kotlin/Android 코드

---

## 기본 원칙

### 기존 코드베이스 우선
새로운 코드 작성 전, 반드시 기존 코드베이스의 패턴과 컨벤션을 먼저 파악하고 준수

### 필요한 것만 구현
과도한 추상화나 미래를 위한 설계 지양. 현재 필요한 기능만 구현

### 불필요한 주석 금지
코드로 의도를 드러내는 것을 우선. 코드만으로 이해 불가능한 경우에만 주석 작성

### 매직 넘버 금지
명확한 의미를 담은 상수화
```kotlin
// ❌
if (count > 5) { ... }

// ✅
private const val MAX_RETRY_COUNT = 5
if (count > MAX_RETRY_COUNT) { ... }
```

### 들여쓰기 1단계
중첩 2단계 이상이면 메서드 추출
```kotlin
// ❌
fun process() {
    if (condition1) {
        if (condition2) {
            if (condition3) {
                // 너무 깊은 중첩
            }
        }
    }
}

// ✅
fun process() {
    if (!condition1) return
    processCondition2And3()
}

private fun processCondition2And3() {
    if (!condition2) return
    handleCondition3()
}
```

### else 금지
early return 또는 `when`으로 대체
```kotlin
// ❌
fun getStatus(code: Int): String {
    if (code == 200) {
        return "Success"
    } else {
        return "Error"
    }
}

// ✅
fun getStatus(code: Int): String {
    if (code == 200) return "Success"
    return "Error"
}

// ✅ (복잡한 경우)
fun getStatus(code: Int): String = when (code) {
    200 -> "Success"
    404 -> "Not Found"
    else -> "Error"
}
```

### 원시값 포장
의미 있는 도메인 값은 `value class`로 래핑
```kotlin
// ❌
fun sendEmail(email: String) { ... }

// ✅
@JvmInline
value class Email(val value: String)

fun sendEmail(email: Email) { ... }
```

### 일급 컬렉션
컬렉션 포함 클래스는 해당 컬렉션 외 다른 필드 금지
```kotlin
// ❌
data class Goals(
    val items: List<Goal>,
    val userId: String  // 다른 필드 존재
)

// ✅
data class Goals(val items: List<Goal>) {
    val size: Int get() = items.size
    fun filter(predicate: (Goal) -> Boolean) = Goals(items.filter(predicate))
}
```

### 축약 금지
의도를 명확히 드러내는 이름
```kotlin
// ❌
val cnt = 5
fun calc() { ... }
val usrId = "123"

// ✅
val retryCount = 5
fun calculateTotalPrice() { ... }
val userId = "123"
```

### 계산식 분해
중첩된 계산식은 의미 단위로 변수에 분리하여 가독성 확보
```kotlin
// ❌
return (COOLDOWN_MS - (System.currentTimeMillis() - pokedAt)).coerceAtLeast(0L)

// ✅
val elapsedMs = currentTime - pokedAt
val remainingMs = COOLDOWN_MS - elapsedMs
return remainingMs.coerceAtLeast(0L)
```

```kotlin
// ❌
val overflow = min((speed - dragVelocityThreshold) / dragVelocityThreshold, 1f)

// ✅
val excessSpeed = speed - dragVelocityThreshold
val overflowRatio = excessSpeed / dragVelocityThreshold
val overflow = min(overflowRatio, 1f)
```

---

## 함수 설계
- 메서드 15줄 초과 시 분리
- 의미 단위로 함수 추출

### onEvent 위임
분기에서 로직 직접 작성 금지, 반드시 별도 함수로 위임
```kotlin
// ❌
fun onEvent(event: UiEvent) {
    when (event) {
        is UiEvent.LoadData -> {
            viewModelScope.launch {
                _uiState.value = UiState.Loading
                val result = repository.loadData()
                _uiState.value = when (result) {
                    is Success -> UiState.Success(result.data)
                    is Failure -> UiState.Error(result.error)
                }
            }
        }
    }
}

// ✅
fun onEvent(event: UiEvent) {
    when (event) {
        is UiEvent.LoadData -> handleLoadData()
    }
}

private fun handleLoadData() {
    viewModelScope.launch {
        updateLoadingState()
        val result = fetchData()
        handleDataResult(result)
    }
}
```

### 함수 단일 책임
상태 변경 / 데이터 호출 / 결과 처리 각각 별도 함수로 분리
```kotlin
// ❌
fun loadUser() {
    _uiState.value = UiState.Loading
    viewModelScope.launch {
        val user = repository.getUser()
        _uiState.value = UiState.Success(user)
    }
}

// ✅
fun loadUser() {
    updateLoadingState()
    fetchUserAndUpdateState()
}

private fun updateLoadingState() {
    _uiState.value = UiState.Loading
}

private fun fetchUserAndUpdateState() {
    viewModelScope.launch {
        val user = fetchUser()
        updateSuccessState(user)
    }
}

private suspend fun fetchUser() = repository.getUser()

private fun updateSuccessState(user: User) {
    _uiState.value = UiState.Success(user)
}
```

---

## SOLID 원칙

### SRP (Single Responsibility Principle)
- **ViewModel**: UI 상태 관리만
- **UseCase**: 비즈니스 로직 하나만

### UseCase 생성 기준
- **생성**: 비즈니스 로직이 있을 때만
- **생략**: 단순 Repository 위임(bypass)은 ViewModel에서 직접 호출

### ISP (Interface Segregation Principle)
- Repository는 역할별로 인터페이스 분리

### DIP (Dependency Inversion Principle)
- 인터페이스에 의존, Koin DI로 주입

---

## DI (Koin)

### 모듈 구조
각 feature 패키지 하위에 `di` 패키지를 두고 `{FeatureName}Module.kt`에 ViewModel을 등록

```
feature/
  login/
    di/
      LoginModule.kt    ← viewModel { LoginViewModel(...) }
    LoginViewModel.kt
    LoginScreen.kt
di/
  AppModule.kt          ← includes(loginModule, ...)
```

### AppModule 역할
**각 feature 모듈을 `includes()`로 통합만 함** — ViewModel을 직접 등록하지 않음

---

## 네이밍 규칙

### get / set 접두사 절대 금지
```kotlin
// ❌
fun getUser(): User
fun setName(name: String)

// ✅
fun fetchUser(): User
fun loadUser(): User
fun updateName(name: String)
```

### 동사 선택
- **조회**: `fetch` `load` `find` `search`
- **변경**: `update` `change` `save`
- **Boolean**: `is` `has` `can` `should`

```kotlin
// ✅
suspend fun fetchGoals(): List<Goal>
suspend fun loadUserProfile(): User
fun findGoalById(id: String): Goal?
fun searchGoals(query: String): List<Goal>

fun updateGoalTitle(id: String, title: String)
fun saveGoal(goal: Goal)

fun isCompleted(): Boolean
fun hasPermission(): Boolean
fun canEdit(): Boolean
```

---

## 문자열 관리

### UI 노출 문자열
반드시 `strings.xml`로 분리. 포맷팅 인자가 있으면 `%1$s`, `%2$d` 등 포맷 플레이스홀더 활용

### 하드코딩 금지
매직 넘버, UI에 노출되지 않는 디버깅용 에러 메시지는 `companion object` 상수로 분리

```kotlin
// ❌
throw IllegalArgumentException("User ID cannot be empty")

// ✅
companion object {
    private const val ERROR_EMPTY_USER_ID = "User ID cannot be empty"
}

throw IllegalArgumentException(ERROR_EMPTY_USER_ID)
```

---

## 레이어별 코딩 가이드

### Domain Layer

**원칙:**
- Pure Kotlin만 사용 (UI/Android 의존성 절대 금지)
- 비즈니스 로직 계산만 수행

**권장 패턴:**
- 팩토리 메서드: `companion object { fun from(...) }`

**예시:**
```kotlin
// ✅ Domain Layer
data class RelativeTime(
    val days: Long,
    val hours: Long,
    val minutes: Long
) {
    companion object {
        fun from(uploadedAt: Instant): RelativeTime {
            val now = Clock.System.now()
            val duration = now - uploadedAt
            // 시간 계산만 수행 (포맷팅 X)
            return RelativeTime(
                days = duration.inWholeDays,
                hours = duration.inWholeHours % 24,
                minutes = duration.inWholeMinutes % 60
            )
        }
    }
}
```

---

### UI Layer

**원칙:**
- **포맷팅은 UI의 책임**
- `stringResource`로 문자열 포맷팅
- Domain 모델을 UI에 맞게 변환

**권장 패턴:**
- Composable 함수에서 포맷팅
- `remember` / `derivedStateOf` 활용

**예시:**
```kotlin
@Composable
fun PhotoCard(uploadedAt: Instant) {
    val relativeTime = remember(uploadedAt) {
        RelativeTime.from(uploadedAt)
    }
    val formattedTime = formatRelativeTime(relativeTime)
    Text(formattedTime)
}

@Composable
fun formatRelativeTime(relativeTime: RelativeTime): String {
    return stringResource(R.string.days_ago, relativeTime.days)
}
```

---

### Presentation Layer (ViewModel)

**원칙:**
- BaseViewModel 상속
- onEvent는 별도 함수로 위임 (이미 "onEvent 위임" 섹션 참조)

---

### Data Layer

**원칙:**
- Repository 인터페이스는 `domain/` 모듈에 정의
- 구현체는 `data/` 모듈에 위치
- Mapper: `ResponseDto.toDomain()` 확장 함수 패턴

**예시:**
```kotlin
// domain/repository/GoalRepository.kt
interface GoalRepository {
    suspend fun getGoals(): AppResult<List<Goal>>
}

// data/repository/GoalRepositoryImpl.kt
class GoalRepositoryImpl(
    private val api: GoalApi
) : GoalRepository {
    override suspend fun getGoals(): AppResult<List<Goal>> = runCatchingAppError {
        api.getGoals().toDomain()
    }
}

// data/mapper/GoalMapper.kt
fun GoalResponse.toDomain(): Goal = Goal(
    id = this.id,
    title = this.title,
    // ...
)
```

---

## 절대 금지 사항
- Singleton 객체에 Context 전달
  - **문제:** 메모리 누수 위험
- util/core 모듈에 비즈니스 로직
  -**문제:** 레이어 책임 위반
- Domain에서 문자열 포맷팅
  -**문제:** UI 관심사가 Domain에 침투

---

## 계획 작성 시 체크리스트

구현 전 계획 단계에서 다음 항목을 미리 판단하고 명시:

- [ ] **파일 분리**: 컨벤션 기준으로 파일 분리 여부 판단
- [ ] **메서드 크기**: 15줄 기준 준수 여부
- [ ] **UseCase 생성 여부**: 비즈니스 로직 유무로 판단
- [ ] **네이밍**: get/set 금지, 축약 금지 적용된 이름
- [ ] **strings.xml 항목**: UI 문자열 키 이름 명시
- [ ] **모듈 의존성**: 새 모듈 추가 시 `build.gradle.kts`, `settings.gradle.kts` 변경 항목
- [ ] **변경 파일 목록**: Domain → Data → Presentation → UI 순서로 정리
