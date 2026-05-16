---
name: workflows
description: 자주 쓰는 agent 조합 워크플로우 요약
---

# Complex Workflows

이 문서는 "어떤 agent를 어떤 순서로 조합할지"를 빠르게 결정하기 위한 요약본입니다.

정책 원본은 `AGENTS.md`와 `.codex/docs/routing-rules.md`를 따릅니다.

## 기본 조합

| 이름 | 흐름 | 사용할 때 |
|------|------|-----------|
| 설계 후 테스트 선행 구현 | `planner → tester → implementer` | 구현 전에 파일/레이어 계획과 성공 기준 정리가 필요할 때 |
| 설계 후 테스트 선행 구현 후 리뷰 | `planner → tester → implementer → code-reviewer` | 복잡한 기능, 품질 우선 작업 |
| 탐색 후 테스트 선행 구현 | `explore → tester → implementer` | 위치 파악 후 바로 재현 테스트나 기대 동작 테스트를 먼저 만들 수 있을 때 |
| 탐색 후 분석 후 테스트 선행 구현 | `explore → analyst → tester → implementer` | 기존 구조를 읽고 수정 방향과 실패 조건을 함께 잡아야 할 때 |
| 분석 후 계획 후 테스트 선행 구현 | `analyst → planner → tester → implementer` | 대규모 리팩토링, 구조 개선 |
| 빠른 소규모 수정 | `tester → implementer` | 범위가 작고 테스트로 기대 결과를 먼저 고정할 수 있을 때 |
| 테스트 선행 구현 | `tester → implementer` | TDD 또는 버그 재현 테스트가 먼저 필요할 때 |
| 구현 후 리뷰 | `tester → implementer → code-reviewer` | 구현은 하되 테스트를 먼저 고정하고 품질 검토까지 할 때 |
| 예외적 테스트 후행 보강 | `implementer → tester` | 테스트 작성이 구조적으로 어렵거나 초기 재현이 불가능할 때만 |
| 구현 후 커밋 | `implementer → committer` | 코드 변경 후 승인된 커밋이 필요할 때 |
| 커밋 후 PR | `committer → pr-creator` | Git 마무리 단계 |
| 명시적 회고 후 기록 | `retrospective` | 사용자가 회고를 직접 요청했을 때 |

## 추천 워크플로우

### 1. 일반 기능 추가

`planner → tester → implementer`

언제:
- 요구사항은 명확하지만 영향 범위 확인이 필요할 때
- ViewModel, state, navigation, UI를 함께 수정할 때
- 기대 동작을 테스트로 먼저 고정하고 싶을 때

### 2. 빠른 버그 수정

`explore → tester → implementer`

언제:
- 크래시나 단순 회귀를 빨리 잡아야 할 때
- 구조 분석보다 위치 파악이 더 중요할 때
- 실패 조건을 테스트로 먼저 재현할 수 있을 때

단, 테스트 작성이 현실적으로 어렵다면 예외적으로 `implementer → tester`로 축약 가능

### 3. 대규모 리팩토링

`analyst → planner → tester → implementer`

언제:
- 여러 feature나 모듈에 같은 패턴을 적용할 때
- 순서, 영향 범위, 병렬 가능 여부가 중요할 때

### 4. 품질 우선 작업

`planner → tester → implementer → code-reviewer`

언제:
- UI 안정성, Compose 패턴, 아키텍처 준수가 중요할 때

### 5. 문서 기반 작업

`writer → planner → tester → implementer`

언제:
- 먼저 스펙/가이드가 필요할 때
- 문서와 구현을 같이 남겨야 할 때

### 6. 작업 완료 후 회고

`retrospective`

언제:
- 사용자가 `"회고해줘"`, `"retrospective"`, `"작업 일기 남겨줘"`처럼 회고를 명시적으로 요청했을 때

규칙:
- 회고는 자동 시작하지 않는다
- 사용자가 회고를 요청한 시점에만 `retrospective`를 실행한다
- `retrospective`가 시작되면 이후 과정은 자동으로 수행한다:
  1. 회고 내용 정리
  2. `.codex/diary/YYYY-MM-DD-{task-name}.md` 기록
  3. 반복 학습할 가치가 있는 규칙이 있으면 `.codex/skills/`에 스킬 추출

예:
- `"이번 작업 회고해줘"`

## 병렬 실행 규칙

병렬 실행 가능:
- 서로 다른 feature
- 서로 다른 파일 세트
- 공유 상태나 같은 ViewModel 수정이 없는 경우

병렬 실행 금지:
- 같은 Screen, same ViewModel, same contract 파일
- 구현 순서 의존성이 있는 경우
- 한 결과가 다음 작업의 입력인 경우

## 비용/속도 기준

| 전략 | 흐름 | 특징 |
|------|------|------|
| 비용 우선 | `explore`를 먼저 활용 | 빠르고 저렴, 깊은 판단은 약함 |
| 균형형 | `planner → tester → implementer` | 대부분의 기능 작업에 적합 |
| 품질 우선 | `analyst/planner → tester → implementer → code-reviewer` | 느리지만 안정적 |

## 작업 유형별 추천

| 작업 | 추천 흐름 |
|------|-----------|
| 파일 위치 찾기 후 수정 | `explore → tester → implementer` |
| 구조 문제 찾고 개선 | `analyst → planner → tester → implementer` |
| 새 화면 추가 | `planner → tester → implementer` |
| Compose 품질 확인 | `tester → implementer → code-reviewer` |
| 긴급 버그 수정 | `explore → tester → implementer` |
| PR까지 마무리 | `implementer → committer → pr-creator` |
| 작업 완료 후 회고 요청 | `retrospective` |

## 승인 포인트

- 계획 문서가 필요한 작업: `planner` 뒤 승인
- 커밋이 필요한 작업: `committer` 전 승인
- PR이 필요한 작업: `pr-creator` 전 상태 확인
- 회고는 사용자의 명시적 요청이 있을 때만 시작, 시작 후 diary 기록과 skill 추출은 자동 진행

## 운영 메모

- 워크플로우는 강제 순서가 아니라 기본값이다
- 작은 작업은 과도한 계획 단계를 줄일 수 있다
- 기본 원칙은 테스트 선행이지만, 테스트 작성이 구조적으로 어렵다면 예외적으로 후행 보강을 허용한다

## 참고 문서

| 문서 | 파일 |
|------|------|
| 라우팅 규칙 | `.codex/docs/routing-rules.md` |
| 에이전트 목록 | `.codex/docs/agent-list.md` |
| 프로젝트 개요 | `.codex/docs/project-overview.md` |
