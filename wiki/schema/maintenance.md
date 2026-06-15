---
status: active
last_verified: 2026-06-15
tags:
  - wiki
  - maintenance
authority: canonical
---

# Wiki 자동 유지보수

`wiki/`는 프로젝트의 유일한 공식 지식 베이스입니다. 작업을 수행한 Agent는 구현과 검증 과정에서 장기 지식이 생겼는지 판단하고, 필요한 경우 `wiki-maintainer`를 통해 같은 작업에서 별도 Wiki 승인 없이 함께 갱신합니다.

모든 Wiki 명령은 `Keepiluv-Agent` 저장소 루트에서 실행합니다.

## 자동 판단 기준

다음 중 하나에 해당하면 Wiki 갱신 대상으로 봅니다.

- 도메인 정책이나 사용자 흐름의 의미가 변경됨
- 여러 작업에서 반복되는 설명이나 판단 기준이 확인됨
- 기존 Wiki가 실제 코드와 달라졌거나 빠진 내용을 발견함
- 다음 작업부터 Agent나 Skill이 따라야 할 운영 규칙이 생김

일회성 구현 세부사항, 단순 UI 조정, 기존 정책을 바꾸지 않는 버그 수정은 축적하지 않습니다.

## 동기화 방식

1. 본작업 Agent가 구현과 검증을 완료합니다.
2. 장기 지식 변경 여부를 판단합니다.
3. 필요하면 `wiki-maintainer`가 작업 중 확인한 코드, 테스트, 기존 canonical 문서와 승인된 사용자 요구사항을 비교합니다.
4. 승인된 본작업 범위 안에서 Wiki, Index와 Log를 별도 Wiki 승인 없이 함께 갱신합니다.
5. 원본 작업 PR 번호는 Wiki 출처로 기록하지 않습니다.
6. 외부 코드 위치를 장기 보존해야 할 때만 commit SHA가 고정된 파일 permalink를 사용합니다.

## 상태 확인

```bash
./scripts/wiki-status.sh
```

기본 실행은 읽기 전용입니다. Wiki 검증 기준점과 비교해 `NEW`, `CHANGED`, `DELETED`를 표시하고, `source_paths`로 연결된 종합 문서는 `IMPACT`로 표시합니다.

## 갱신 절차

1. 상태 보고서와 영향을 받는 문서를 읽습니다.
2. 공식 문서, 종합 문서, 실제 코드의 차이를 확인합니다.
3. 수정, 신규 작성, 폐기 범위와 근거를 판단합니다.
4. 승인된 본작업 범위 안에서 문서를 함께 변경합니다.
5. Index와 Log를 함께 갱신합니다.
6. 관련 테스트를 실행합니다.
7. Wiki validator를 실행합니다.
8. 작업 시작 전부터 존재한 다른 미승인 변경이 승인 범위에 섞이지 않았는지 확인합니다.
9. 안전한 경우에만 승인된 본작업 범위를 Wiki 검증 기준점에 기록합니다.

```bash
./scripts/wiki-status.sh --accept --approved
```

`--accept --approved`는 본작업 승인이 확인되었음을 명시하고, 필수 canonical 문서와 Wiki validator가 모두 통과한 경우에만 현재 파일 해시를 저장합니다. 관련 테스트 전체를 다시 실행하지 않으므로 외부 workflow와 Agent가 선행 테스트를 책임집니다. 작업 시작 전부터 존재한 다른 미승인 source/Wiki 변경까지 함께 확정할 수 있으면 실행하지 않고 이유를 보고합니다. `--accept` 단독 실행, 잘못된 Wiki 검증 기준점, validator 실패에서는 기존 Wiki 검증 기준점을 변경하지 않습니다.

## 추적 범위

- `wiki/reference/**/*.md`
- `wiki/operations/**/*.md`
- `wiki/schema/**/*.md`
- `AGENTS.md`
- `.codex/agents/**/*.md`
- `.agents/skills/**/*.md`, `.agents/skills/**/*.yaml`
- `.github/workflows/**/*.yml`, `.github/workflows/**/*.yaml`

`wiki/log.md`와 `wiki/state/`는 상태 비교에서 제외합니다. Wiki 검증 기준점(`wiki/state/wiki-verification-baseline.tsv`)은 확인된 파일의 `path`와 `sha256`만 경로순으로 저장하며 실행 시각은 기록하지 않습니다.

## 승인과 버전 기록

- Wiki 수정은 본작업 변경과 함께 검토합니다.
- 승인된 본작업에서 생긴 장기 지식, Wiki와 코드의 불일치, 재사용 운영 규칙은 별도 Wiki 수정 승인 없이 동기화합니다.
- 본작업과 무관한 도메인/운영 정책 변경이나 새로운 의미 결정은 사용자 승인을 받습니다.
- Skill 생성이나 갱신은 사용자의 명시적 요청 또는 별도 승인된 작업에서 해당 Skill 절차로 수행합니다.
- 일반 코드가 포함된 변경은 기존 커밋과 PR 승인 절차를 따릅니다.
- 승인된 본작업에서 Wiki, Agent 지침, Wiki 검사 도구만 변경된 경우에는 검사와 기준점 갱신 후 별도 Git 승인 없이 이번 작업 파일을 커밋하고 push하여 Draft PR을 생성합니다.
- 관련 Wiki 변경은 작업 단위로 묶어 PR 남발을 피합니다.
- 사용자는 Draft PR에 리뷰를 남기고, AI는 승인 범위 안에서 리뷰를 확인해 수정·답변한 뒤 재검증하여 같은 PR에 반영합니다.
- AI는 자동 병합하지 않으며 최종 승인과 병합은 사용자가 수행합니다.
- 병합된 Wiki PR과 Git 커밋이 공식 버전 이력입니다.
- `wiki/log.md`는 사람이 읽기 쉬운 변경 요약이며 Git 이력을 대체하지 않습니다.

GitHub Actions의 `Wiki Validation`은 LLM을 호출하지 않습니다. PR이나 수동 실행에서 마이그레이션, 상태, validator 회귀 테스트와 Wiki validator를 실행합니다.
