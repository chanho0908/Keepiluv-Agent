---
status: draft
last_verified: 2026-06-14
tags:
- source
authority: canonical
---

# 원본 제목

`wiki/inbox`에 미정리 새 자료를 등록할 때는 아래 frontmatter를 사용합니다. inbox 항목은 공식 지식이 아닙니다.

```yaml
---
type: source
status: pending
created_at: 2026-06-15
updated_at: 2026-06-15
last_verified: 2026-06-15
tags:
  - inbox
  - source
authority: none
---
```

외부 자료를 근거로 새 문서를 만들 때만 아래 예시를 frontmatter에 추가하고 실제 출처와 확인일로 바꿉니다.

```yaml
sources:
  # Twix 같은 외부 저장소의 commit 고정 permalink
  - "url:https://github.com/chanho0908/Twix/blob/0123456789abcdef0123456789abcdef01234567/path/to/source.kt|checked:2026-06-12"

last_verified: 2026-06-12
authority: canonical
```

외부 GitHub URL의 `/blob/` 다음 값은 실제 40자리 commit SHA여야 합니다. `main`, 브랜치명, `HEAD` URL은 사용하지 않습니다.
원본 작업의 PR 번호는 Wiki 출처로 기록하지 않습니다.
외부 근거가 없다면 `sources` 항목 자체를 생략합니다.

## 등록 이유

이 원본을 Wiki에 추가하는 이유를 설명합니다.

## 요약

저작권을 존중해 원문 전체 대신 핵심 내용만 요약합니다.

## 연결 후보

- [Wiki Index](../index.md)
