# Keepiluv Coding Conventions

## 목차

- [기본 원칙](#기본-원칙)
- [함수와 이름](#함수와-이름)
- [SOLID와 UseCase](#solid와-usecase)
- [Koin 의존성 주입](#koin-의존성-주입)
- [문자열과 상수](#문자열과-상수)
- [레이어별 규칙](#레이어별-규칙)
- [금지 사항](#금지-사항)
- [계획 체크리스트](#계획-체크리스트)

## 기본 원칙

- 새 코드를 작성하기 전에 기존 코드베이스의 패턴과 관례를 먼저 확인한다.
- 현재 필요한 기능만 구현하고, 미래를 위한 과도한 추상화를 만들지 않는다.
- 코드로 의도를 드러내고, 코드만으로 이해하기 어려운 경우에만 짧은 주석을 쓴다.
- 값의 목적과 정책이 드러나는 상수를 사용한다.
- 중첩이 2단계 이상이면 guard clause, early return, 함수 추출을 검토한다.
- 단순 분기는 early return을 사용하고, 복잡한 분기는 `when`을 검토한다.
- ID, Email, Title, Count처럼 의미나 검증 규칙이 있는 값은 `value class`로 감싸는 것을 우선 검토한다.
- 컬렉션을 감싼 클래스에는 컬렉션 외 필드를 두지 않고, 컬렉션 관련 행위를 래퍼 안으로 옮긴다.
- `cnt`, `calc`, `usrId` 같은 축약어를 쓰지 않는다.
- 시간, 비율, 임계값, 보간값처럼 중첩된 계산식은 의미 단위의 중간 변수로 나눈다.

## 함수와 이름

- 메서드가 15줄을 넘으면 의미 단위 분리를 검토한다.
- 상태 변경, 데이터 호출, 결과 처리를 별도 함수로 나눈다.
- 함수 하나는 의도 하나만 표현한다.
- 함수명은 동작과 결과를 함께 드러낸다.
- 변수명은 `elapsedMs`, `remainingRatio`, `retryCount`처럼 단위와 의미를 드러낸다.

`get`과 `set` 접두사는 사용하지 않는다.

- 조회: `fetch`, `load`, `find`, `search`
- 변경: `update`, `change`, `save`
- Boolean: `is`, `has`, `can`, `should`

Repository를 단순히 호출하더라도 프로젝트의 동사 규칙을 따른다.

`onEvent`는 이벤트 경로만 정하고 실제 처리를 `handle...` 함수에 맡긴다.

```kotlin
fun onEvent(event: UiEvent) {
    when (event) {
        is UiEvent.LoadData -> handleLoadData()
    }
}
```

## SOLID와 UseCase

### SRP

- ViewModel은 UI 상태를 관리한다.
- UseCase는 하나의 비즈니스 규칙을 담당한다.

### UseCase 생성 기준

- 비즈니스 로직이 있으면 만든다.
- Repository에 그대로 전달만 하는 경우에는 만들지 않고 ViewModel에서 직접 호출한다.

### ISP와 DIP

- Repository 인터페이스는 역할별로 나눈다.
- 구현체보다 인터페이스에 의존하고 Koin으로 주입한다.

## Koin 의존성 주입

각 feature 아래 `di` 패키지를 두고 `{FeatureName}Module.kt`에 ViewModel을 등록한다.

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

`AppModule`은 feature 모듈을 `includes()`로 모으기만 하며 ViewModel을 직접 등록하지 않는다.

## 문자열과 상수

- 사용자 화면에 보이는 문자열은 반드시 `strings.xml`로 분리한다.
- 포맷 인자는 `%1$s`, `%2$d` 같은 자리 표시자를 사용한다.
- 매직 넘버와 화면에 보이지 않는 디버그용 오류 메시지는 `companion object` 상수로 분리한다.

## 레이어별 규칙

레이어 책임과 의존 방향의 source of truth는 [architecture.md](../../../../wiki/reference/architecture.md), 모듈과 파일 위치의 source of truth는 [hierarchy.md](../../../../wiki/reference/module-hierarchy.md)이다. 이 reference에는 구현 중 반복 확인할 코딩 규칙만 둔다.

- Domain 변경에서 Android, Compose, 리소스 접근, 표시 문자열 생성을 발견하면 레이어 경계를 다시 확인한다.
- ViewModel은 `BaseViewModel` 패턴을 따르고 `onEvent`의 실제 처리를 별도 함수에 맡긴다.
- UiState에 Android 또는 Compose UI 객체를 직접 저장하지 않는다.
- DTO 변환은 `ResponseDto.toDomain()` 확장 함수 패턴을 따르고 API 응답 모델을 상위 레이어에 노출하지 않는다.
- 값 생성 규칙이 모델 자체의 책임이면 `companion object { fun from(...) }` 형태의 팩토리 메서드를 사용할 수 있다.
- UI 포맷팅에서 상태 기반 계산이 필요하면 `remember`, `derivedStateOf` 사용을 검토한다.

## 금지 사항

- Singleton 객체에 Context를 전달하지 않는다. 메모리 누수 위험이 있다.
- `util` 또는 `core` 모듈에 비즈니스 규칙을 두지 않는다. 레이어 책임이 흐려진다.
- Domain에서 문자열을 포맷하지 않는다. 표현 책임이 Domain으로 침투한다.

## 계획 체크리스트

사용자가 읽는 계획 본문에 먼저 적는다.

- [ ] 목표: 무엇을 왜 바꾸는가?
- [ ] 사용자 흐름: 사용자가 어떤 순서로 경험하는가?
- [ ] 정책과 판단 기준: 어떤 조건에서 어떤 동작을 하는가?
- [ ] 예외 처리: 실패, 취소, 재시도, 빈 상태를 어떻게 다루는가?
- [ ] 검증 계획: 자동 테스트와 수동 확인은 무엇인가?

기술 메모 또는 handoff에 분리한다.

- [ ] 파일 분리 여부
- [ ] 메서드 15줄 기준
- [ ] 비즈니스 로직에 따른 UseCase 생성 여부
- [ ] `get`/`set`과 축약어를 피한 이름
- [ ] `strings.xml` 키
- [ ] 새 모듈의 `build.gradle.kts`, `settings.gradle.kts` 변경
- [ ] Domain → Data → Presentation → UI 순서의 변경 파일 목록
