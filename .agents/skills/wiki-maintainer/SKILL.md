---
name: wiki-maintainer
description: 승인된 본작업에서 공식 Wiki나 Agent/Skill 변경을 감지하고, 영향 문서와 Wiki 검증 기준점을 자동 동기화할 때 사용한다.
---

# Wiki Maintainer

1. `wiki/index.md`를 먼저 읽고 관련 canonical 문서를 확인한다.
2. `./scripts/wiki-status.sh`를 실행해 내부 변경과 영향 문서를 확인한다.
3. 작업 중 확인한 코드, 테스트, 기존 canonical 문서와 승인된 사용자 요구사항을 비교한다.
4. 도메인 정책 변경, 반복되는 지식, Wiki와 코드의 불일치, 재사용할 운영 규칙만 축적한다.
5. 일회성 구현 세부사항과 정책을 바꾸지 않는 단순 수정은 Wiki에 추가하지 않는다.
6. 승인된 본작업 범위 안에서 Wiki, Index와 Log를 별도 Wiki 승인 없이 함께 갱신한다.
7. 본작업과 무관한 도메인/운영 정책 변경이나 새로운 의미 결정은 사용자 승인을 받는다.
8. 원본 작업의 PR 번호나 움직이는 브랜치 URL은 Wiki 출처로 기록하지 않는다.
9. 외부 코드 근거를 장기 보존해야 할 때만 commit SHA가 고정된 파일 permalink를 사용한다.
10. Wiki 명령은 `Keepiluv-Agent` 저장소 루트에서 실행한다.
11. 관련 테스트를 실행한다.
12. Wiki validator를 실행한다.
13. 작업 시작 전부터 존재한 다른 미승인 변경이 승인 범위에 섞이지 않았는지 확인한다.
14. 안전한 경우에만 `./scripts/wiki-status.sh --accept --approved`로 Wiki 검증 기준점을 갱신한다.
15. 다른 미승인 변경이 함께 확정될 수 있으면 갱신하지 않고 이유를 보고한다.
16. Skill 생성이나 갱신은 사용자의 명시적 요청 또는 별도 승인된 작업에서 해당 Skill 절차로 수행한다.
17. automation, 마이그레이션, 상태, Wiki 검사와 diff 검사 결과를 보고한다.

공식 문서는 `authority: canonical`, 종합 문서는 `authority: synthesized`와 존재하는 `source_paths`를 사용한다.
`--accept --approved`는 관련 테스트 전체를 대신하지 않는다. 외부 workflow와 Agent가 선행 테스트를 책임지며, `--accept` 단독 실행, 필수 canonical 누락, validator 실패 상태에서는 Wiki 검증 기준점을 변경하지 않는다.
