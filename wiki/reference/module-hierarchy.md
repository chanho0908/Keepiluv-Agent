---
name: hierarchy
description: 모듈 구조와 feature 표준 형태 요약
status: active
last_verified: 2026-06-14
tags:
- wiki
- reference
authority: canonical
---

# Module Hierarchy

이 문서는 아키텍처 원칙이 적용되는 실제 모듈과 폴더 위치, 파일의 표준 배치를 설명합니다. 레이어 책임, 의존 방향, MVI처럼 구현할 때 지켜야 할 기준은 [아키텍처 원칙](architecture.md)을 따릅니다.

## 최상위 구조

| 경로 | 역할 |
|------|------|
| `app/` | 앱 진입점, 앱 조립 |
| `feature/` | Screen, ViewModel, contract, navigation |
| `domain/` | 모델, UseCase, Repository interface |
| `data/` | Domain Repository 구현, network/local 호출 조합 |
| `core/` | 네트워크, 알림, UI 등 공통 인프라 |

## 구현 순서

`domain → data → feature(ViewModel/contract) → feature(UI/navigation)`

## 주요 core 모듈

| 모듈 | 역할 |
|------|------|
| `core:ui` | `BaseViewModel`, `DefaultLoadableState`, `ContentLoadableState`, MVI 유틸 |
| `core:design-system` | 공통 Compose UI, 테마, drawable |
| `core:navigation` | `NavGraphContributor`, 라우팅 인프라 |
| `core:result` | `AppResult`, `AppError` |
| `core:network` | Ktor 설정, `safeApiCall`, Service, Request/Response DTO, DTO와 Domain 간 Mapper |
| `core:util` | Event Bus, 공통 유틸 |

## feature 표준 구조

| 위치 | 역할                                |
|------|-----------------------------------|
| `contract/` | `UiState`, `Intent`, `SideEffect` |
| `component/` | 재사용 가능한, 파일 분리를 위한 Composable     |
| `navigation/` | `NavGraphContributor` 구현          |
| `di/` | feature용 Koin module              |
| `*ViewModel.kt` | Presentation                      |
| `*Screen.kt` or `*Route.kt` | Route + UI                        |

## feature 작성 규칙

- `Route`와 `Screen` 분리 선호
- `Route`는 DI, navigation, side effect 처리
- `Screen`은 pure UI
- ViewModel은 `BaseViewModel` 패턴 준수
- contract 파일은 feature별로 분리

## domain / data / network 규칙

### 기본 원칙

| 영역 | 포함 |
|------|------|
| `domain/{feature}` | `model/`, `repository/`, `usecase/` |
| `data/src/main/java/com/twix/data/repository/` | Domain Repository 구현과 network/local 호출 조합 |
| `core/network/src/main/java/com/twix/network/service/` | API Service |
| `core/network/src/main/java/com/twix/network/model/request/` | Request DTO와 Domain → DTO Mapper |
| `core/network/src/main/java/com/twix/network/model/response/` | Response DTO와 DTO → Domain Mapper |

### 허용 조건

Data는 여러 통신·저장소 호출을 하나의 Domain Repository 동작으로 조합할 수 있지만, 서버 요청·응답 형식이나 DTO Mapper를 새로 소유하지 않습니다. 로컬 저장 전용 모델과 변환은 해당 로컬 인프라 모듈의 책임에 따라 배치합니다.

### 대표 예시

- `DefaultGoalRepository`는 `GoalService` 호출과 `safeApiCall`을 조합해 `GoalRepository`를 구현합니다.
- `GoalService`, 목표 Request/Response DTO, 목표 DTO와 Domain 간 Mapper는 `core:network`에 둡니다.

## 의존 규칙

아래 항목은 모듈 배치를 판단하기 위한 요약입니다. 자세한 책임과 의존 원칙은 [아키텍처 원칙](architecture.md)을 기준으로 합니다.

- `feature`는 `domain`에 의존 가능
- `data`는 `domain` 계약을 구현하고 `core:network` 호출을 조합
- `core:network`는 Service, Request/Response DTO, DTO와 Domain 간 Mapper 소유
- `domain`은 Android / Compose 의존성 금지
- 공통 인프라는 `core`에 둠

## 빠른 판단 기준

| 추가하려는 것 | 위치 |
|------|------|
| 새 화면 상태 | `feature/{name}/contract` |
| 새 화면 로직 | `feature/{name}/*ViewModel.kt` |
| 새 공통 UI | `core:design-system` 또는 `feature/{name}/component` |
| 새 비즈니스 규칙 | `domain/{feature}/usecase` |
| 새 API Service | `core/network/.../service` |
| 새 Request/Response DTO | `core/network/.../model/request` 또는 `model/response` |
| 새 DTO와 Domain 간 매핑 | 해당 DTO와 가까운 `core/network/.../mapper` |
| 새 Repository 구현·호출 조합 | `data/.../repository` |

## 참고 문서

| 문서 | 파일 |
|------|------|
| 프로젝트 개요 | `wiki/reference/project-overview.md` |
| 아키텍처 원칙 | `wiki/reference/architecture.md` |
| 코드 컨벤션 적용 | `.agents/skills/apply-coding-conventions/SKILL.md` |
| 로딩 UI 상태 모델링 | `.agents/skills/model-loadable-ui-state/SKILL.md` |
