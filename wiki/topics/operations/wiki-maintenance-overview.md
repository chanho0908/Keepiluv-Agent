---
status: active
last_verified: 2026-06-15
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

즉시 공식화할 근거가 부족한 재사용 지식은 `wiki/inbox`에 비공식 후보로 기록합니다. 검색이나 단순 열람은 사용으로 세지 않고, 서로 다른 작업의 계획·구현·테스트·리뷰 판단에 실제 사용한 근거만 누적합니다. 일반 후보는 독립 작업 2회 이상 사용되면 승격을 검토하고, 제품 정책·사용자 흐름·데이터 안전 규칙은 횟수와 관계없이 바로 검토할 수 있지만 자동으로 공식화하지는 않습니다.

수정할 내용이 있으면 같은 작업에서 `wiki-maintainer`가 별도 Wiki 승인 없이 함께 갱신합니다. Wiki 관련 파일만 바뀐 안전한 작업은 검사와 기준점 갱신 후 자동 커밋과 Draft PR 생성까지 이어지며, 사용자는 Draft PR에서 리뷰하고 최종 승인과 병합을 수행합니다. 제품 기능 코드가 섞이거나 본작업과 무관한 새 의미 결정이 필요하면 기존 승인 절차를 따릅니다. 원본 작업 PR 번호는 Wiki 출처로 기록하지 않으며 AI는 자동 병합하지 않습니다.

구체적인 실행 위치, 검사 범위, Wiki 검증 기준점 갱신 조건은 아래 canonical 문서를 따릅니다. 이 요약과 canonical 문서가 다르면 canonical 문서가 우선합니다.

## 관련 문서

- [복합 워크플로우](../../operations/workflows.md)
- [자동 유지보수](../../schema/maintenance.md)
