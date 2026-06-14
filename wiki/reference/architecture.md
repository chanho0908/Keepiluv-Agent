---
name: architecture
description: MVI + Clean Architecture 핵심 원칙 요약
status: active
last_verified: 2026-06-15
tags:
- wiki
- reference
authority: canonical
---

# Architecture Principles

이 문서는 레이어 책임, 의존 방향, MVI처럼 구현할 때 지켜야 할 원칙을 설명합니다. 실제 모듈과 폴더 위치, 파일의 표준 배치는 [모듈 구조](module-hierarchy.md)를 기준으로 확인합니다.

아래 위치 표기는 원칙을 이해하기 위한 대표 예시이며, 구체적인 배치 기준은 모듈 구조 문서가 우선합니다.

## 레이어

| Layer | 위치 | 책임 | 금지 |
|------|------|------|------|
| UI | `feature/*Screen`, `feature/component` | Composable, 포맷팅, 사용자 인터랙션 | 비즈니스 로직 누적 |
| Presentation | `feature/*ViewModel`, `contract` | 상태 관리, Intent 처리, SideEffect 발행 | Android UI 직접 렌더링 |
| Domain | `domain/` | 도메인 모델, UseCase, Repository interface | Android, Compose, 포맷팅 |
| Data | `data/` | Domain Repository 구현, 네트워크 호출 조합 | UI 상태 관리, DTO 소유 |
| Network | `core:network` | Request/Response DTO, Service, DTO와 Domain 간 Mapper | 화면 상태 관리, Repository 구현 |

## 의존 방향

`UI → Presentation → Domain`

`Data → Domain`, `Data → Network → Domain`

규칙:
- 상위 레이어 역의존 금지
- Domain은 pure Kotlin 유지
- Data는 Domain 계약을 구현
- Network는 서버 통신 형식과 Domain 변환을 소유하고, Data는 이를 조합해 Repository 계약을 구현

## MVI 규칙

### 현재 사실

현재 화면 계약의 Intent와 SideEffect는 대부분 `sealed interface`입니다. 이벤트 입력이 없는 Splash는 공통 최소 계약인 `EmptyIntent`를 사용하며, 화면 상태도 `EmptyState`를 사용합니다. 현재 확인된 SideEffect 계약은 발생 가능한 일회성 이벤트를 `sealed interface`로 열거합니다.

### 목표 규칙

| 요소 | 규칙 |
|------|------|
| `UiState` | 기본적으로 immutable data class, 상태가 없는 화면은 최소 계약 허용 |
| `Intent` | 기본적으로 sealed interface, 이벤트가 없는 단순 계약은 최소 계약 허용 |
| `SideEffect` | one-time event, 기본적으로 sealed interface, 확장 가능성이 없는 단순 계약은 최소 계약 허용 |
| `ViewModel` | intent 처리, state 업데이트, side effect 발행 |

## 상태 처리

### 기본 원칙

서버 데이터를 표시하는 화면은 공통 로딩 상태 계약을 사용합니다. 비동기 요청의 로딩과 오류만 필요하면 `DefaultLoadableState`, 처음 불러온 뒤 기존 콘텐츠를 유지해야 하면 `ContentLoadableState`를 사용합니다. 서버나 네트워크 실패는 `AppError`로 표현하고, UI는 상태의 파생 규칙을 렌더링합니다.

### 허용 조건

화면 상태가 매우 단순하거나 카메라처럼 기기 기능이 중심이어서 공통 로딩 상태 계약이 화면 의미를 더 잘 설명하지 못할 때는 목적에 맞는 최소 상태 계약을 허용합니다. 이 허용은 공통 계약을 피하기 위한 일반 예외가 아니며, 서버 데이터를 로딩·오류·기존 콘텐츠로 나누어 보여주는 화면에는 적용하지 않습니다.

### 대표 예시

- 로그인처럼 비동기 요청의 로딩과 오류만 관리하는 화면은 `DefaultLoadableState`를 사용합니다.
- 홈이나 알림처럼 초기 로딩 뒤 기존 콘텐츠를 유지하는 화면은 `ContentLoadableState`를 사용합니다.
- Splash는 표시할 화면 상태가 없어 `EmptyState`와 `EmptyIntent`를 사용합니다.
- 인증샷 촬영은 카메라와 촬영 상태가 중심이므로 목적별 필드로 구성한 최소 `State`를 사용합니다.

## 역할 경계

| 항목 | 책임 |
|------|------|
| 문자열 포맷팅 | UI |
| 화면 요청의 Repository 호출 | Presentation |
| UI 상태와 무관한 앱 인프라 Repository 호출 | 제한된 Core 인프라 |
| 비즈니스 규칙 | Domain |
| Request/Response DTO와 DTO ↔ Domain 매핑 | Network (`core:network`) |

## Repository 호출 원칙

### 기본 원칙

화면에서 시작되어 로딩, 오류, 콘텐츠 또는 SideEffect에 영향을 주는 요청은 Presentation의 ViewModel이 Repository를 호출합니다.

### 허용 조건

UI 상태와 생명주기에 속하지 않고 앱 전체에서 동작해야 하는 인프라 작업만 Core에서 Repository를 직접 호출할 수 있습니다. 호출 위치는 해당 인프라 책임을 가진 Core 컴포넌트로 제한하며, 화면 로직이나 일반 비즈니스 흐름을 Core로 옮기는 근거로 사용하지 않습니다.

### 대표 예시

- 화면 목록 조회, 저장, 삭제, 재시도는 ViewModel이 담당합니다.
- 알림 토큰 등록과 해제는 `core:notification`의 토큰 등록 컴포넌트가 담당할 수 있습니다.
- 알림을 눌렀을 때 읽음 처리와 라우팅을 함께 수행하는 작업은 `core:notification`의 라우터가 담당할 수 있습니다.

## 용어 구분

| 용어 | 의미 |
|------|------|
| UI Layer | `feature` 안의 실제 Screen / Component |
| UI 모듈 | 공통 UI 인프라 모듈 (`core:ui`) |

## 구현 체크리스트

- 새 기능이 Domain 변경을 필요로 하는가
- UiState / Intent / SideEffect가 맞게 분리되었는가
- 포맷팅이 UI에 남아 있는가
- Request/Response DTO와 Mapper가 `core:network`에 머물고, Data는 Repository 구현과 호출 조합에 집중하는가

## MVI 상태 모델링과 협업 원칙

사용자 액션은 Intent를 통해 ViewModel에 전달합니다. 재시도처럼 단순해 보이는 동작도 화면이 ViewModel 메서드를 직접 호출하지 않고 Intent 계약을 따라야 합니다.

로딩, 성공, 실패는 `DefaultLoadableState`와 `ContentLoadableState`로 구성된 공통 로딩 상태 계약을 기준으로 사용합니다. `isLoading`, `error`, `hasLoadedContent`로 계산할 수 있는 초기 로딩 여부를 별도 값으로 다시 저장하면 같은 사실이 여러 곳에 저장되어 서로 어긋날 수 있습니다. 화면에 필요한 `showLoading`, `showError`, `showOverlayLoading`은 `UiState`의 파생 규칙으로 둡니다.

상태와 Intent 이름은 사용자 행위를 설명하는 공식 도메인 용어를 사용합니다. 같은 `selectedDate`도 화면에 따라 목표 날짜 또는 통계 조회 기준 월일 수 있으므로 코드 식별자만 보고 의미를 정하지 않습니다.

구현 전에 다음을 확인합니다.

- 이 값은 Domain 규칙인가, 화면 표시 규칙인가
- 사용자 액션이 Intent를 우회하고 있지 않은가
- 기존 상태에서 계산할 수 있는 값을 다시 저장하고 있지 않은가
- 표시 조건의 의미가 Screen 조건문에 흩어져 있지 않은가
- 공식 용어와 프로젝트의 기존 패턴을 사용하고 있는가

## 참고 문서

| 문서 | 파일 |
|------|------|
| 프로젝트 개요 | `wiki/reference/project-overview.md` |
| 모듈 구조 | `wiki/reference/module-hierarchy.md` |
| 코드 컨벤션 적용 | `.agents/skills/apply-coding-conventions/SKILL.md` |
| 로딩 UI 상태 모델링 | `.agents/skills/model-loadable-ui-state/SKILL.md` |
