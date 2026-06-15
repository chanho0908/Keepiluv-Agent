---
status: draft
last_verified: 2026-06-15
tags:
  - template
  - knowledge-candidate
authority: canonical
---

# 지식 후보 제목

`wiki/inbox`에 작업 중 발견한 지식 후보를 등록할 때 아래 frontmatter를 사용합니다. 후보는 비공식이며 공식 판단 근거로 단독 사용할 수 없습니다.

```yaml
---
type: knowledge-candidate
status: candidate
created_at: 2026-06-15
updated_at: 2026-06-15
last_verified: 2026-06-15
use_count: 1
last_used_at: 2026-06-15
used_in:
  - task: archive-refresh-error-handling
    used_at: 2026-06-15
    context: implementation
    evidence: 기존 콘텐츠를 유지할지 결정하는 근거로 사용
tags:
  - inbox
  - knowledge-candidate
authority: none
---
```

단순 검색과 열람은 기록하지 않습니다. 서로 다른 작업에서 계획·구현·테스트·리뷰 판단에 실제 사용했을 때 작업당 최대 한 번 기록하고, `use_count`를 `used_in` 항목 수와 맞춥니다. 사용 이력이 없는 후보는 `use_count: 0`, `last_used_at: null`, `used_in: []`로 시작할 수 있습니다.

## 후보 내용

재사용할 수 있다고 판단한 설명이나 규칙을 적습니다.

## 근거와 적용 범위

확인한 코드, 테스트, 승인된 요구사항과 적용 범위를 적습니다. 후보만으로 공식 정책을 확정하지 않습니다.

## 승격 또는 기각

승격할 때는 다음 항목을 frontmatter에 추가합니다.

```yaml
status: promoted
resolution_reason: 독립된 작업에서 반복 사용했고 canonical 정책으로 검토·반영함
target_path: wiki/reference/example.md
```

기각할 때는 다음처럼 기록합니다.

```yaml
status: rejected
resolution_reason: 특정 구현에만 해당해 재사용 지식이 아님
target_path: null
```
