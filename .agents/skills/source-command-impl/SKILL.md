---
name: "source-command-impl"
description: "계획 수립 후 테스트를 먼저 작성하고 구현합니다"
---

# source-command-impl

Use this skill when the user asks to run the migrated source command `impl`.

## Command Template

다음 순서로 작업을 수행하세요:

## 1단계: 계획 수립
- Codex의 에이전트 위임 기능을 사용하여 planner 역할 에이전트를 호출
- 사용자의 요구사항을 분석하고 상세한 구현 계획을 수립
- 계획에는 다음이 포함되어야 합니다:
    * 변경할 파일 목록
    * 각 파일의 변경 내용
    * 구현 순서
    * 예상되는 영향 범위
    * `handoff_to_tester`
    * `handoff_to_implementer`

## 2단계: 계획 제시 및 승인 대기
- planner 에이전트가 수립한 계획을 사용자에게 명확하게 제시
- 사용자의 승인 또는 수정 요청을 기다림

## 3단계: 테스트 선행 구현 (사용자 승인 후)
- 사용자가 계획을 승인하면:
    * Codex의 에이전트 위임 기능을 사용하여 tester 역할 에이전트를 먼저 호출
    * 1단계에서 수립한 계획을 tester에게 전달하여 실패 테스트 또는 기대 동작 테스트를 먼저 작성
    * 이후 implementer 역할 에이전트를 호출
    * tester가 작성한 테스트와 1단계 계획을 implementer에게 전달
    * implementer가 테스트를 통과하도록 코드를 구현

## 중요 사항
- 각 단계는 순차적으로 진행되어야 합니다
- 2단계에서 사용자 승인 없이 3단계로 넘어가지 마세요
- planner, tester, implementer는 **별도의 에이전트 호출**로 실행하세요
- tester는 작성/수정 테스트 파일, 실행 명령, 기대 실패 이유를 implementer에게 전달해야 합니다

사용자가 요구사항을 제공하면, 위 3단계를 순차적으로 수행하세요.
