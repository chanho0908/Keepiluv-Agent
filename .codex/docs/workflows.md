---
name: workflows
description: 자주 쓰는 agent 조합 워크플로우 요약
---

# Complex Workflows

이 문서는 "어떤 agent를 어떤 순서로 조합할지"를 빠르게 결정하기 위한 요약본입니다.

정책 원본은 `AGENTS.md`와 `.codex/docs/routing-rules.md`를 따릅니다.
테스트 레벨 선택과 완료 기준은 `.codex/docs/test-strategy.md`를 따릅니다.
tester의 구체적인 테스트 작성과 검증 절차는 `.agents/skills/test-workflow/SKILL.md`를 따릅니다.

## 기본 조합

| 이름 | 흐름 | 사용할 때 |
|------|------|-----------|
| 요구사항 인터뷰 후 설계 | `interviewer → planner` | 목표, 범위, 성공 기준이 불명확해 바로 계획하면 추측이 섞일 때 |
| 요구사항 인터뷰 후 테스트 선행 구현 | `interviewer → planner → tester → implementer` | 모호한 기능 요청을 Feature Spec으로 고정한 뒤 구현해야 할 때 |
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

### 1. 모호한 요구사항 정리

`interviewer → planner`

언제:
- 사용자의 요청이 추상적이어서 목표, 범위, 완료 기준이 열려 있을 때
- planner가 계획을 세우려면 중요한 제품/정책 판단을 추측해야 할 때
- "개선", "고도화", "편하게", "정리"처럼 해석 범위가 넓은 표현이 중심일 때

규칙:
- interviewer는 최대 3개 질문으로 Feature Spec만 작성한다
- 구현 계획은 planner가 작성한다
- 질문 없이 합리적으로 판단한 내용은 Feature Spec의 `가정`에 남긴다

### 2. 일반 기능 추가

`planner → tester → implementer`

언제:
- 요구사항은 명확하지만 영향 범위 확인이 필요할 때
- ViewModel, state, navigation, UI를 함께 수정할 때
- 기대 동작을 테스트로 먼저 고정하고 싶을 때

### 3. 빠른 버그 수정

`explore → tester → implementer`

언제:
- 크래시나 단순 회귀를 빨리 잡아야 할 때
- 구조 분석보다 위치 파악이 더 중요할 때
- 실패 조건을 테스트로 먼저 재현할 수 있을 때

단, 테스트 작성이 현실적으로 어렵다면 예외적으로 `implementer → tester`로 축약 가능

### 4. 대규모 리팩토링

`analyst → planner → tester → implementer`

언제:
- 여러 feature나 모듈에 같은 패턴을 적용할 때
- 순서, 영향 범위, 병렬 가능 여부가 중요할 때

### 5. 품질 우선 작업

`planner → tester → implementer → code-reviewer`

언제:
- UI 안정성, Compose 패턴, 아키텍처 준수가 중요할 때

### 6. 문서 기반 작업

`writer → planner → tester → implementer`

언제:
- 먼저 스펙/가이드가 필요할 때
- 문서와 구현을 같이 남겨야 할 때

### 7. 작업 완료 후 회고

`retrospective`

언제:
- 사용자가 `"회고해줘"`, `"retrospective"`, `"작업 일기 남겨줘"`처럼 회고를 명시적으로 요청했을 때

규칙:
- 회고는 자동 시작하지 않는다
- 사용자가 회고를 요청한 시점에만 `retrospective`를 실행한다
- `retrospective`가 시작되면 이후 과정은 자동으로 수행한다:
  1. 회고 내용 정리
  2. `.codex/diary/YYYY-MM-DD-{task-name}.md` 기록
  3. 반복 절차와 사용 시점이 모두 명확할 때만 `.agents/skills/<name>/SKILL.md` 생성 또는 갱신
  4. 기존 Skill의 상세 규칙은 해당 `references/`, 공식 사실과 정책은 `.codex/docs/`에 반영

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
| 의도 우선 | `interviewer → planner → tester → implementer` | 모호한 요청을 Feature Spec으로 먼저 고정 |
| 품질 우선 | `analyst/planner → tester → implementer → code-reviewer` | 느리지만 안정적 |

## 작업 유형별 추천

| 작업 | 추천 흐름 |
|------|-----------|
| 모호한 기능 요청 정리 | `interviewer → planner` |
| 파일 위치 찾기 후 수정 | `explore → tester → implementer` |
| 구조 문제 찾고 개선 | `analyst → planner → tester → implementer` |
| 새 화면 추가 | `planner → tester → implementer` |
| Compose 품질 확인 | `tester → implementer → code-reviewer` |
| 긴급 버그 수정 | `explore → tester → implementer` |
| PR까지 마무리 | `implementer → committer → pr-creator` |
| 작업 완료 후 회고 요청 | `retrospective` |

## 승인 포인트

- 계획 문서가 필요한 작업: `planner` 뒤 승인
- 요구사항 인터뷰가 필요한 작업: `interviewer`가 Feature Spec을 작성한 뒤 planner로 전달
- 계획 문서는 코드 레벨 설계서가 아니라 승인 가능한 작업 흐름 문서로 작성한다
- 파일명, 함수명, API명은 필요한 경우에만 기술 메모나 handoff 항목으로 분리한다
- 테스트 선행 구현: `planner` 승인 후 `tester → implementer`
- 커밋이 필요한 작업: `committer` 전 승인
- 커밋 승인 범위에는 stage 대상 파일과 커밋 메시지 후보가 포함된다
- PR이 필요한 작업: `pr-creator` 전 상태 확인
- PR 승인 범위에는 push 여부, base 브랜치, 제목, 본문 초안이 포함된다
- 회고는 사용자의 명시적 요청이 있을 때만 시작하고, 시작 후 diary 기록과 필요한 Skill·문서 갱신은 자동 진행

## 실행 단계

이 섹션은 계획 승인 이후 어떤 agent를 어떤 순서로 호출할지 정하는 작업 워크플로우입니다.
`planner`는 이 흐름을 직접 실행하지 않고, 계획서에 추천 후속 흐름과 승인 지점만 남깁니다.

### 0단계: 구현 전 준비 (조건부)

파일을 변경할 수 있는 agent를 호출하기 전에 브랜치 상태를 확인합니다.
브랜치/이슈 정책의 source of truth는 `.codex/docs/routing-rules.md`와 각 Write 가능 agent의 작업 프로세스입니다.

### 1단계: 테스트 선행 구현 (단일 작업)

1. `tester`에게 선행 테스트 작성을 위임한다
   - tester는 `.agents/skills/test-workflow/SKILL.md`에 따라 테스트를 작성, 검증, handoff한다
2. `implementer`에게 테스트를 만족하는 구현을 위임한다
3. 품질 확인이 필요한 경우 `code-reviewer`로 리뷰한다

### 1단계: 테스트 선행 구현 (여러 작업)

1. 병렬 가능한 작업인지 먼저 확인한다
2. 서로 다른 파일/feature라면 가능한 범위에서 `tester`를 병렬 호출한다
   - 각 tester는 `.agents/skills/test-workflow/SKILL.md`의 입력, 출력, 예외 규칙을 따른다
3. 각 테스트 기준이 고정되면 `implementer`로 구현을 위임한다
4. 모든 작업이 합쳐진 뒤 필요 시 `code-reviewer`로 통합 리뷰한다

### 2단계: 커밋 & PR

1. 사용자 승인 후 `committer`로 커밋을 생성한다
2. 사용자 승인 후 `pr-creator`로 Pull Request를 생성한다

## Handoff 표준

| From | To | 전달 내용 |
|------|----|-----------|
| `interviewer` | `planner` | Feature Spec, 목적/범위/제외/완료 기준, 가정, 미해결 질문 |
| `planner` | `tester` | 테스트 파일 후보, 기대 동작/실패 조건, 실행 명령, Mock/Fake 기준 |
| `planner` | `implementer` | 레이어별 변경 범위, 구현 순서, strings/DI/navigation/build 변경, 충돌 위험 |
| `tester` | `implementer` | 작성/수정 테스트 파일, 현재 실패 이유, 통과 조건, 최소 구현 메모 |

## 운영 메모

- 워크플로우는 강제 순서가 아니라 기본값이다
- 작은 작업은 과도한 계획 단계를 줄일 수 있다
- 기본 원칙은 테스트 선행이지만, 테스트 작성이 구조적으로 어렵다면 예외적으로 후행 보강을 허용한다
- 모든 handoff와 산출물은 `.codex/docs/domain-glossary.md`의 공식 용어를 사용한다
- 코드 표현의 의미가 문맥별로 다르면 용어집의 모듈별 매핑을 확인하고, 정의되지 않은 의미는 사용자에게 확인한다

## 참고 문서

| 문서 | 파일 |
|------|------|
| 라우팅 규칙 | `.codex/docs/routing-rules.md` |
| 에이전트 목록 | `.codex/docs/agent-list.md` |
| 프로젝트 개요 | `.codex/docs/project-overview.md` |
| 도메인 용어집 | `.codex/docs/domain-glossary.md` |
| 테스트 전략 | `.codex/docs/test-strategy.md` |
| 테스트 작업 절차 | `.agents/skills/test-workflow/SKILL.md` |
