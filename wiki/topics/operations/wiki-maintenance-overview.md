---
status: active
sources:
  - "repo:chanho0908/Keepiluv-Agent@14c17aa834575a9422d5e4b33c1191285c575e02:AGENTS.md"
last_verified: 2026-06-14
tags:
  - wiki
  - operations
authority: synthesized
source_paths:
  - wiki/operations/workflows.md
  - wiki/schema/maintenance.md
---

# Wiki 유지보수 한눈에 보기

Wiki 상태 확인은 읽기 전용이며, 공식 지식이나 행동 규칙의 변경과 영향을 받는 종합 문서를 보여줍니다. 원본 Android 저장소에서 `develop`에 PR이 병합되면 자동화가 PR 설명, 병합된 코드와 변경 파일을 근거로 Wiki 수정 필요 여부를 확인합니다.

AI가 수정할 내용이 있으면 `Keepiluv-Agent`에 Draft PR을 만듭니다. 이 PR에는 어떤 Android PR을 근거로 삼았는지가 표시됩니다. 공식 지식은 사람이 내용을 확인하고 병합해야 확정됩니다.

병합 후에는 Git 커밋과 PR이 공식 버전 이력이 되고, Wiki Log에는 사람이 읽기 쉬운 변경 요약이 남습니다. Manifest에는 승인된 현재 파일 상태를 기록합니다.

## 관련 문서

- [복합 워크플로우](../../operations/workflows.md)
- [자동 유지보수](../../schema/maintenance.md)
