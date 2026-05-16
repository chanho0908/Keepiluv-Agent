---
name: hierarchy
description: 모듈 구조와 feature 표준 형태 요약
---

# Module Hierarchy

## 최상위 구조

| 경로 | 역할 |
|------|------|
| `app/` | 앱 진입점, 앱 조립 |
| `feature/` | Screen, ViewModel, contract, navigation |
| `domain/` | 모델, UseCase, Repository interface |
| `data/` | Repository 구현, remote/local, mapper |
| `core/` | 공통 인프라 |

## 구현 순서

`domain → data → feature(ViewModel/contract) → feature(UI/navigation)`

## 주요 core 모듈

| 모듈 | 역할 |
|------|------|
| `core:ui` | `BaseViewModel`, `LoadableState`, MVI 유틸 |
| `core:design-system` | 공통 Compose UI, 테마, drawable |
| `core:navigation` | `NavGraphContributor`, 라우팅 인프라 |
| `core:result` | `AppResult`, `AppError` |
| `core:network` | Ktor 설정, `safeApiCall` |
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

## domain / data 규칙

| 영역 | 포함 |
|------|------|
| `domain/{feature}` | `model/`, `repository/`, `usecase/` |
| `data/{feature}` | `repository/`, `remote/`, `local/`, `mapper/` |

## 의존 규칙

- `feature`는 `domain`에 의존 가능
- `data`는 `domain` 계약 구현
- `domain`은 Android / Compose 의존성 금지
- 공통 인프라는 `core`에 둠

## 빠른 판단 기준

| 추가하려는 것 | 위치 |
|------|------|
| 새 화면 상태 | `feature/{name}/contract` |
| 새 화면 로직 | `feature/{name}/*ViewModel.kt` |
| 새 공통 UI | `core:design-system` 또는 `feature/{name}/component` |
| 새 비즈니스 규칙 | `domain/{feature}/usecase` |
| 새 API 연동 | `data/{feature}/remote` + `repository` |
| 새 매핑 | `data/{feature}/mapper` |

## 참고 문서

| 문서 | 파일 |
|------|------|
| 프로젝트 개요 | `.codex/docs/project-overview.md` |
| 아키텍처 원칙 | `.codex/docs/architecture.md` |
| 코드 컨벤션 | `.codex/skills/coding-conventions.md` |
