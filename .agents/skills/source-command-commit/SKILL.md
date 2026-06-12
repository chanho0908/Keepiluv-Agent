---
name: source-command-commit
description: 변경 파일과 기존 커밋 형식을 분석해 stage 대상과 한글 커밋 메시지를 제안하고, 사용자 승인 후에만 커밋하는 절차. 사용자가 `/commit`, "커밋해줘", "변경사항 커밋"처럼 Git 커밋 생성을 요청할 때 사용한다.
---

# source-command-commit

committer 에이전트를 사용하여 변경사항을 분석하고, 사용자 승인 후 커밋한다.

Codex의 에이전트 위임 기능을 사용하여 committer 역할 에이전트를 호출하세요.

## 승인 전

committer는 다음을 수행한다.

1. git status, git diff로 변경사항 분석
2. git log로 기존 커밋 패턴 확인
3. 프로젝트 커밋 규칙에 맞는 메시지 작성
4. stage 대상 파일과 커밋 메시지 후보 제시
5. 사용자 승인 대기

stage 또는 commit을 실행하지 않고 사용자 승인을 기다린다.

## 승인 후

사용자가 승인한 후에만 다음을 수행한다.

1. 승인된 파일만 git add
2. 승인된 메시지로 git commit

## 커밋 규칙

- {emoji} {Type}: {제목} 형식
- 한 줄만 작성 (본문 없음)
- Codex 서명 금지
- 한글로 작성

## 금지 사항

사용자 승인 전에는 다음 명령을 실행하지 않는다.

- `git add`
- `git commit`
- `git commit --amend`
