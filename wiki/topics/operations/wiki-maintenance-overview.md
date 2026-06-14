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

Wiki 상태 확인은 읽기 전용이며, 공식 지식이나 행동 규칙의 변경과 영향을 받는 종합 문서를 보여줍니다. 작업을 수행한 AI는 구현과 검증을 마친 뒤 도메인 정책 변경이나 반복되는 장기 지식이 생겼는지 판단합니다.

수정할 내용이 있으면 같은 작업에서 `wiki-maintainer`가 Wiki를 함께 갱신합니다. 원본 작업 PR 번호는 Wiki 출처로 기록하지 않습니다. 공식 지식은 본작업 변경과 함께 검토하고 병합해야 확정됩니다.

GitHub Actions는 별도 LLM을 실행하지 않고 문서 형식과 연결만 검사합니다. 병합 후에는 Git 커밋과 PR이 공식 버전 이력이 되고, Wiki Log에는 사람이 읽기 쉬운 변경 요약이 남습니다. Manifest에는 승인된 현재 파일 상태를 기록합니다.

## 관련 문서

- [복합 워크플로우](../../operations/workflows.md)
- [자동 유지보수](../../schema/maintenance.md)
