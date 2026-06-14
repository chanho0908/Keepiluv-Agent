---
name: wiki-maintainer
description: 공식 Wiki나 Agent/Skill 변경을 감지하고, 영향 문서를 찾아 승인 후 단일 지식 베이스를 갱신할 때 사용한다.
---

# Wiki Maintainer

1. `wiki/index.md`를 먼저 읽고 관련 canonical 문서를 확인한다.
2. `./scripts/wiki-status.sh`를 실행해 내부 변경과 영향 문서를 확인한다.
3. 작업 중 확인한 코드, 테스트, 기존 canonical 문서와 승인된 사용자 요구사항을 비교한다.
4. 도메인 정책 변경, 반복되는 지식, Wiki와 코드의 불일치, 재사용할 운영 규칙만 축적한다.
5. 일회성 구현 세부사항과 정책을 바꾸지 않는 단순 수정은 Wiki에 추가하지 않는다.
6. 승인된 본작업 범위 안에서 Wiki, Index와 Log를 함께 갱신한다.
7. 원본 작업의 PR 번호나 움직이는 브랜치 URL은 Wiki 출처로 기록하지 않는다.
8. 외부 코드 근거를 장기 보존해야 할 때만 commit SHA가 고정된 파일 permalink를 사용한다.
9. Wiki validator가 통과한 뒤 `./scripts/wiki-status.sh --accept --approved`로 승인된 기준 상태를 갱신한다.
10. automation, 마이그레이션, 상태, Wiki 검사와 diff 검사를 실행한다.

공식 문서는 `authority: canonical`, 종합 문서는 `authority: synthesized`와 존재하는 `source_paths`를 사용한다.
`--accept` 단독 실행, 필수 canonical 누락, validator 실패 상태에서는 Manifest를 변경하지 않는다.
