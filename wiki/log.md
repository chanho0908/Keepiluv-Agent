---
status: active
last_verified: 2026-06-14
tags:
- wiki
- operations
authority: canonical
---

# Wiki Log

이 문서는 Wiki에서 수행한 작업을 기록하기 위해 2026-06-12 파일럿에서 생성했습니다.

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

- 작업을 수행한 Agent가 구현 종료 시 장기 지식 변경 여부를 판단하도록 운영 흐름을 정리했습니다.
- 도메인 정책 변경, 반복 지식, Wiki와 코드의 불일치가 있으면 같은 작업에서 Wiki를 갱신하도록 했습니다.
- 원본 작업 PR 번호를 Wiki 출처로 기록하지 않는 원칙을 명시했습니다.
- 외부 LLM API 자동화를 제거하고 GitHub Actions는 Wiki 검증만 담당하도록 변경했습니다.
- 과거 지식 저장소에서 이전했다는 표시를 Wiki의 `sources`에서 제거했습니다.
- `sources`는 실제 외부 근거가 있을 때만 기록하는 선택 항목으로 변경했습니다.
