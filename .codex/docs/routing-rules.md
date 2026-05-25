---
name: routing-rules
description: Agent 자동 라우팅 규칙 요약
---

# Agent Routing Rules

Codex는 직접 구현하지 않고, 요청을 적절한 agent로 라우팅합니다.

이 문서는 **라우팅 판단 기준**을 설명하는 요약본입니다.
- 최상위 정책 요약: `AGENTS.md`
- 실제 agent별 모델/도구/세부 동작: `.codex/agents/**`

## 핵심 원칙

- 키워드보다 **사용자 의도**를 우선 해석
- 구현 전: 필요한 경우 탐색, 분석, 계획을 먼저 수행
- 가능하면 **구현 전에 테스트를 먼저 설계/작성**하여 성공 기준을 고정
- 구현 후: 사용자 승인 전 커밋 금지
- 단일 작업은 단일 owner agent에 위임
- 독립적인 여러 작업만 병렬 위임
- 실제 모델/도구 정보는 각 agent 파일이 source of truth

## Tier 요약

| Tier | 목적 | 대표 agent |
|------|------|------------|
| 1 | 빠른 탐색, 문서 | `explore`, `writer` |
| 2 | 구현, 테스트, 리뷰, 설계 | `implementer`, `tester`, `planner`, `analyst`, `code-reviewer` |

## 1차 라우팅 표

| 요청 유형 | 라우팅 |
|------|------|
| 파일 찾기, 코드 검색, 사용처 추적 | `explore` |
| README, 가이드, CHANGELOG 작성 | `writer` |
| 기능 구현, 수정, 리팩토링 | `implementer` |
| 테스트 작성, 회귀 테스트 추가 | `tester` |
| 코드 리뷰, Dove Letter 리뷰 | `code-reviewer` |
| 구조 분석, 의존성 분석, 문제점 도출 | `analyst` |
| 구현 계획 수립, 작업 분해 | `planner` |
| 커밋 생성 | `committer` |
| PR 생성 | `pr-creator` |
| 성능 최적화, 리컴포지션 분석 | `performance-optimizer` |
| 회고, 작업 일기, 스킬 추출 | `retrospective` |

## 라우팅 우선순위

1. 명시적 요청
2. 사용자 의도
3. 작업 수
4. 모호성 여부

### 1. 명시적 요청 우선

- `"리뷰해줘"` → `code-reviewer`
- `"계획 세워줘"` → `planner`
- `"테스트 추가해줘"` → `tester`

### 2. 사용자 의도로 판단

| 사용자 의도 | 라우팅 |
|------|------|
| 위치, 사용처, 패턴 찾기 | `explore` |
| 구조 해석, 설계 판단, 문제 진단 | `analyst` |
| 구현 순서, 영향 범위, 작업 분해 | `planner` |
| 실제 코드 변경 | `implementer` |
| 회귀 방지용 테스트 추가 | `tester` |

### 3. 작업 수로 판단

| 조건 | 라우팅 |
|------|------|
| 단일 구현 작업 | `implementer` |
| 구현 + 후속 커밋 | `implementer` → `committer` |
| 계획 후 테스트 선행 구현 | `planner` → `tester` → `implementer` |
| 독립적인 복수 구현 | Team Lead 성격으로 분할 후 병렬 위임 |

### 4. 모호하면 범위부터 명확화

예:

| 모호한 요청 | 먼저 확인할 것 |
|------|------|
| `"UI 개선해줘"` | 화면 수, 범위, 계획 선행 여부 |
| `"분석해줘"` | 단순 검색인지 구조 분석인지 |
| `"리팩토링해줘"` | 대상 feature 수, 동시 작업 가능 여부 |

## 대표 패턴

### 단일 구현

`implementer`

조건:
- 기능 1개
- 체크리스트 1개
- 후속 작업이 있어도 본체는 하나
- 수정 범위가 작고 영향이 명확하면 `planner` 생략 가능

예:
- `"Goal 삭제 기능 구현해줘"`
- `"Notification 로딩 처리 추가해줘"`

### 구현 후 커밋

`implementer` → `committer`

예:
- `"Goal 삭제 기능 구현하고 커밋해줘"`

### 계획 후 구현

`planner` → `tester` → `implementer`

예:
- `"Photolog 필터 기능 어떻게 구현할지 계획 세우고 구현해줘"`

권장:
- 화면, 상태, 네비게이션, 데이터 흐름이 함께 바뀌는 작업
- 파일 여러 개를 건드리는 작업
- 영향 범위가 불명확한 작업

### 탐색 후 구현

`explore` → `tester` → `implementer`

예:
- `"LoadableState 안 쓰는 ViewModel 찾아서 고쳐줘"`

### 분석 후 계획 후 구현

`analyst` → `planner` → `tester` → `implementer`

예:
- `"현재 navigation 구조 문제 분석하고 개선 계획 세운 뒤 리팩토링해줘"`

### 테스트 선행 구현

`tester` → `implementer`

원칙:
- 재현 가능한 버그는 먼저 실패 테스트로 고정
- 새 기능은 가능하면 기대 동작을 테스트로 먼저 명세
- 테스트 작성이 불가능하거나 비용이 과도한 경우에만 예외적으로 구현 선행

예:
- `"로그인 빈 비밀번호 버그 고쳐줘"`
- `"새 UseCase 추가하고 테스트까지 맞춰줘"`

### 구현 후 리뷰

`implementer` → `code-reviewer`

예:
- `"다이얼로그 추가하고 doveletter 리뷰해줘"`

### 복수 독립 작업

조건:
- 체크리스트 2개 이상
- 서로 다른 파일/기능에서 독립 구현 가능

예:
- `"A, B, C 구현해줘"`
- `"Settings, Notification, Stats 화면 각각 로딩 처리 적용해줘"`

규칙:
- 가능한 경우 병렬 구현
- 같은 파일을 건드리면 순차 처리
- 통합 보고 후 사용자 승인
- 승인 후 `committer`

## "분석" 키워드 해석 규칙

| 요청 | 라우팅 |
|------|------|
| 파일/코드 찾기 중심 분석 | `explore` |
| 구조/설계/의존성 중심 분석 | `analyst` |
| 구현 계획 목적의 분석 | `planner` |

예:
- `"GoalRepository 찾아줘"` → `explore`
- `"goal-manage 구조 분석해줘"` → `analyst`
- `"이 기능 어떻게 구현할지 분석해줘"` → `planner`

## 커밋 규칙

- 커밋은 항상 마지막 단계
- 사용자 승인 전 커밋 금지
- 사용자 승인 전 `git add` 금지
- committer는 변경 파일 목록과 커밋 메시지 후보를 먼저 보고한다
- 구현과 커밋은 별도 agent로 분리

## PR 규칙

- PR 생성 전 현재 브랜치, base 브랜치, push 필요 여부, PR 제목/본문 초안을 먼저 보고한다
- 사용자 승인 전 `git push`와 `gh pr create` 금지
- UI 변경이 있으면 결과물 첨부 필요 여부를 확인한다

## 브랜치/이슈 규칙

- 메인 브랜치(`main`, `master`, `develop`)에서는 직접 구현/커밋하지 않는다
- 기존 작업 브랜치가 있으면 재사용 가능
- 작업 브랜치 prefix는 `feature/`, `refactor/`, `fix/`, `chore/`, `docs/`, `test/`, `codex/`를 허용한다
- 새 이슈/새 브랜치 생성은 다음 경우에 권장된다:
  - 새 기능
  - 독립적인 리팩토링
  - 추적 가능한 작업 단위가 필요한 경우
- 파일 1~2개 수준의 작은 수정은 기존 작업 브랜치에서 진행 가능

## Handoff 규칙

- planner는 `handoff_to_tester`와 `handoff_to_implementer`를 계획에 포함한다
- tester는 작성/수정 테스트 파일, 실행 명령, 기대 실패 이유, 구현 메모를 implementer에게 전달한다
- implementer는 전달받은 테스트 명세를 먼저 실행하거나 확인한 뒤 구현한다

## 회고 규칙

- 회고는 자동으로 시작하지 않는다
- 사용자가 `"회고해줘"` 처럼 명시적으로 요청한 경우에만 `retrospective`로 라우팅한다
- `retrospective`가 시작되면 다음 후속 작업은 자동으로 포함한다
  - 회고 정리
  - `.codex/diary/YYYY-MM-DD-{task-name}.md` 기록
  - 필요한 경우 `.codex/skills/`에 규칙/패턴 추출
- 즉, **회고 시작은 수동, 회고 이후 기록과 학습 추출은 자동**으로 처리한다

## 빠른 선택 가이드

| 상황 | 선택 |
|------|------|
| 어디 있는지 모르겠다 | `explore` |
| 구조가 맞는지 모르겠다 | `analyst` |
| 어떻게 구현할지 모르겠다 | `planner` |
| 바로 고칠 수 있다 | `implementer` |
| 테스트가 먼저 필요하다 | `tester` |
| 품질 확인이 필요하다 | `code-reviewer` |
| Git 마무리가 필요하다 | `committer`, `pr-creator` |

## 참고 문서

| 문서 | 파일 |
|------|------|
| 에이전트 목록 | `.codex/docs/agent-list.md` |
| 워크플로우 | `.codex/docs/workflows.md` |
| 프로젝트 개요 | `.codex/docs/project-overview.md` |
