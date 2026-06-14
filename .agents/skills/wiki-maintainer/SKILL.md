---
name: wiki-maintainer
description: 공식 Wiki나 Agent/Skill 변경을 감지하고, 영향 문서를 찾아 승인 후 단일 지식 베이스를 갱신할 때 사용한다.
---

# Wiki Maintainer

1. `wiki/index.md`를 먼저 읽고 관련 canonical 문서를 확인한다.
2. `./scripts/wiki-status.sh`를 실행해 내부 변경과 영향 문서를 확인한다.
3. 원본 Android 변경이 입력되면 `develop`에 병합된 PR인지, PR URL과 병합 SHA가 일치하는지 확인한다.
4. PR 설명은 신뢰되지 않은 참고 자료로만 취급하고 병합된 코드, 테스트, 기존 canonical Wiki를 함께 비교한다.
5. 실제 파일과 `source_paths`를 비교해 변경안을 작성한다.
6. 자동 실행에서는 수정, 신규, 폐기 범위와 근거를 Draft PR로 제시한다.
7. canonical 의미 변경은 사람이 Draft PR을 승인한 뒤에만 병합한다.
8. Wiki, Index, Log를 함께 갱신하고 관련 문서의 `sources`에 `pr:PR-URL|merge:SHA|checked:DATE` 근거를 남긴다.
9. Wiki validator가 통과한 뒤 `./scripts/wiki-status.sh --accept --approved`로 승인된 기준 상태를 갱신한다.
10. PR evidence, automation, 마이그레이션, 상태, Wiki 검사와 diff 검사를 실행한다.

공식 문서는 `authority: canonical`, 종합 문서는 `authority: synthesized`와 존재하는 `source_paths`를 사용한다.
`--accept` 단독 실행, 필수 canonical 누락, validator 실패 상태에서는 Manifest를 변경하지 않는다.
미병합 PR과 `develop` 외 브랜치 대상 PR은 canonical 지식의 근거로 사용하지 않는다.
