---
name: project-overview
description: Keepiluv (Twix) 서비스 목적, 핵심 스택과 주요 진입점
status: active
last_verified: 2026-06-14
tags:
- wiki
- reference
authority: canonical
---

# Project Overview

## 서비스 개요

Keepiluv는 커플이 함께 목표를 만들고, 목표 날짜별로 인증하며, 서로의 인증샷에 반응하거나 아직 인증하지 않은 짝꿍을 찔러 참여를 독려하는 서비스입니다.
목표 수행 결과는 통계 조회 기준 월의 스탬프 통계와 목표 날짜별 인증 기록으로 확인할 수 있습니다.

주요 사용자 흐름은 다음과 같습니다.

1. 로그인 후 짝꿍과 연결한다.
2. 프로필과 기념일을 설정한다.
3. 함께 수행할 목표와 반복 주기를 만든다.
4. 날짜를 선택해 그날의 목표를 확인한다.
5. 목표 수행 후 인증샷을 등록한다.
6. 짝꿍의 인증샷에 리액션을 남기거나, 미인증 상태라면 찌르기를 보낸다.
7. 통계 조회 기준 월을 선택해 스탬프 통계와 목표 날짜별 인증 기록을 확인한다.

## 핵심 스택

| 영역 | 선택 |
|------|------|
| UI | Jetpack Compose |
| Architecture | MVI + Clean Architecture 기반 구조 |
| DI | Koin |
| Network | Ktor Client + Ktorfit/KSP |
| Async | Coroutines + Flow |
| Result | `AppResult`, `AppError` |
| UI State | 기본 로딩·오류는 `DefaultLoadableState`, 기존 콘텐츠 유지 화면은 `ContentLoadableState` |
| Navigation | Compose Navigation + `NavGraphContributor` |
| Test | JUnit 5, AssertJ, Turbine, coroutines-test/Kotlin Test |
| Lint | ktlint |

## 구조 안내

Repository, Mapper, 상태 처리와 레이어 책임은 [아키텍처 원칙](architecture.md)을 기준으로 확인합니다.
실제 모듈과 feature 배치는 [모듈 구조](module-hierarchy.md)를 따릅니다.
Navigation은 feature별 `NavGraphContributor`로 그래프를 조립하고, 문자열 경로와 인자 이름·경로 생성은 `NavRoutes`에서 중앙 관리합니다.

## 자주 보는 위치

| 목적 | 위치 |
|------|------|
| 앱 진입점과 조립 | `app/src/main/java/com/yapp/twix/` |
| 공통 Navigation 경로와 그래프 조립 | `core/navigation/src/main/java/com/twix/navigation/` |
| 네트워크 클라이언트와 API 서비스 | `core/network/src/main/java/com/twix/network/` |
| 공통 MVI 상태와 ViewModel 기반 코드 | `core/ui/src/main/java/com/twix/ui/base/` |
| 주요 홈·통계 화면 | `feature/main/src/main/java/com/twix/` |
| 전체 아키텍처 원칙 | `wiki/reference/architecture.md` |
| 모듈 / 디렉터리 구조 | `wiki/reference/module-hierarchy.md` |
| 테스트 전략 / 레벨 선택 | `wiki/reference/test-strategy.md` |
| 라우팅 / 에이전트 선택 | `wiki/operations/routing-rules.md` |
| 복합 작업 흐름 | `wiki/operations/workflows.md` |
| 코드 컨벤션 적용 | `.agents/skills/apply-coding-conventions/SKILL.md` |
| 로딩·오류 UI 상태 모델링 | `.agents/skills/model-loadable-ui-state/SKILL.md` |
