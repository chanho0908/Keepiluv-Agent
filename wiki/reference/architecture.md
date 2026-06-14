---
name: architecture
description: MVI + Clean Architecture 핵심 원칙 요약
status: active
sources:
- repo:chanho0908/Keepiluv-Agent@14c17aa834575a9422d5e4b33c1191285c575e02:.codex/docs/architecture.md
- repo:chanho0908/Keepiluv-Agent@de9f870146845f8fffa917f7c2c794bf70edb124:.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md
last_verified: 2026-06-13
tags:
- wiki
- reference
authority: canonical
---

# Architecture Principles

## 레이어

| Layer | 위치 | 책임 | 금지 |
|------|------|------|------|
| UI | `feature/*Screen`, `feature/component` | Composable, 포맷팅, 사용자 인터랙션 | 비즈니스 로직 누적 |
| Presentation | `feature/*ViewModel`, `contract` | 상태 관리, Intent 처리, SideEffect 발행 | Android UI 직접 렌더링 |
| Domain | `domain/` | 도메인 모델, UseCase, Repository interface | Android, Compose, 포맷팅 |
| Data | `data/` | Repository 구현, API 호출, DTO/mapper | UI 상태 관리 |

## 의존 방향

`UI → Presentation → Domain ← Data`

규칙:
- 상위 레이어 역의존 금지
- Domain은 pure Kotlin 유지
- Data는 Domain 계약을 구현

## MVI 규칙

| 요소 | 규칙 |
|------|------|
| `UiState` | immutable data class |
| `Intent` | sealed interface |
| `SideEffect` | one-time event, sealed interface |
| `ViewModel` | intent 처리, state 업데이트, side effect 발행 |

## 상태 처리

- 로딩/성공/실패는 `LoadableState`
- 서버/네트워크 실패는 `AppError`
- UI는 `LoadableState`를 직접 렌더링

## 역할 경계

| 항목 | 책임 |
|------|------|
| 문자열 포맷팅 | UI |
| Repository 호출 | Presentation |
| 비즈니스 규칙 | Domain |
| DTO ↔ Domain 매핑 | Data |

## 용어 구분

| 용어 | 의미 |
|------|------|
| UI Layer | `feature` 안의 실제 Screen / Component |
| UI 모듈 | 공통 UI 인프라 모듈 (`core:ui`) |

## 구현 체크리스트

- 새 기능이 Domain 변경을 필요로 하는가
- UiState / Intent / SideEffect가 맞게 분리되었는가
- 포맷팅이 UI에 남아 있는가
- Data에서만 DTO를 알고 있는가

## MVI 상태 모델링과 협업 원칙

사용자 액션은 Intent를 통해 ViewModel에 전달합니다. 재시도처럼 단순해 보이는 동작도 화면이 ViewModel 메서드를 직접 호출하지 않고 Intent 계약을 따라야 합니다.

로딩, 성공, 실패는 `LoadableState`를 기준 상태로 사용합니다. `isLoading`, `error`, `hasLoadedContent`로 계산할 수 있는 초기 로딩 여부를 별도 값으로 다시 저장하면 같은 사실이 여러 곳에 저장되어 서로 어긋날 수 있습니다. 화면에 필요한 `showLoading`, `showError`, `showOverlayLoading`은 `UiState`의 파생 규칙으로 둡니다.

상태와 Intent 이름은 사용자 행위를 설명하는 공식 도메인 용어를 사용합니다. 같은 `selectedDate`도 화면에 따라 목표 날짜 또는 통계 조회 기준 월일 수 있으므로 코드 식별자만 보고 의미를 정하지 않습니다.

구현 전에 다음을 확인합니다.

- 이 값은 Domain 규칙인가, 화면 표시 규칙인가
- 사용자 액션이 Intent를 우회하고 있지 않은가
- 기존 상태에서 계산할 수 있는 값을 다시 저장하고 있지 않은가
- 표시 조건의 의미가 Screen 조건문에 흩어져 있지 않은가
- 공식 용어와 프로젝트의 기존 패턴을 사용하고 있는가

## 병합 이력과 근거

이 문서는 기존 `wiki/topics/architecture/mvi-state-and-collaboration.md`의 고유한 실무 규칙을 병합했습니다. 해당 topic은 삭제 전 다음 공식 문서와 회고를 바탕으로 작성되었습니다.

- `.codex/diary/2026-05-15-loading-error-ui-collaboration-retrospective.md`

삭제된 topic 자체는 커밋된 원본이 아니므로 `sources`에 넣지 않았습니다. `sources`에는 Git에서 확인 가능한 기존 문서와 회고의 커밋·경로만 보존합니다.

## 참고 문서

| 문서 | 파일 |
|------|------|
| 프로젝트 개요 | `wiki/reference/project-overview.md` |
| 모듈 구조 | `wiki/reference/module-hierarchy.md` |
| 코드 컨벤션 적용 | `.agents/skills/apply-coding-conventions/SKILL.md` |
| 로딩 UI 상태 모델링 | `.agents/skills/model-loadable-ui-state/SKILL.md` |
