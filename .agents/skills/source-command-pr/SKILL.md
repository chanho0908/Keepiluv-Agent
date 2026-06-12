---
name: source-command-pr
description: 현재 브랜치와 변경 내용을 분석해 Pull Request 제목과 본문을 준비하고, 사용자 확인 후에만 push와 PR 생성을 수행하는 절차. 사용자가 `/pr`, "PR 만들어줘", "Pull Request 생성"을 요청할 때 사용한다.
---

# source-command-pr

pr-creator 에이전트를 사용하여 Pull Request 초안을 작성하고, 사용자 확인 후 push 및 PR 생성을 수행한다.

Codex의 에이전트 위임 기능을 사용하여 pr-creator 역할 에이전트를 호출하세요.

## 확인 전

pr-creator는 다음을 수행한다.

1. 현재 브랜치 상태 확인
2. base 브랜치 대비 변경사항 분석
3. 커밋 메시지 패턴 분석
4. .github/PULL_REQUEST_TEMPLATE.md 템플릿에 맞춰 PR 본문 작성
5. push 필요 여부, PR 제목 후보, 본문 초안, 이슈 번호, UI 결과물 필요 여부 제시
6. 사용자 승인 대기

push 또는 PR 생성을 실행하지 않고 사용자 확인을 기다린다.

## 확인 후

사용자가 확인한 후에만 다음을 수행한다.

1. 필요한 경우 git push
2. gh pr create로 PR 생성

## PR 생성 규칙

- 제목에 이모지 금지 (✨, ♻️ 등)
- 간결하고 명확한 제목
- 템플릿 형식 준수
- Codex 서명 금지
- base 브랜치 기본값: develop

## 금지 사항

사용자 확인 전에는 다음 명령을 실행하지 않는다.

- `git push`
- `gh pr create`
