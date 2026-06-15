---
status: active
last_verified: 2026-06-15
tags:
- wiki
- lint
authority: canonical
---

# Wiki 검사 기준

검사는 우선 보고서만 만들며 자동으로 의미를 변경하지 않습니다.

## 필수 검사

- 필수 디렉터리와 운영 문서가 존재하는지 확인합니다.
- 각 문서에 `status`, `last_verified`, `tags`, `authority`가 있는지 확인합니다.
- `wiki/inbox` Markdown의 `type`이 `source` 또는 `knowledge-candidate`인지 확인합니다.
- 지식 후보의 날짜, 상태, 사용 근거 형식과 `use_count`/`used_in` 일치 여부를 확인합니다.
- 같은 후보의 `used_in.task`가 중복되지 않고, `last_used_at`이 가장 최근 `used_at`과 일치하는지 확인합니다.
- 승격 후보는 사유와 실제 canonical 대상 문서를, 기각 후보는 사유를 기록했는지 확인합니다.
- 선택 항목인 `sources`가 있으면 비어 있지 않은 인용 문자열 목록이며 고정된 근거로 추적되는지 확인합니다.
- 표준 Markdown 링크가 깨지지 않았는지 확인합니다.
- 출처 없는 주장, 서로 충돌하는 주장, 오래된 출처를 찾습니다.
- Index에서 연결되지 않은 고아 페이지와 폐기된 페이지를 가리키는 링크를 찾습니다.
- 비밀정보로 보이는 값과 금지된 링크 문법을 찾습니다.
- `wiki/reference`, `wiki/operations`, `wiki/schema`의 Markdown이 `authority: canonical`인지 확인합니다.
- synthesized 문서의 `source_paths`가 실제 `authority: canonical` Markdown을 가리키는지 확인합니다.
- `wiki/reference`, `wiki/operations`, `wiki/schema`의 Markdown이 Index에서 직접 탐색 가능한지 확인합니다.
- 이전 지식 디렉터리나 이전 경로 참조가 남아 있지 않은지 확인합니다.
- Wiki 검증 기준점이 경로와 SHA-256 해시만 포함하며 경로순으로 정렬됐는지 확인합니다.

## 실행

```bash
./scripts/validate-wiki.sh
./scripts/wiki-status.sh
```

관련 테스트와 validator 실행 후 승인 범위를 확인했을 때만 Wiki 검증 기준점을 갱신합니다.

```bash
./scripts/wiki-status.sh --accept --approved
```

검사 통과는 후보 내용이 공식 정책으로 승격되었다는 뜻이 아닙니다. 공식 승격은 Draft PR 사용자 리뷰를 거치며, 승인된 본작업 범위 밖의 의미 결정과 Git 반영에는 별도 승인이 필요합니다.
