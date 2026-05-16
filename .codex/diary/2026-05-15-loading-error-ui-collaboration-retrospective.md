# 2026-05-15: Loading/Error UI 적용 작업 - 첫 협업 회고

## 작업 내용
여러 feature의 네트워크 호출 화면에 초기 로딩, 초기 에러, 액션 로딩 오버레이, 토스트 정책을 일괄 적용했다.

구체적으로는 `Home`, `Stats`, `StatsDetail`, `PhotologDetail`, `PhotologEditor`, `Notification`, `Settings`, `GoalManage`, `GoalEditor`, `Login`, `OnBoarding`의 상태 모델과 화면 렌더링 규칙을 정리했다.

## 소통 과정에서의 시행착오

### 1차 시도: 일반적인 MVI 패턴으로 빠르게 확장 ❌
**접근 방법:**
- `Home`을 기준으로 다른 화면에도 같은 로딩/에러 UX를 빠르게 확장
- `Retry`나 로딩 조건도 일반적인 Compose/MVI 관점에서 우선 구현

**문제점:**
- 이 저장소의 구체적인 팀 규칙보다 범용 패턴을 먼저 적용했다
- 구현은 빨랐지만, 팀 컨벤션과 어긋나는 부분이 여러 군데 생겼다

**사용자 피드백:**
> "viewModel의 메서드를 직접 호출하는 것은 MVI 패턴 위반입니다"
> "Retry : Intent 를 전달해 MVI 패턴을 준수"

**배운 점:**
- 이 프로젝트에서는 `Retry`를 포함한 모든 사용자 액션이 반드시 `Intent` 경유여야 한다
- 동작만 맞추는 것보다 상태 흐름의 일관성이 더 중요하다

---

### 2차 시도: 범용 액션 로딩 상태 추가 ❌
**접근 방법:**
- 여러 화면의 액션 로딩을 빠르게 맞추기 위해 `isActionLoading` 같은 공통 플래그를 추가

**문제점:**
- 의미가 모호한 범용 상태가 늘어났다
- 화면별 동작 의미가 흐려졌고, 팀의 상태 네이밍 컨벤션과 맞지 않았다

**사용자 피드백:**
> "UiState에 val isActionLoading: Boolean = false 를 추가하지 마세요"
> "토스트 렌더링은 다음 코드를 참고"

**배운 점:**
- 범용 불리언 상태는 편하지만 유지보수성이 떨어진다
- 액션 로딩은 `isSaving`, `isPoking`처럼 목적이 드러나는 상태를 쓰거나, 가능하면 기존 `isLoading`과 화면 맥락으로 분리해야 한다

---

### 3차 시도: LoadableState 위에 중복 초기 상태 추가 ❌
**접근 방법:**
- `LoadableState`를 쓰면서도 `isInitialLoading`, `hasInitialLoadError`, `hasLoadedInitialData` 같은 초기 상태를 추가

**문제점:**
- 같은 의미의 상태가 여러 이름으로 공존했다
- 저장 상태와 파생 상태의 경계가 흐려졌다

**사용자 피드백:**
> "PhotologDetailUiState에 isInitialLoading을 만든 이유가 뭐야 ?"
> "로딩 상태는 반드시 LoadableState의 isLoading 를 사용해야해"
> "hasLoadedInitialData 가 hasLoadedContent 때문에 비슷한 성격의 상태가 두번 들어가는거 같은데 요걸 좀 개선하고싶어"

**배운 점:**
- `LoadableState` 계열 상태를 사용한다면, 그 계약이 제공하는 `isLoading`, `error`, `hasLoadedContent`를 우선 source of truth로 써야 한다
- 중복 상태를 저장하지 말고 파생 프로퍼티로 계산해야 한다

---

### 4차 시도: UI 렌더링 조건을 Screen에서 직접 계산 ❌
**접근 방법:**
- `if (uiState.isLoading && !hasLoadedContent)` 같은 조건을 Screen/Route에 직접 작성

**문제점:**
- 화면마다 조건식이 퍼지고, 같은 규칙이 중복 구현됐다
- 나중에 수정할 때 한 화면만 빠지는 회귀가 생기기 쉬운 구조였다

**사용자 피드백:**
> "PhotologEditorRoute의 174번, 178번째 라인에 있는 UI 렌저링 조건을 UiState로 캡슐화해주세요"
> "이 요청은 중요합니다 다른 화면도 맞춰주세요"

**배운 점:**
- `showLoading`, `showError`, `showOverlayLoading` 같은 화면 규칙은 `UiState`에서 캡슐화해야 한다
- Screen은 가능한 한 선언적으로 읽히고, 조건의 의미는 상태 객체에 몰아넣는 편이 유지보수에 유리하다

---

### 5차 시도: 구조 개선 제안이 실제 팀 규칙보다 앞섬 ❌
**접근 방법:**
- 작업 도중 `sealed interface`, `AsyncState`, `ContentAwareAsyncState` 등 구조적 개선안을 제안하고 일부 적용

**문제점:**
- 코드 품질 측면에서는 그럴듯했지만, 팀이 이미 익숙한 언어와 패턴에서 잠시 벗어났다
- 실제 요구사항보다 “좋아 보이는 구조”가 먼저 나오면서 왕복 수정이 늘어났다

**사용자 피드백:**
> "AsyncState, ContentAwareAsyncState 이름이 어떤 구현체인지 전혀 알기 힘든거 같아"
> "이 작업 취소하고 com.twix.domain.model의 OnboardingStatus를 활용하는거 어때 ?"
> "요건 보류할게"

**배운 점:**
- 첫 협업에서는 구조 개선보다 팀이 이미 쓰는 개념과 언어를 먼저 완전히 맞추는 것이 중요하다
- 리팩터링 제안은 “지금 꼭 필요한가”와 “팀이 읽기 쉬운가”를 먼저 확인해야 한다

---

### 최종 해결: 상태 모델링 규칙을 팀 컨벤션에 맞춰 재정렬 ✅

**최종 구조:**
- `Retry`는 모두 `Intent`로 전달
- `UiState`가 로딩/에러 렌더링 조건을 직접 캡슐화
- `LoadableState` 계열 상태는 `isLoading`, `error`, `hasLoadedContent`를 source of truth로 사용
- 초기 실패는 `ErrorScreen`, 액션 실패는 토스트
- 사용자 액션 로딩은 의미 있는 상태 또는 기존 `isLoading`과 화면 맥락으로 분리

**핵심 변경:**
- 직접 메서드 호출 제거, `Intent` 재정렬
- `isActionLoading`, `isInitialLoading` 등 중복 성격 상태 제거
- `showLoading`, `showError`, `showOverlayLoading` 규칙을 `UiState`에 캡슐화
- `Settings`, `Notification` 등 후속 회귀 버그 수정

## 핵심 교훈

### 1. 상태 모델링 규칙이 기능 요구사항만큼 중요하다
- 이 프로젝트에서는 “무엇을 보여줄지”보다 “그 상태를 어떤 이름과 경계로 모델링할지”가 훨씬 중요했다
- 특히 `UiState`는 데이터 컨테이너가 아니라 화면 규칙의 중심이다

### 2. LoadableState 계열은 중복 초기 상태를 허용하지 않는다
- `isLoading`, `error`, `hasLoadedContent`를 우선 사용
- `isInitialLoading`, `hasInitialLoadError`, `hasLoadedInitialData` 같은 중복 성격 상태는 저장하지 말고 파생해야 한다

### 3. Retry와 화면 조건은 반드시 일관된 경로를 탄다
- `Retry`는 직접 메서드 호출이 아니라 `Intent`
- 로딩/에러 UI 조건은 Screen이 아니라 `UiState`

### 4. 첫 협업에서는 구조 개선보다 팀 언어 정렬이 먼저다
- 일반적인 좋은 구조를 제안하는 것보다, 팀의 기존 규칙과 용어를 정확히 따라가는 것이 우선이다
- 새로운 추상화나 인터페이스 분리는 기준이 충분히 합의된 후에 들어가야 한다

## 에이전트 개선 제안

### implementer.md 또는 coding-conventions.md 추가 제안
```markdown
### 로딩/에러 상태 모델링 규칙
- `Retry`는 반드시 `Intent`로 전달하고, `ViewModel` 메서드를 직접 호출하지 않는다
- `UiState`가 로딩/에러 렌더링 조건(`showLoading`, `showError`, `showOverlayLoading`)을 캡슐화한다
- `LoadableState` 계열을 사용할 때는 `isLoading`, `error`, `hasLoadedContent`를 source of truth로 사용한다
- `isInitialLoading`, `hasInitialLoadError`, `hasLoadedInitialData`, `isActionLoading` 같은 중복/범용 상태는 지양한다
- 액션 실패는 `ErrorScreen`이 아니라 토스트로 처리하고, 초기 로드 실패만 전면 에러 화면으로 처리한다
```

**추가 위치:** `.codex/skills/coding-conventions.md`의 상태 관리 또는 UI 상태 섹션
**이유:** 이번 작업에서 가장 많이 왕복 수정된 부분이 바로 이 규칙이었기 때문

## 회고
이번이 첫 협업이었기 때문에, 나는 빠르게 구현해서 맞춰가는 방식을 택했고 사용자는 팀 컨벤션을 세밀하게 바로잡는 방식으로 피드백을 줬다.

결과적으로 기능은 잘 정리됐지만, 처음부터 “이 작업에서 절대 어기면 안 되는 규칙”을 더 강하게 고정했으면 수정 횟수를 크게 줄일 수 있었다.

내가 특히 더 잘했어야 했던 점은, 범용적으로 좋아 보이는 구조를 제안하기 전에 이 프로젝트에서 익숙한 이름과 패턴을 먼저 완전히 흡수하는 것이었다.

반대로 사용자 요청도 다음처럼 시작되면 더 잘 맞을 것 같다:
- 이번 작업의 절대 규칙 3~5개를 먼저 명시
- 예외 화면을 초반에 지정
- 좋은 예시 1개, 금지 예시 1개를 함께 제공

다음 작업에서는 내가 먼저 “이번 작업의 상태 관리 규칙”을 짧게 요약해 확인받고, 그 뒤에 구현을 확장하는 방식으로 가는 것이 가장 좋다.

## 태그
#상태모델링 #로딩에러UX #MVI #네이밍 #아키텍처
