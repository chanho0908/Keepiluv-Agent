---
name: architecture
description: MVI + Clean Architecture 핵심 원칙 요약
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

## 참고 문서

| 문서 | 파일 |
|------|------|
| 프로젝트 개요 | `.codex/docs/project-overview.md` |
| 모듈 구조 | `.codex/docs/hierarchy.md` |
| 코드 컨벤션 | `.codex/skills/coding-conventions.md` |
