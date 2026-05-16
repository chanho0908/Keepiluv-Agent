# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

---

## ⚠️ CRITICAL: Never Work Alone

**Codex는 절대로 혼자서 코드를 작성하지 않습니다.**

모든 작업은 전문화된 Agent에게 위임합니다. 구현 전에 항상 사용자 컨펌을 받고, 커밋은 승인 후에만 실행합니다.

이 문서는 오케스트레이션 정책의 **최상위 요약본**입니다.
- 세부 라우팅 규칙: `.codex/docs/routing-rules.md`
- 복합 워크플로우: `.codex/docs/workflows.md`
- 각 agent의 실제 동작, 모델, 도구 제약: `.codex/agents/**`

정책 충돌 시 우선순위:
1. 사용자 요청
2. 이 문서와 `.codex/docs/`의 오케스트레이션 규칙
3. 각 agent 파일의 세부 지침

---

## 빠른 참조: Tier별 라우팅

| 요청 키워드 | Agent | Tier |
|------------|-------|------|
| "찾아줘", "탐색", "검색" | explore | 1 |
| "문서 작성", "README" | writer | 1 |
| "구현", "만들어", "추가", "수정" | implementer | 2 |
| "커밋" | committer | 2 |
| "PR 생성" | pr-creator | 2 |
| "테스트" | tester | 2 |
| "최적화", "리컴포지션" | performance-optimizer | 2 |
| "회고", "일기" | retrospective | 2 |
| "리뷰", "doveletter" | code-reviewer | 2 |
| "분석", "구조 분석" | analyst | 2 |
| "계획 수립", "어떻게 구현" | planner | 2 |

**상세 라우팅 규칙:** `.codex/docs/routing-rules.md`

**복합 워크플로우 패턴:** `.codex/docs/workflows.md`

---

## 핵심 운영 원칙

### 1. 의도 우선 라우팅

키워드만 보지 말고 **사용자 의도**를 먼저 해석합니다.

- 위치/사용처 확인이 목적이면 `explore`
- 구조 판단/문제 진단이 목적이면 `analyst`
- 구현 순서와 영향 범위 정리가 목적이면 `planner`
- 실제 코드 변경이 목적이면 `implementer`
- 회귀 방지가 목적이면 `tester`
- 품질 검토가 목적이면 `code-reviewer`
- Git 마무리가 목적이면 `committer`, `pr-creator`

키워드는 보조 신호이며, 의도와 충돌하면 의도를 우선합니다.

### 2. 단일 owner 원칙

- 하나의 본작업은 하나의 owner agent가 맡습니다.
- 후속 작업은 별도 agent로 넘깁니다.
- 예: 구현은 `implementer`, 커밋은 `committer`

### 3. 승인 게이트

- 계획이 필요한 작업: `planner` 결과를 먼저 보여주고 승인 후 구현
- 커밋: 항상 사용자 승인 후 실행
- PR 생성: 상태 확인 후 실행

### 4. 병렬 위임 원칙

병렬 실행 가능:
- 서로 다른 feature
- 서로 다른 파일 세트
- 순서 의존성이 없는 작업

병렬 실행 금지:
- 같은 ViewModel, Screen, contract 파일 수정
- 한 작업 결과가 다음 작업 입력인 경우

### 5. 기본 흐름

- 단순 탐색: `explore`
- 빠른 수정: `explore → tester → implementer`
- 일반 기능: `planner → tester → implementer`
- 구조 개선: `analyst → planner → tester → implementer`
- 품질 우선: `planner → tester → implementer → code-reviewer`

### 6. 작은 작업 예외

아주 작은 수정은 불필요한 오버헤드를 줄입니다.

- 기존 작업 브랜치가 있으면 새 이슈/브랜치 생성 없이 진행 가능
- 파일 1~2개 수준의 명확한 수정은 `planner`를 생략할 수 있음
- 단, 커밋 승인 규칙은 항상 유지

---

## Quick Commands

```bash
/commit        # 커밋만 생성
/pr            # PR만 생성
/impl          # 계획 → 승인 → 테스트 → 구현
```

---

## 참고 문서

| 분류 | 문서 | 파일 | 용도 |
|------|------|------|------|
| Core | 프로젝트 개요 | `.codex/docs/project-overview.md` | Keepiluv 소개, Tech Stack, Key Patterns |
| Core | 아키텍처 | `.codex/docs/architecture.md` | MVI, Clean Architecture, 레이어별 책임 |
| Core | 모듈 구조 | `.codex/docs/hierarchy.md` | Layer Hierarchy, Core Modules, Feature Structure |
| Orchestration | 라우팅 규칙 | `.codex/docs/routing-rules.md` | 단일 작업, 여러 작업, Tier별 자동 라우팅 |
| Orchestration | 워크플로우 | `.codex/docs/workflows.md` | 복합 워크플로우 패턴, Tier 조합 전략 |
| Orchestration | 에이전트 목록 | `.codex/docs/agent-list.md` | Agent 인덱스 |
| Guideline | 코드 컨벤션 | `.codex/skills/coding-conventions.md` | SOLID, Koin, 네이밍 규칙, 문자열 관리 |
| Guideline | working fence | `.codex/skills/andrej-karpathy-skills.md` | Think Before Coding, Simplicity First, Surgical Changes |

### Agents

전체 목록: `.codex/docs/agent-list.md`

| Tier | Agent | 역할 | 파일 |
|------|------|------|------|
| 1 | `explore` | 코드베이스 탐색 (READ-ONLY) | `.codex/agents/tier1/explore.md` |
| 1 | `writer` | 문서 작성 | `.codex/agents/tier1/writer.md` |
| 2 | `implementer` | 코드 구현 | `.codex/agents/tier2/implementer.md` |
| 2 | `committer` | Git 커밋 생성 | `.codex/agents/tier2/committer.md` |
| 2 | `pr-creator` | Pull Request 생성 | `.codex/agents/tier2/pr-creator.md` |
| 2 | `tester` | 테스트 코드 작성 | `.codex/agents/tier2/tester.md` |
| 2 | `performance-optimizer` | 성능 최적화 | `.codex/agents/tier2/performance-optimizer.md` |
| 2 | `retrospective` | 작업 회고, 스킬 자동 추출 | `.codex/agents/tier2/retrospective.md` |
| 2 | `code-reviewer` | Dove Letter 기반 코드 리뷰 (READ-ONLY) | `.codex/agents/tier2/code-reviewer.md` |
| 2 | `analyst` | 아키텍처 분석 (READ-ONLY) | `.codex/agents/tier2/analyst.md` |
| 2 | `planner` | 구현 계획 수립 (READ-ONLY) | `.codex/agents/tier2/planner.md` |

### Codex 모델 운영 기준

- **Tier 1 권장**: `gpt-5.4-mini` + `reasoning_effort=low`
- **Tier 2 권장**: `gpt-5.5` 또는 현재 상속 모델 + `reasoning_effort=medium` 이상
- 이 구분은 문서상의 운영 가이드이며, Codex가 tier 이름만 보고 자동으로 모델을 바꾸지는 않습니다.
