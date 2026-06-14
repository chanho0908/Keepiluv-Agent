---
status: active
sources:
- repo:chanho0908/Keepiluv-Agent@de9f870146845f8fffa917f7c2c794bf70edb124:AGENTS.md
last_verified: 2026-06-14
tags:
- wiki
- operations
authority: canonical
---

# Wiki Log

이 문서는 Wiki에서 수행한 작업을 기록하기 위해 2026-06-12 파일럿에서 생성했습니다. 출처는 작업 기록 자체가 아니라 승인과 운영 원칙의 근거를 가리킵니다.

## 2026-06-12

- LLM Wiki 파일럿 구조를 생성했습니다.
- 프로젝트 개요, 아키텍처, 도메인 용어집, 협업 회고를 첫 topic으로 종합했습니다.
- Ingest, Query, Lint의 역할과 승인 게이트를 정의했습니다.

## 2026-06-13

- 기존 프로젝트 문서를 `wiki/reference`와 `wiki/operations`로 이전했습니다.
- Wiki를 프로젝트의 유일한 공식 지식 베이스로 지정했습니다.
- MVI 상태 모델링과 협업 원칙을 canonical 아키텍처 문서에 병합했습니다.
- Wiki 변경 감지, 영향 분석, 승인 후 동기화를 위한 `wiki-maintainer`와 상태 Manifest를 도입했습니다.

## 2026-06-14

- `Keepiluv/Keepiluv-Android`의 `develop` 병합 PR을 Wiki 변경 근거로 사용하는 규칙을 추가했습니다.
- PR URL, 병합 커밋과 확인일을 함께 기록하는 `pr:` 출처 형식을 도입했습니다.
- 병합 PR을 정기 또는 수동으로 확인하고 Codex가 Wiki 수정 Draft PR을 만드는 GitHub Actions를 추가했습니다.
- Codex 실행 작업과 저장소 쓰기 작업을 분리하고 모든 외부 Action을 커밋 SHA로 고정했습니다.
