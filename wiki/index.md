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

이 Wiki의 오너는 Twix 프로젝트입니다. 문서는 `Keepiluv-Agent` 저장소에서 중앙 관리하며, `Twix/wiki` 심볼릭 링크를 통해 Twix 프로젝트에서 Wiki에 접근합니다.

`authority: canonical` 문서는 공식 사실과 정책입니다. `authority: synthesized` 문서는 canonical 문서를 연결해 설명하며, 충돌할 때는 연결된 canonical 문서가 우선합니다.

## 처음 사용하는 분

- [비개발자를 위한 사용 안내서](guide.md): 설치, 첫 화면 찾기, 일상 사용법, 안전 수칙을 쉬운 말로 안내합니다.

## 공식 프로젝트 지식

- [프로젝트 개요](reference/project-overview.md): 서비스 목적, 대표 사용자 흐름, 핵심 기술과 주요 진입점
- [아키텍처 원칙](reference/architecture.md): 레이어 책임, 의존 방향, MVI 등 구현할 때 지켜야 할 원칙
- [모듈 구조](reference/module-hierarchy.md): 아키텍처 원칙이 적용되는 실제 모듈과 폴더 위치, 표준 배치
- [도메인 용어집](reference/domain-glossary.md)
- [테스트 전략](reference/test-strategy.md)

## Agent 작업 운영

Codex가 어떤 Agent에게 작업을 맡기고, 어떤 순서와 승인 절차로 진행하는지 정한 기준입니다.

- [Agent 라우팅 규칙](operations/routing-rules.md)
- [Agent 작업 워크플로우](operations/workflows.md)
- [Agent 목록](operations/agent-list.md)

## Wiki 관리 운영

Wiki 문서를 등록하고 검사하며, 승인된 본작업의 지식을 자동 동기화하는 관리 기준입니다.

- [Wiki 운영 흐름](schema/workflow.md): Ingest, Query, Lint와 승인 게이트
- [Wiki 자동 유지보수](schema/maintenance.md): 승인 범위 변경 감지, 자동 동기화, Wiki 검증 기준점 갱신
- [출처 정책](schema/source-policy.md): 원본 추적과 저장 금지 정보
- [Wiki 검사 기준](schema/lint.md): Wiki 품질 점검 기준
- [페이지 템플릿](schema/page-template.md): 공통 메타데이터와 본문 형식
- [Source 템플릿](templates/source.md): 원본 등록 형식
- [지식 후보 템플릿](templates/knowledge-candidate.md): 비공식 후보의 사용 근거와 승격·기각 기록 형식
- [Topic 템플릿](templates/topic.md): 종합 지식 작성 형식
- [Wiki 변경 기록](log.md): Wiki 운영 이력

## 종합 안내

- [Wiki 유지보수 한눈에 보기](topics/operations/wiki-maintenance-overview.md)

## Obsidian 규칙

- `Keepiluv-Agent` 저장소 루트를 Vault로 엽니다.
- 링크는 표준 Markdown 링크만 사용합니다.
- 첨부파일 기본 경로는 `wiki/attachments`로 설정합니다.
- Properties, Backlinks, Graph view, Templates 등 코어 기능부터 사용합니다.
