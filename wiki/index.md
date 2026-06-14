---
status: active
last_verified: 2026-06-14
tags:
- wiki
- index
authority: canonical
---

# Keepiluv LLM Wiki

이 저장소의 루트를 Obsidian Vault로 열어 사용합니다. `wiki/`는 프로젝트의 유일한 공식 지식 베이스이며, 이 Index가 모든 지식 탐색의 시작점입니다.

`authority: canonical` 문서는 공식 사실과 정책입니다. `authority: synthesized` 문서는 canonical 문서를 연결해 설명하며, 충돌할 때는 연결된 canonical 문서가 우선합니다.

## 처음 사용하는 분

- [비개발자를 위한 사용 안내서](guide.md): 설치, 첫 화면 찾기, 일상 사용법, 안전 수칙을 쉬운 말로 안내합니다.

## 공식 프로젝트 지식

- [프로젝트 개요](reference/project-overview.md)
- [아키텍처 원칙](reference/architecture.md)
- [모듈 구조](reference/module-hierarchy.md)
- [도메인 용어집](reference/domain-glossary.md)
- [테스트 전략](reference/test-strategy.md)

## 공식 운영 지식

- [Agent 라우팅 규칙](operations/routing-rules.md)
- [복합 워크플로우](operations/workflows.md)
- [Agent 목록](operations/agent-list.md)

## 종합 안내

- [Wiki 유지보수 한눈에 보기](topics/operations/wiki-maintenance-overview.md)

## Operations

- [운영 흐름](schema/workflow.md): Ingest, Query, Lint와 승인 게이트
- [자동 유지보수](schema/maintenance.md): 변경 감지, 승인, Manifest 갱신
- [출처 정책](schema/source-policy.md): 원본 추적과 저장 금지 정보
- [검사 기준](schema/lint.md): Wiki 품질 점검 기준
- [페이지 템플릿](schema/page-template.md): 공통 메타데이터와 본문 형식
- [Source 템플릿](templates/source.md): 원본 등록 형식
- [Topic 템플릿](templates/topic.md): 종합 지식 작성 형식
- [변경 기록](log.md): Wiki 운영 이력

## Obsidian 규칙

- `Keepiluv-Agent` 저장소 루트를 Vault로 엽니다.
- 링크는 표준 Markdown 링크만 사용합니다.
- 첨부파일 기본 경로는 `wiki/attachments`로 설정합니다.
- Properties, Backlinks, Graph view, Templates 등 코어 기능부터 사용합니다.
- `.obsidian`은 개인 설정이므로 Git에서 추적하지 않습니다.
