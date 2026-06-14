---
status: draft
sources:
- repo:chanho0908/Keepiluv-Agent@de9f870146845f8fffa917f7c2c794bf70edb124:AGENTS.md
last_verified: 2026-06-14
tags:
- source
authority: canonical
---

# 원본 제목

새 문서를 만들 때 아래 예시의 값을 실제 출처와 확인일로 바꿉니다. Frontmatter의 현재 값은 유효한 Keepiluv-Agent 내부 출처를 유지합니다.

```yaml
sources:
  # 현재 Keepiluv-Agent 저장소 내부 원본
  - "repo:chanho0908/Keepiluv-Agent@14c17aa834575a9422d5e4b33c1191285c575e02:AGENTS.md"

  # Twix 같은 외부 저장소의 commit 고정 permalink
  - "url:https://github.com/chanho0908/Twix/blob/0123456789abcdef0123456789abcdef01234567/path/to/source.kt|checked:2026-06-12"

  # 원본 Android 저장소에서 develop에 병합된 PR
  - "pr:https://github.com/Keepiluv/Keepiluv-Android/pull/165|merge:2b74cd4d61e3a78360e83128968a8a8dc78760e8|checked:2026-06-14"
last_verified: 2026-06-12
authority: canonical
```

외부 GitHub URL의 `/blob/` 다음 값은 실제 40자리 commit SHA여야 합니다. `main`, 브랜치명, `HEAD` URL은 사용하지 않습니다.
PR 출처는 `develop`에 실제로 병합된 PR과 그 병합 커밋을 함께 기록합니다.

## 등록 이유

이 원본을 Wiki에 추가하는 이유를 설명합니다.

## 요약

저작권을 존중해 원문 전체 대신 핵심 내용만 요약합니다.

## 연결 후보

- [Wiki Index](../index.md)
