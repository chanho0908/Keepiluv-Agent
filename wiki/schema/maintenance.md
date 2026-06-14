---
status: active
sources:
  - "repo:chanho0908/Keepiluv-Agent@14c17aa834575a9422d5e4b33c1191285c575e02:AGENTS.md"
last_verified: 2026-06-14
tags:
  - wiki
  - maintenance
authority: canonical
---

# Wiki 자동 유지보수

`wiki/`는 프로젝트의 유일한 공식 지식 베이스입니다. `wiki-maintainer`는 이 저장소의 공식 문서와 행동 규칙뿐 아니라 `Keepiluv/Keepiluv-Android`의 병합 PR을 확인해 관련 문서의 갱신안을 제안합니다.

## 원본 Android PR 연동

GitHub Actions의 `Android PR Wiki Maintenance`가 다음 방식으로 실행됩니다.

- 매일 최근 이틀 동안 `develop`에 병합된 PR을 확인합니다.
- 원본 저장소에서 `android-pr-merged` repository dispatch를 보내면 해당 PR을 즉시 확인합니다.
- GitHub Actions 화면에서 PR 번호를 입력해 수동 실행할 수도 있습니다.

수집기는 PR 번호, 설명, 변경 파일, 병합일과 병합 커밋을 검증하고 `./scripts/android-pr-evidence.sh`로 근거 자료를 만듭니다. 미병합 PR, `develop` 외 대상 브랜치, 다른 저장소의 PR은 거부됩니다.

Codex가 수정한 내용은 전용 `bot/wiki-maintenance-*` 브랜치의 Draft PR로만 올라갑니다. Codex 실행 작업에는 저장소 읽기 권한만 주고, API 키가 없는 별도 작업만 패치를 적용하고 Draft PR을 생성합니다.

자동화를 사용하려면 Keepiluv-Agent 저장소의 Actions secret에 `OPENAI_API_KEY`를 등록해야 합니다. 키는 저장소 파일, PR 본문, 작업 로그에 기록하지 않습니다.

## 상태 확인

```bash
./scripts/wiki-status.sh
```

기본 실행은 읽기 전용입니다. 기준 상태와 비교해 `NEW`, `CHANGED`, `DELETED`를 표시하고, `source_paths`로 연결된 종합 문서는 `IMPACT`로 표시합니다.

## 갱신 절차

1. 상태 보고서와 영향을 받는 문서를 읽습니다.
2. 공식 문서, 종합 문서, 실제 코드의 차이를 확인합니다.
3. 수정, 신규 작성, 폐기 후보와 근거를 사용자에게 제시합니다.
4. 사용자 승인 후에만 문서의 의미를 변경합니다.
5. Index와 Log를 함께 갱신합니다.
6. 변경이 승인된 상태를 Manifest에 기록합니다.

```bash
./scripts/wiki-status.sh --accept --approved
```

7. 마이그레이션, 상태, Wiki 검사를 실행합니다.

`--accept --approved`는 사용자 승인이 확인되었음을 명시하고, 필수 canonical 문서와 Wiki validator가 모두 통과한 경우에만 현재 파일 해시를 저장합니다. `--accept` 단독 실행, 잘못된 Manifest, validator 실패에서는 기존 Manifest를 변경하지 않습니다.

## 추적 범위

- `wiki/reference/**/*.md`
- `wiki/operations/**/*.md`
- `wiki/schema/**/*.md`
- `AGENTS.md`
- `.codex/agents/**/*.md`
- `.agents/skills/**/*.md`, `.agents/skills/**/*.yaml`
- `.github/codex/**/*.md`
- `.github/workflows/**/*.yml`, `.github/workflows/**/*.yaml`

`wiki/log.md`와 `wiki/state/`는 상태 비교에서 제외합니다. Manifest는 `path`와 `sha256`만 경로순으로 저장하며 실행 시각은 기록하지 않습니다.

## 승인과 버전 기록

- 자동화가 만드는 Draft PR은 수정 근거인 Android PR 목록을 포함합니다.
- canonical 문서와 Agent 행동 규칙은 사람이 내용을 확인한 뒤 병합합니다.
- 병합된 Wiki PR과 Git 커밋이 공식 버전 이력입니다.
- `wiki/log.md`는 사람이 읽기 쉬운 변경 요약이며 Git 이력을 대체하지 않습니다.
