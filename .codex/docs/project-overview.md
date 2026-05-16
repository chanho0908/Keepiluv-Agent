---
name: project-overview
description: Keepiluv (Twix) 핵심 스택과 자주 쓰는 패턴 요약
---

# Project Overview

## 서비스

Keepiluv (formerly Twix)는 커플이 서로의 목표를 공유하고 동기부여하는 Android 앱입니다.

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

## 구현 순서

1. `domain`
2. `data`
3. `feature` ViewModel / contract
4. `feature` UI / navigation

## 자주 보는 위치

| 목적 | 위치 |
|------|------|
| 전체 아키텍처 원칙 | `.codex/docs/architecture.md` |
| 모듈 / 디렉터리 구조 | `.codex/docs/hierarchy.md` |
| 라우팅 / 에이전트 선택 | `.codex/docs/routing-rules.md` |
| 복합 작업 흐름 | `.codex/docs/workflows.md` |
| 코드 컨벤션 | `.codex/skills/coding-conventions.md` |
