---
name: test-workflow
description: Keepiluv Android에서 위험에 맞는 가장 낮은 테스트 레벨을 선택하고, 테스트를 작성·검증한 뒤 implementer handoff를 만드는 절차. tester가 단위, 상태 통합, Repository 통합, Compose UI 테스트를 새로 작성하거나 수정하고 회귀 테스트를 보강할 때 사용한다.
---

# Test Workflow

승인된 테스트 범위 안에서 가장 낮고 효과적인 테스트를 작성하고, 실행 결과와 구현 조건을 implementer에게 전달한다.

## 필수 입력

- 사용자 요청 또는 승인된 planner의 `handoff_to_tester`
- 테스트 대상 코드와 같은 모듈의 기존 테스트
- `.codex/docs/test-strategy.md`의 테스트 레벨, 완료 기준, 제외 대상
- `.codex/docs/domain-glossary.md`의 공식 도메인 용어
- `.codex/docs/routing-rules.md`의 브랜치와 쓰기 작업 규칙
- 로딩·오류·재시도 UI가 범위에 포함되면 `.agents/skills/model-loadable-ui-state/SKILL.md`

입력이 부족해 테스트 대상, 기대 동작, 성공 기준을 결정할 수 없으면 추측하지 말고 planner 또는 사용자에게 확인한다.

## 작업 절차

1. **작업 가능 상태 확인**
   - 현재 브랜치와 변경 파일을 확인한다.
   - 메인 브랜치(`main`, `master`, `develop`)에서는 테스트 파일을 수정하지 않는다.
   - 다른 작업자의 변경을 되돌리지 않고 승인된 파일 범위만 다룬다.

2. **대상과 기존 패턴 파악**
   - 테스트 대상의 공개 동작, 의존성, 상태 흐름을 읽는다.
   - 같은 모듈의 기존 테스트, Fake, 코루틴 테스트 유틸을 먼저 찾아 재사용한다.
   - 테스트 파일은 대상과 같은 패키지의 `{module}/src/test/.../{Class}Test.kt`를 기본으로 한다. UI 테스트는 모듈의 기존 Android 테스트 구조를 따른다.

3. **시나리오와 레벨 확정**
   - `.codex/docs/test-strategy.md`에 따라 가장 낮고 효과적인 테스트 레벨을 선택한다.
   - 검증할 위험, 정상·실패·경계 시나리오, 제외 범위, 실행 명령을 짧게 정리한다.
   - 낮은 레벨에서 충분히 검증한 규칙을 넓은 테스트에서 반복하지 않는다.

4. **테스트 작성**
   - 구현 세부사항보다 사용자가 관찰할 수 있는 결과를 검증한다.
   - 테스트명은 백틱을 사용한 자연스러운 한국어 문장으로 작성하고 공식 도메인 용어를 쓴다.
   - 조건의 주체와 결과가 드러나게 작성한다. `현재`, `해당`, `대상`, `상세`처럼 문맥에 의존하는 표현은 피한다.
   - 각 테스트에 Given, When, Then 주석을 명시한다.
   - 실제 객체와 Fake를 우선한다. Mock은 특정 외부 기능의 호출 확인이 필수이거나 Fake 작성 비용이 지나치게 클 때만 사용한다.

5. **테스트 도구 적용**
   - JUnit5의 `org.junit.jupiter.api.Test`를 사용한다.
   - Assertion은 AssertJ의 구체적인 메서드를 사용한다.
   - 코루틴은 `kotlinx.coroutines.test.runTest`와 테스트 dispatcher를 사용한다.
   - Flow와 `Channel` 기반 SideEffect는 Turbine으로 수집한다.
   - ViewModel 테스트는 같은 모듈의 기존 `CoroutinesTestExtension` 또는 동등한 유틸을 우선 재사용한다.
   - MockK가 필요하면 의존성 존재 여부를 먼저 확인한다. 새 의존성 추가는 승인된 범위에 있을 때만 수행한다.

6. **좁은 범위부터 검증**
   - 대상 테스트를 먼저 실행한다.
   - 영향 범위에 맞으면 모듈 테스트까지 넓힌다.
   - 새 테스트는 가능하면 반복 실행해 비결정적 실패가 없는지 확인한다.

   ```bash
   ./gradlew :{module}:test --tests "{TestClass}"
   ./gradlew :{module}:test
   ```

   Compose UI 테스트는 실행 기기와 task가 준비된 경우에만 실행한다.

   ```bash
   ./gradlew :{module}:connectedDebugAndroidTest
   ```

   task 이름이 다르면 다음 명령으로 확인한다.

   ```bash
   ./gradlew :{module}:tasks --group verification
   ```

7. **결과 검토와 handoff 작성**
   - 테스트가 의도한 이유로 실패하는지, 이미 통과하는지, 환경 문제로 실행할 수 없는지 구분한다.
   - 불안정한 시간, 공유 상태, 실서버 의존성, 구현 세부사항 결합이 없는지 검토한다.
   - 아래 형식으로 implementer에게 전달한다.

## 출력

````markdown
## handoff_to_implementer

**작성/수정 테스트 파일**
- `{path}` - {검증하는 동작}

**실행 명령**
```bash
./gradlew :{module}:test --tests "{TestClass}"
```

**현재 결과**
- 기대 실패 / 통과 / 실행 불가 중 하나
- 실패 이유 또는 실행할 수 없는 환경 조건
- 구현이 만족해야 하는 통과 조건

**구현 메모**
- 테스트를 통과하기 위한 최소 구현 범위
- 건드리지 말아야 할 파일 또는 따라야 할 기존 패턴
- Mock을 사용했다면 호출 검증이 필요하거나 Fake 작성이 어려웠던 이유
````

## 예외와 주의

- 버그 재현 테스트가 구조적으로 불가능하거나 비용이 과도하면 억지로 작성하지 않는다. 이유, 대체 검증, 남은 위험을 출력에 기록한다.
- UI 또는 E2E 인프라가 없으면 새 인프라를 임의로 도입하지 않는다. 승인된 범위에 따라 낮은 레벨 테스트와 수동 검증으로 제한한다.
- 실제 현재 시각, 테스트 실행 순서, 공유 mutable state, 실서버 상태에 의존하지 않는다.
- 기계적인 DTO와 Domain 변환, 단순 프로퍼티, 프레임워크 자체 동작은 별도 요구가 없으면 테스트하지 않는다.
- `AppResult`는 기존 `AppResult.Success`, `AppResult.Error` 패턴을 따른다.
- 테스트 절차는 이 Skill을 따르되, 테스트 판단 기준은 항상 `.codex/docs/test-strategy.md`를 우선한다.
