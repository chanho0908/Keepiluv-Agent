---
name: model-loadable-ui-state
description: Keepiluv 화면의 초기 로딩, 기존 콘텐츠 위 로딩, 초기 오류, 사용자 액션 오류, 재시도를 MVI 상태로 모델링하는 규칙. 로딩·오류 UI를 계획하거나 UiState, Intent, ViewModel, Screen, 관련 테스트를 구현·수정·리뷰할 때 사용한다.
---

# Model Loadable UI State

로딩과 오류 UI를 다룰 때 다음 순서로 상태 경계를 정한다.

1. `UiState`가 가진 기존 `isLoading`, `error`, `hasLoadedContent`를 확인한다.
2. 화면 조건은 `showLoading`, `showError`, `showOverlayLoading` 같은 파생 프로퍼티로 캡슐화한다.
3. 기존 상태로 계산할 수 있는 `isInitialLoading`, `hasInitialLoadError`, `hasLoadedInitialData` 같은 중복 상태는 저장하지 않는다.
4. 초기 데이터 로드 실패만 전체 `ErrorScreen`으로 표시한다.
5. 기존 콘텐츠가 있는 사용자 액션 실패는 화면을 유지하고 토스트 같은 SideEffect로 알린다.
6. 기존 콘텐츠가 있는 동안의 로딩은 화면 위 오버레이로 표시한다.
7. `isActionLoading` 같은 범용 이름을 피한다. 별도 상태가 꼭 필요하면 `isSaving`, `isPoking`처럼 목적을 드러낸다.
8. 재시도는 ViewModel 공개 메서드를 직접 호출하지 않고 `Intent.Retry`처럼 MVI Intent 경로로 전달한다.

Screen은 원시 조건을 다시 조합하지 않고 `UiState`의 파생 프로퍼티만 사용한다. 새 상태를 추가하기 전에 기존 상태로 계산할 수 있는지 먼저 확인한다.

테스트에서는 다음 경계를 작업 위험에 맞게 검증한다.

- 콘텐츠가 없을 때의 초기 로딩과 초기 오류
- 콘텐츠가 있을 때의 오버레이 로딩
- 액션 실패 시 콘텐츠 유지와 SideEffect
- 재시도 사용자 행동이 `Intent.Retry`로 전달되는 흐름

이 규칙의 원본 교훈과 근거는 [.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md](../../../.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md)에 남겨 둔다.
