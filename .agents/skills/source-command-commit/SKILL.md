---
name: "source-command-commit"
description: "변경사항을 커밋합니다"
---

# source-command-commit

Use this skill when the user asks to run the migrated source command `commit`.

## Command Template

committer 에이전트를 사용하여 변경사항을 분석하고, 사용자 승인 후 커밋합니다.

Codex의 에이전트 위임 기능을 사용하여 committer 역할 에이전트를 호출하세요.

에이전트가 승인 전 자동으로:
1. git status, git diff로 변경사항 분석
2. git log로 기존 커밋 패턴 확인
3. 프로젝트 커밋 규칙에 맞는 메시지 작성
4. stage 대상 파일과 커밋 메시지 후보 제시
5. 사용자 승인 대기

사용자가 승인한 후에만:
1. 승인된 파일만 git add
2. 승인된 메시지로 git commit

커밋 규칙:
- {emoji} {Type}: {제목} 형식
- 한 줄만 작성 (본문 없음)
- Codex 서명 금지
- 한글로 작성

승인 전 금지:
- git add
- git commit
- git commit --amend
