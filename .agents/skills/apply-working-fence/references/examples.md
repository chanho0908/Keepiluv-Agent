# Working Fence Examples

## 목차

- [가정과 혼란 드러내기](#가정과-혼란-드러내기)
- [단순한 구현 선택하기](#단순한-구현-선택하기)
- [요청 범위만 수정하기](#요청-범위만-수정하기)
- [검증 가능한 목표 만들기](#검증-가능한-목표-만들기)
- [핵심 질문](#핵심-질문)

## 가정과 혼란 드러내기

피해야 할 예:

```text
사용자가 방식을 정하지 않았는데 JWT 인증을 바로 구현한다.
```

권장 예:

```text
JWT 방식을 원하는 것으로 이해했습니다.
세션 방식은 더 단순하고, OAuth2는 외부 로그인 연동에 적합합니다.
어떤 방식이 제품 요구에 맞는지 확인해 주세요.
```

피해야 할 예:

```text
검증 로직이 ViewModel과 UseCase 중 어디에 있어야 할지 불분명한데 ViewModel을 조용히 선택한다.
```

권장 예:

```text
검증 위치가 불분명합니다.
ViewModel은 파일 수가 적지만 UI에 결합되고, UseCase는 책임이 명확하지만 파일이 늘어납니다.
프로젝트 아키텍처 기준을 확인한 뒤 선택하겠습니다.
```

## 단순한 구현 선택하기

피해야 할 예:

```kotlin
interface DataFetcher<T> {
    suspend fun fetch(): T
}

interface CacheStrategy {
    fun shouldCache(): Boolean
    fun cacheKey(): String
}

class ConfigurableGoalFetcher(
    private val cacheStrategy: CacheStrategy,
    private val errorHandler: ErrorHandler,
    private val retryPolicy: RetryPolicy,
) : DataFetcher<Goal>
```

현재 요구가 목표 조회뿐이라면 다음처럼 단순하게 유지한다.

```kotlin
class GoalRepository(private val api: GoalApi) {
    suspend fun fetchGoal(id: String): Goal = api.fetchGoal(id)
}
```

요청하지 않은 설정도 추가하지 않는다.

```kotlin
// 피해야 할 예
fun loadData(
    cachingEnabled: Boolean = true,
    retryCount: Int = 3,
    timeout: Duration = 30.seconds,
    onProgress: ((Float) -> Unit)? = null,
)

// 권장 예
suspend fun loadData(): Result<Data> = repository.loadData()
```

구현이 200줄인데 같은 동작을 50줄로 명확하게 표현할 수 있다면 줄인다. 판단할 때 "경력 있는 개발자가 과도하게 복잡하다고 볼까?"를 묻는다.

## 요청 범위만 수정하기

사용자가 `userName` null 처리를 요청했다면 이메일 형식까지 바꾸지 않는다.

```kotlin
fun displayUser(user: User) {
    val name = user.name ?: "Unknown"
    println("Name: $name")
    println("Email: ${user.email}")
}
```

특정 import 하나를 지우는 작업에서는 기존의 다른 미사용 import를 함께 삭제하지 않는다. 발견 사실은 보고할 수 있지만, 별도 요청 없이 정리하지 않는다.

기존 코드를 수정할 때는 다음을 지킨다.

- 인접 코드, 주석, 형식을 임의로 개선하지 않는다.
- 고장 나지 않은 코드를 리팩터링하지 않는다.
- 개인 취향보다 기존 코드 스타일을 따른다.
- 이번 변경으로 생긴 미사용 import, 변수, 함수만 제거한다.

## 검증 가능한 목표 만들기

약한 목표:

```text
로그인 버그를 고친다.
```

강한 목표:

```text
빈 비밀번호가 허용되는 로그인 버그를 고친다.
1. 빈 비밀번호면 로그인이 실패하는 테스트를 작성한다.
2. 검증 로직을 구현한다.
3. 대상 테스트가 통과하는지 확인한다.
```

여러 단계의 리팩터링도 단계마다 확인한다.

```text
1. 기존 테스트 실행 -> 현재 기준이 통과하는지 확인
2. loadData 로직을 UseCase로 이동 -> 테스트가 계속 통과하는지 확인
3. 입력 검증을 분리 -> 테스트가 계속 통과하는지 확인
4. 이번 변경으로 생긴 미사용 코드 제거 -> 테스트가 통과하는지 확인
```

## 핵심 질문

| 원칙 | 확인 질문 |
|------|-----------|
| 먼저 생각하기 | 확인해야 할 가정을 조용히 선택하고 있지 않은가? |
| 단순하게 해결하기 | 현재 요구보다 복잡하게 만들고 있지 않은가? |
| 관련된 부분만 바꾸기 | 모든 변경이 요청과 직접 연결되는가? |
| 완료 조건으로 검증하기 | 성공 여부를 독립적으로 확인할 수 있는가? |
