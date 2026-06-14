---
name: project-overview
description: Keepiluv (Twix) 핵심 스택과 자주 쓰는 패턴 요약
status: active
sources:
- repo:chanho0908/Keepiluv-Agent@14c17aa834575a9422d5e4b33c1191285c575e02:.codex/docs/project-overview.md
last_verified: 2026-06-13
tags:
- wiki
- reference
authority: canonical
---

# Project Overview

## 서비스 개요

Keepiluv는 커플이 함께 목표를 만들고, 날짜별로 목표를 인증하며, 서로의 인증샷에 반응하거나 아직 인증하지 않은 상대를 찔러 참여를 독려하는 서비스입니다.
목표 수행 기록은 스탬프와 통계로 확인할 수 있습니다.

주요 사용자 흐름은 다음과 같습니다.

1. 로그인 후 짝꿍과 연결한다.
2. 프로필과 기념일을 설정한다.
3. 함께 수행할 목표와 반복 주기를 만든다.
4. 날짜를 선택해 그날의 목표를 확인한다.
5. 목표 수행 후 인증샷을 등록한다.
6. 짝꿍의 인증샷에 리액션을 남기거나, 미인증 상태라면 찌르기를 보낸다.
7. 날짜와 목표별 달성 기록을 통계에서 확인한다.

## 핵심 스택

| 영역 | 선택 |
|------|------|
| UI | Jetpack Compose |
| Architecture | MVI + Clean Architecture |
| DI | Koin |
| Network | Ktor Client |
| Async | Coroutines + Flow |
| Result | `AppResult`, `AppError` |
| UI State | `LoadableState` |
| Navigation | Compose Navigation + `NavGraphContributor` |
| Test | JUnit, Kotest, Turbine, Fake Repository |
| Lint | ktlint |

## 자주 쓰는 패턴

| 패턴 | 규칙                                           |
|------|----------------------------------------------|
| Repository | 인터페이스는 `domain`, 구현은 `data`                  |
| Mapper | DTO → Domain 변환은 `.toDomain()` 계열로 분리        |
| Error Handling | `safeApiCall` → `AppResult` → `LoadableState` |
| Testing | `Mock 지양`, `Fake*Repository` 우선              |
| Navigation | feature별 `NavGraphContributor` 사용            |
| Deep Link | launch source / handler 분리                   |
| Cross-Feature Sync | Event Bus 사용 가능                              |
| Route Design | type-safe route 선호                           |

## 자주 보는 위치

| 목적 | 위치 |
|------|------|
| 전체 아키텍처 원칙 | `wiki/reference/architecture.md` |
| 모듈 / 디렉터리 구조 | `wiki/reference/module-hierarchy.md` |
| 테스트 전략 / 레벨 선택 | `wiki/reference/test-strategy.md` |
| 라우팅 / 에이전트 선택 | `wiki/operations/routing-rules.md` |
| 복합 작업 흐름 | `wiki/operations/workflows.md` |
| 코드 컨벤션 적용 | `.agents/skills/apply-coding-conventions/SKILL.md` |
| 로딩·오류 UI 상태 모델링 | `.agents/skills/model-loadable-ui-state/SKILL.md` |
