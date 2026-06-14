---
status: active
sources:
- repo:chanho0908/Keepiluv-Agent@de9f870146845f8fffa917f7c2c794bf70edb124:AGENTS.md
last_verified: 2026-06-14
tags:
- wiki
- workflow
authority: canonical
---

# Wiki 운영 흐름

## Ingest

1. 사람은 자료의 가치, 공개 가능 여부, 민감정보 포함 여부를 확인합니다.
2. Codex는 Keepiluv-Agent 내부 원본을 `repo:chanho0908/Keepiluv-Agent@40자리-커밋:path`로 기록합니다. 외부 원본은 필요한 경우에만 commit SHA가 포함된 GitHub 고정 permalink로 기록합니다. 원본 작업의 PR 번호는 출처로 기록하지 않습니다.
3. Codex는 [Wiki Index](../index.md)에서 기존 topic을 찾아 새 사실을 연결하거나 새 topic 초안을 만듭니다.
4. Codex는 원문 복사보다 결론, 관계, 적용 맥락을 종합하고 변경 후보를 보여줍니다.
5. 사람이 의미와 출처를 승인한 뒤에만 Wiki 쓰기를 확정합니다.

파일럿에서는 한 번에 원본 하나를 처리합니다. 의미가 달라지는 모든 변경은 사람의 승인이 필요합니다.

내부 저장소 출처는 해당 커밋에서 경로가 실제로 존재하는지 확인합니다. 외부 저장소에 `repo:` 형식을 사용하거나 `main`, 브랜치명, `HEAD` 기반 URL을 출처로 사용하지 않습니다. 새로 생성해 아직 커밋되지 않은 Wiki 문서는 자기 자신을 출처로 삼지 않고 생성 사실을 본문과 log에 기록합니다.

## Query

1. Codex는 Index에서 관련 topic을 찾고 필요한 원본까지 확인합니다.
2. 답변에는 사용한 Wiki 페이지와 최종 원본을 함께 제시합니다.
3. 근거가 부족하면 추측하지 않고 `확인 필요`로 답합니다.
4. 일반 Query는 읽기 전용입니다.
5. 반복해서 쓸 가치가 있는 결론은 저장 후보로 제안하고, 사람이 승인한 경우에만 topic과 log를 갱신합니다.

## Lint

1. Codex는 [검사 기준](lint.md)에 따라 보고서를 만듭니다.
2. 링크 정렬처럼 의미가 바뀌지 않는 수정도 파일럿 동안에는 승인 후 적용합니다.
3. 출처, 상태, 결론이 달라지는 수정은 반드시 사람이 검토합니다.
4. 검사가 끝나면 실행일과 결과를 [Wiki Log](../log.md)에 남깁니다.

## 자동 유지보수

1. 작업을 수행한 Agent가 구현과 검증을 마친 뒤 장기 지식 변경 여부를 판단합니다.
2. 도메인 정책 변경, 반복되는 지식, Wiki와 코드의 불일치 또는 재사용할 운영 규칙이 있으면 `wiki-maintainer`로 넘깁니다.
3. `wiki-maintainer`는 작업 중 확인한 코드, 테스트, 기존 canonical 문서와 승인된 사용자 요구사항을 비교합니다.
4. 승인된 본작업 범위 안에서 Wiki, Index와 Log를 함께 갱신합니다.
5. validator 통과 후 승인된 변경을 `./scripts/wiki-status.sh --accept --approved`로 Manifest에 기록합니다.
6. GitHub Actions는 LLM을 호출하지 않고 [검사 기준](lint.md)에 따라 Wiki 형식과 연결만 검증합니다.

## 역할과 승인 게이트

| 단계 | 사람 | Codex | 승인 지점 |
|---|---|---|---|
| 자료 선택 | 공개 가능성과 가치 판단 | 후보 원본 분석 | Ingest 시작 승인 |
| 초안 작성 | 의미와 범위 검토 | 출처 등록과 topic 종합 | Wiki 쓰기 승인 |
| 질의 | 질문과 저장 필요성 결정 | Wiki와 원본 기반 답변 | 새 지식 저장 승인 |
| 검사 | 의미 변경 판단 | 문제 탐지와 수정안 제시 | 수정 적용 승인 |
| Git 마무리 | 변경 범위와 메시지 승인 | 승인된 절차로 위임 | 커밋과 PR 각각 승인 |
