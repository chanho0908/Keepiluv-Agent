---
status: active
sources:
- repo:chanho0908/Keepiluv-Agent@de9f870146845f8fffa917f7c2c794bf70edb124:AGENTS.md
last_verified: 2026-06-12
tags:
- wiki
- lint
authority: canonical
---

# Wiki 검사 기준

검사는 우선 보고서만 만들며 자동으로 의미를 변경하지 않습니다.

## 필수 검사

- 필수 디렉터리와 운영 문서가 존재하는지 확인합니다.
- 각 topic에 `status`, `sources`, `last_verified`, `tags`가 있는지 확인합니다.
- 출처가 인용 문자열 목록이며 저장소·경로·커밋 또는 URL·확인일로 추적되는지 확인합니다.
- 표준 Markdown 링크가 깨지지 않았는지 확인합니다.
- 출처 없는 주장, 서로 충돌하는 주장, 오래된 출처를 찾습니다.
- Index에서 연결되지 않은 고아 페이지와 폐기된 페이지를 가리키는 링크를 찾습니다.
- 비밀정보로 보이는 값과 금지된 링크 문법을 찾습니다.
- 필수 canonical 문서와 `authority` 값이 올바른지 확인합니다.
- synthesized 문서의 `source_paths`가 실제 파일을 가리키는지 확인합니다.
- 이전 지식 디렉터리나 이전 경로 참조가 남아 있지 않은지 확인합니다.
- Manifest가 경로와 SHA-256 해시만 포함하며 경로순으로 정렬됐는지 확인합니다.

## 실행

```bash
./scripts/validate-wiki.sh
./scripts/wiki-status.sh
```

승인된 기준 상태를 확정할 때만 다음 명령을 사용합니다.

```bash
./scripts/wiki-status.sh --accept --approved
```

검사 통과는 내용이 공식 정책으로 승격되었다는 뜻이 아닙니다. 의미 검토와 Git 반영에는 별도 승인이 필요합니다.
