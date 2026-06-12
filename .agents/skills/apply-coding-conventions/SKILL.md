---
name: apply-coding-conventions
description: Keepiluv(Twix)의 Kotlin/Android 코드를 기존 아키텍처와 규칙에 맞게 계획, 구현, 테스트, 리뷰하는 절차. 함수와 이름, SOLID, Koin, 문자열, Domain/Data/Presentation/UI 책임을 판단하거나 Kotlin 코드를 변경할 때 사용한다.
---

# Apply Coding Conventions

1. 변경할 모듈과 같은 영역의 기존 코드를 먼저 읽고 현재 패턴을 확인한다.
2. `.codex/docs/domain-glossary.md`, `.codex/docs/architecture.md`, `.codex/docs/hierarchy.md`에서 공식 용어와 레이어 책임을 확인한다.
3. [references/coding-conventions.md](references/coding-conventions.md)에서 작업과 관련된 절만 읽는다.
4. 필요한 기능만 설계하고 Domain → Data → Presentation → UI 순서로 변경한다.
5. 이름, 함수 크기, UseCase 필요 여부, DI 위치, UI 문자열, 레이어 의존성을 점검한다.
6. 기존 테스트와 정적 검사를 실행하고, 새 규칙이 필요한 경우 승인된 범위 안에서 테스트를 보강한다.

계획은 사용자가 이해할 수 있는 목표, 사용자 흐름, 정책, 예외, 검증 방법을 먼저 설명한다. 파일명과 함수명 같은 구현 세부사항은 기술 메모나 handoff에 분리한다.
