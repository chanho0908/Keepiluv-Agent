---
name: agent-list
description: 모든 Agent의 파일 위치와 역할 요약
---

# Agent List

Keepiluv (Twix) 프로젝트의 Agent 인덱스입니다.

`Agent List.md`는 탐색용 요약만 제공합니다. 실제 모델, 도구, 세부 동작의 기준 정보는 각 agent 파일입니다.

---

## Tier 1 - 경량 탐색 / 문서

| Agent | 역할 | 파일 |
|------|------|------|
| `explore` | 코드베이스 탐색, 파일 위치 검색, 코드 패턴 분석, 의존성 추적 | `.codex/agents/tier1/explore.md` |
| `writer` | 프로젝트 문서 작성, 가이드 문서 작성, 마크다운 파일 관리 | `.codex/agents/tier1/writer.md` |

---

## Tier 2 - 구현 / 분석 / 검증

| Agent | 역할 | 파일 |
|------|------|------|
| `implementer` | 실제 코드 구현, 브랜치 검증 및 생성, ktlint 검증 | `.codex/agents/tier2/implementer.md` |
| `committer` | Git 커밋 생성, 커밋 메시지 작성, 커밋 전 검증 처리 | `.codex/agents/tier2/committer.md` |
| `pr-creator` | Pull Request 생성, PR 본문 작성, 브랜치 푸시 | `.codex/agents/tier2/pr-creator.md` |
| `tester` | 단위 테스트 작성, ViewModel/Repository/Domain 테스트, 테스트 패턴 정리 | `.codex/agents/tier2/tester.md` |
| `performance-optimizer` | Compose 리컴포지션 최적화, 메모리 누수 탐지, 렌더링 성능 개선, 벤치마크 작성 | `.codex/agents/tier2/performance-optimizer.md` |
| `retrospective` | 작업 회고 작성, 시행착오 분석, 스킬 자동 추출, 에이전트 문서 개선 제안 | `.codex/agents/tier2/retrospective.md` |
| `code-reviewer` | Dove Letter 기반 전문 코드 리뷰, Compose 내부 동작 분석, 아키텍처 위반 탐지, 성능 이슈 확인 | `.codex/agents/tier2/code-reviewer.md` |
| `analyst` | 전체 프로젝트 구조 분석, 아키텍처 패턴 평가, 의존성 분석, 문제점 도출 | `.codex/agents/tier2/analyst.md` |
| `planner` | 구현 계획 수립, 작업 분해, 영향 범위 분석, 리스크 평가 | `.codex/agents/tier2/planner.md` |

---

## 참고 문서

| 문서 | 파일 |
|------|------|
| 라우팅 규칙 | `.codex/docs/routing-rules.md` |
| 워크플로우 | `.codex/docs/workflows.md` |
| 프로젝트 개요 | `.codex/docs/project-overview.md` |
