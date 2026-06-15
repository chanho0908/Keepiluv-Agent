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

## Inbox 지식 후보

`wiki/inbox`는 미정리 새 자료와 아직 공식화되지 않은 지식 후보의 공통 대기 공간입니다.

- `type: source`: 회의 메모, 참고 링크처럼 아직 정리하지 않은 새 자료
- `type: knowledge-candidate`: 작업 중 발견했지만 canonical 문서로 확정하지 않은 재사용 지식

지식 후보는 비공식이며 `authority: none`을 사용합니다. 후보만으로 제품 사실이나 운영 정책을 확정할 수 없고, 기존 canonical 문서와 코드·테스트·승인된 사용자 요구사항을 함께 확인해야 합니다.

### 후보 메타데이터

모든 `knowledge-candidate`는 다음 항목을 기록합니다.

- `created_at`: 후보를 처음 기록한 날짜
- `updated_at`: 후보 내용이나 사용 근거를 마지막으로 바꾼 날짜
- `use_count`: 실제 판단에 사용한 서로 다른 작업 수
- `last_used_at`: 가장 최근 사용 근거의 날짜. 사용 이력이 없으면 `null`
- `used_in`: 독립된 작업별 `task`, `used_at`, `context`, `evidence` 목록

`context`는 `plan`, `implementation`, `test`, `review` 중 하나입니다. 검색 결과에 포함되거나 내용을 단순 열람한 경우는 사용으로 세지 않습니다. 계획·구현·테스트·리뷰의 판단 근거로 실제 적용했을 때만 기록하며, 같은 작업에서는 여러 번 적용해도 최대 한 번만 셉니다. `use_count`는 중복 없는 `used_in.task` 개수와 항상 같아야 합니다.

### 승격과 기각

- 제품 정책, 사용자 흐름, 데이터 안전 규칙은 `use_count`와 무관하게 즉시 승격 검토할 수 있습니다.
- 일반 후보는 독립 작업 2회 이상에서 사용됐을 때 승격 검토합니다.
- 조건 충족은 검토 시작 신호이며 자동 승격 승인이 아닙니다.
- 승격하면 `status: promoted`, `resolution_reason`, `target_path`를 기록합니다. `target_path`는 반영된 canonical 문서를 가리킵니다.
- 기각하면 `status: rejected`, `resolution_reason`을 기록하고 `target_path`는 비워 둡니다.
- 공식 Wiki 승격은 기존 Wiki 전용 Draft PR을 만들고 사용자가 리뷰·최종 승인하는 흐름을 따릅니다.

형식은 [지식 후보 템플릿](../templates/knowledge-candidate.md)을 사용합니다.

## 동기화 방식

1. 본작업 Agent가 구현과 검증을 완료합니다.
2. 장기 지식 변경 여부를 판단합니다.
3. 필요하면 `wiki-maintainer`가 작업 중 확인한 코드, 테스트, 기존 canonical 문서와 승인된 사용자 요구사항을 비교합니다.
4. 즉시 공식화하지 않는 재사용 지식은 inbox 후보로 만들거나 기존 후보의 독립 작업 근거를 갱신합니다.
5. 승격 또는 기각한 후보는 상태, 사유와 대상 문서를 기록합니다.
6. 승인된 본작업 범위 안에서 Wiki, Index와 Log를 별도 Wiki 승인 없이 함께 갱신합니다.
7. 원본 작업 PR 번호는 Wiki 출처로 기록하지 않습니다.
8. 외부 코드 위치를 장기 보존해야 할 때만 commit SHA가 고정된 파일 permalink를 사용합니다.

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
