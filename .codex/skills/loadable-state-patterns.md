---
name: loadable-state-patterns
description: 로딩/에러 UI 상태 모델링 규칙과 LoadableState 계열 사용 패턴
source: diary
---

# Loadable State Patterns

로딩/에러 UI를 다루는 화면에서 반복적으로 어긋났던 규칙을 정리한 스킬이다.

이 프로젝트에서는 단순히 로딩을 보여주는 것보다, 상태를 어떤 이름과 경계로 모델링하느냐가 더 중요하다.

---

### Retry는 반드시 Intent로 전달
**출처:** `.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md`  
**일자:** 2026-05-15

- `Retry`는 `ViewModel`의 공개 메서드를 직접 호출하지 않는다
- `ErrorScreen(onClickRetry = { viewModel.dispatch(Intent.Retry) })` 형태로 흐르게 한다
- MVI에서 사용자 액션은 항상 Intent 경로를 타야 일관성이 유지된다

### UiState가 렌더링 조건을 캡슐화
**출처:** `.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md`  
**일자:** 2026-05-15

- `Screen`에서 `if (isLoading && !hasLoadedContent)` 같은 raw 조건을 직접 쓰지 않는다
- `UiState`에 `showLoading`, `showError`, `showOverlayLoading` 같은 파생 프로퍼티를 둔다
- Screen은 그 값을 소비만 하도록 유지한다

### LoadableState 계열은 기존 상태를 source of truth로 사용
**출처:** `.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md`  
**일자:** 2026-05-15

- `isLoading`, `error`, `hasLoadedContent`를 우선 사용한다
- `isInitialLoading`, `hasInitialLoadError`, `hasLoadedInitialData` 같은 중복 성격 상태는 저장하지 않는다
- 필요한 경우 파생 프로퍼티로 계산한다

### 범용 액션 로딩 플래그를 만들지 않는다
**출처:** `.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md`  
**일자:** 2026-05-15

- `isActionLoading` 같은 범용 플래그는 의미가 약해서 지양한다
- 액션 의미가 분명하면 `isSaving`, `isPoking`처럼 목적이 드러나는 상태를 사용한다
- 가능하면 기존 `isLoading`과 `hasLoadedContent` 조합으로 초기 로딩/오버레이 로딩을 구분한다

### 초기 실패와 액션 실패의 UX를 분리
**출처:** `.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md`  
**일자:** 2026-05-15

- 초기 데이터 로드 실패만 `ErrorScreen`
- 사용자 액션 실패는 기존 화면 유지 + 토스트
- 액션 중 로딩은 기존 화면 위 오버레이로 처리한다

---

## 적용 방법

1. 로딩/에러 화면 작업 전, 해당 `UiState`가 `isLoading`, `error`, `hasLoadedContent`를 어떻게 가질지 먼저 정한다.
2. `showLoading`, `showError`, `showOverlayLoading`을 `UiState`에 파생 프로퍼티로 정의한다.
3. `Retry`는 항상 `Intent`로 연결한다.
4. 액션 실패는 토스트, 초기 실패는 `ErrorScreen`이라는 UX 경계를 먼저 확정한다.
5. 새 상태를 추가하기 전에 기존 상태로 파생 가능한지 먼저 검토한다.
