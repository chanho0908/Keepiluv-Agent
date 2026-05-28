---
name: coding-conventions
description: Kotlin/Android 코드 컨벤션 및 아키텍처 원칙 (Keepiluv/Twix 프로젝트)
---

# 코드 컨벤션

> **적용 대상:** Keepiluv (Twix) 프로젝트의 모든 Kotlin/Android 코드

---

## 기본 원칙

- **기존 코드베이스 우선**: 새로운 코드 작성 전, 반드시 기존 코드베이스의 패턴과 컨벤션을 먼저 파악하고 준수
- **필요한 것만 구현**: 과도한 추상화나 미래를 위한 설계 지양. 현재 필요한 기능만 구현
- **불필요한 주석 금지**: 코드로 의도를 드러내는 것을 우선. 코드만으로 이해 불가능한 경우에만 주석 작성
- 명확한 의미를 담은 상수로 분리. 상수명은 값의 목적과 정책을 드러내야 함
- 중첩 2단계 이상이면 guard clause, early return, 함수 추출로 분리
- 단순 분기는 early return, 복잡한 분기는 `when`으로 대체
- 의미 있는 도메인 값은 `value class`로 래핑. ID, Email, Title, Count처럼 검증/의미가 있는 값에 우선 적용
- 컬렉션 포함 클래스는 해당 컬렉션 외 다른 필드 금지. 컬렉션 관련 행위는 컬렉션 래퍼 내부로 이동
- 의도를 명확히 드러내는 이름 사용. `cnt`, `calc`, `usrId`처럼 축약된 이름 금지
- 중첩된 계산식은 의미 단위 변수로 분리. 특히 시간, 비율, 임계값, 보간값 계산은 중간 이름을 부여

---

## 함수 설계

- 메서드 15줄 초과 시 분리
- 의미 단위로 함수 추출
- 상태 변경, 데이터 호출, 결과 처리는 각각 별도 함수로 분리
- 하나의 함수는 하나의 의도만 표현

### get / set 접두사 절대 금지
- 조회: `fetch`, `load`, `find`, `search`
- 변경: `update`, `change`, `save`
- Boolean: `is`, `has`, `can`, `should`

### 이름 선택 기준
- 함수명은 동작과 결과를 함께 드러냄
- 변수명은 단위와 의미를 드러냄 (`elapsedMs`, `remainingRatio`, `retryCount`)
- Repository 우회 호출이라도 단순 `get...` 대신 프로젝트 동사 규칙을 따름


### onEvent 위임
분기에서 로직 직접 작성 금지. `onEvent`는 이벤트 라우팅만 담당하고 실제 처리는 `handle...` 함수로 위임

```kotlin
fun onEvent(event: UiEvent) {
    when (event) {
        is UiEvent.LoadData -> handleLoadData()
    }
}
```

## SOLID 원칙

### SRP (Single Responsibility Principle)
- **ViewModel**: UI 상태 관리만
- **UseCase**: 비즈니스 로직 하나만

### UseCase 생성 기준
- **생성**: 비즈니스 로직이 있을 때만
- **생략**: 단순 Repository 위임(bypass)은 ViewModel에서 직접 호출

### ISP (Interface Segregation Principle)
Repository는 역할별로 인터페이스 분리

### DIP (Dependency Inversion Principle)
인터페이스에 의존, Koin DI로 주입

---

## DI (Koin)

### 모듈 구조
각 feature 패키지 하위에 `di` 패키지를 두고 `{FeatureName}Module.kt`에 ViewModel을 등록

```text
feature/
  login/
    di/
      LoginModule.kt
    LoginViewModel.kt
    LoginScreen.kt
di/
  AppModule.kt
```

### AppModule 역할
**각 feature 모듈을 `includes()`로 통합만 함**. ViewModel을 직접 등록하지 않음

---

## 문자열 관리

### UI 노출 문자열
반드시 `strings.xml`로 분리. 포맷팅 인자가 있으면 `%1$s`, `%2$d` 등 포맷 플레이스홀더 활용

### 하드코딩 금지
매직 넘버, UI에 노출되지 않는 디버깅용 에러 메시지는 `companion object` 상수로 분리

---

## 레이어별 코딩 가이드

### Domain Layer

**원칙:**
- Pure Kotlin만 사용 (UI/Android 의존성 절대 금지)
- 비즈니스 로직 계산만 수행
- 문자열 포맷팅, 리소스 접근, Compose 의존 금지

**권장 패턴:**
- 팩토리 메서드: `companion object { fun from(...) }`
- 계산 결과는 UI가 표현하기 쉬운 값 객체로 반환
- 시간 계산은 가능하지만 "n분 전" 같은 표시 문자열 생성은 금지

### UI Layer

**원칙:**
- 포맷팅은 UI의 책임
- `stringResource`로 문자열 포맷팅
- Domain 모델을 UI에 맞게 변환

**권장 패턴:**
- Composable 함수에서 포맷팅
- `remember` / `derivedStateOf` 활용
- Domain 값 객체를 받아 화면 표시 문자열로 변환

### Presentation Layer (ViewModel)

**원칙:**
- BaseViewModel 상속
- onEvent는 별도 함수로 위임
- UI 상태 변경과 SideEffect 발행만 담당
- Android/Compose UI 객체를 상태에 직접 보관하지 않음

### Data Layer

**원칙:**
- Repository 인터페이스는 `domain/` 모듈에 정의
- 구현체는 `data/` 모듈에 위치
- Mapper는 `ResponseDto.toDomain()` 확장 함수 패턴 사용
- API 응답 모델을 UI/Presentation으로 직접 전달하지 않음

---

## 절대 금지 사항

- Singleton 객체에 Context 전달
  - **문제:** 메모리 누수 위험
- util/core 모듈에 비즈니스 로직
  - **문제:** 레이어 책임 위반
- Domain에서 문자열 포맷팅
  - **문제:** UI 관심사가 Domain에 침투

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
