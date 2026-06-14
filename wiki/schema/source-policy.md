---
status: active
sources:
- repo:chanho0908/Keepiluv-Agent@de9f870146845f8fffa917f7c2c794bf70edb124:AGENTS.md
last_verified: 2026-06-14
tags:
- wiki
- source-policy
authority: canonical
---

# 출처 정책

## 우선순위

`wiki/`는 프로젝트의 유일한 공식 지식 베이스입니다. `authority: canonical` 문서가 공식 사실과 정책을 정의하고, `authority: synthesized` 문서는 `source_paths`로 연결된 canonical 문서를 종합합니다. 내용이 충돌하면 canonical 문서, 실제 코드, agent와 skill의 행동 규칙 순서로 재검증합니다.

## 추적 형식

`sources`는 Obsidian Properties에서 배열로 인식되는 인용 문자열 목록으로 기록합니다.

- `repo:` 형식은 현재 Vault가 속한 `chanho0908/Keepiluv-Agent` 저장소 내부 원본에만 사용합니다.
- 원본 Android 저장소에서 병합된 PR은 `pr:PR-URL|merge:40자리-SHA|checked:YYYY-MM-DD` 형식으로 기록합니다.
- Twix처럼 다른 저장소의 원본은 GitHub commit SHA가 포함된 고정 permalink를 `url:https://주소|checked:YYYY-MM-DD` 형식으로 기록합니다.
- `main`, 다른 브랜치명, `HEAD`가 들어간 움직이는 GitHub URL은 출처로 사용하지 않습니다.

```yaml
sources:
  - "repo:chanho0908/Keepiluv-Agent@de9f870146845f8fffa917f7c2c794bf70edb124:AGENTS.md"
  - "pr:https://github.com/Keepiluv/Keepiluv-Android/pull/165|merge:2b74cd4d61e3a78360e83128968a8a8dc78760e8|checked:2026-06-14"
  - "url:https://github.com/chanho0908/Twix/blob/0123456789abcdef0123456789abcdef01234567/path/to/source.kt|checked:2026-06-12"
```

내부 저장소 출처의 커밋에는 해당 경로가 실제로 존재해야 합니다. PR 출처는 병합된 PR만 사용하며 실제 병합 커밋 SHA를 고정합니다. 외부 GitHub permalink는 `/blob/` 다음에 40자리 commit SHA가 있어야 하며, 해당 SHA와 경로를 확인한 날짜를 함께 기록합니다. 아직 커밋되지 않은 생성 문서는 자기 자신을 출처로 기록하지 않고, 생성 사실을 본문이나 [Wiki Log](../log.md)에 설명합니다. 중요한 결론은 본문에서도 Vault 안의 원본 문서로 연결합니다.

PR 제목과 설명만으로 정책을 확정하지 않습니다. 병합된 코드, 테스트, 리뷰 결론과 기존 canonical Wiki를 함께 비교합니다. 미병합 또는 닫힌 PR은 변경 예정이나 논의 자료로만 취급하며 공식 지식의 근거로 사용하지 않습니다.

다음처럼 시간이 지나면 내용이 바뀔 수 있는 URL은 금지합니다.

```text
https://github.com/chanho0908/Twix/blob/main/path/to/source.kt
https://github.com/chanho0908/Twix/blob/feature-branch/path/to/source.kt
https://github.com/chanho0908/Twix/blob/HEAD/path/to/source.kt
```

## 저장 원칙

- 외부 원문 전체를 복사하지 않고 URL, 확인일, 요약만 남깁니다.
- 비밀번호, 인증 토큰, 개인키, 서명 파일, 개인정보는 `inbox`, `sources`, topic, 첨부파일 어디에도 저장하지 않습니다.
- 출처가 없거나 확인할 수 없는 내용은 사실처럼 기록하지 않고 `확인 필요`로 표시합니다.
- 모순은 한쪽을 지우지 않고 양쪽 근거와 현재 상태를 함께 기록합니다.
- 오래된 내용은 삭제보다 `deprecated` 상태와 후속 문서 링크로 보존합니다.

## 문서 권위

- 공식 프로젝트 지식과 운영 정책은 `authority: canonical`을 사용합니다.
- 여러 공식 문서를 연결한 해설은 `authority: synthesized`와 비어 있지 않은 `source_paths`를 사용합니다.
- `source_paths`는 저장소 루트 기준 상대 경로이며 실제 파일이 존재해야 합니다.
- canonical 문서의 의미 변경은 사용자 승인 후에만 반영합니다.
