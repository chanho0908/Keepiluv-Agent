---
name: andrej-karpathy-skills
description: LLM 코딩 모범 사례 - 범용 가이드라인 (프로젝트 무관)
---

# LLM Coding Best Practices

> **적용 대상:** 모든 LLM 기반 코드 생성 작업

**Tradeoff:** These guidelines bias toward caution over speed. Use judgment for trivial tasks.

---

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### Examples

```
❌ Silent Assumption:
"I'll implement user authentication using JWT tokens."
(User never mentioned JWT - assumption made silently)

✅ Explicit Assumption:
"I'm assuming you want JWT-based authentication.
Alternative approaches:
1. Session-based auth (simpler, but less scalable)
2. OAuth2 (more complex, but better for third-party integration)

Which approach fits your needs?"
```

```
❌ Hidden Confusion:
"I'll add the validation logic to the ViewModel."
(Uncertain whether validation belongs in ViewModel or UseCase, but didn't ask)

✅ Surface Confusion:
"I'm unclear where validation should live:
- Option A: ViewModel (simpler, but UI-coupled)
- Option B: UseCase (cleaner architecture, but more files)

What's your preference given this project's architecture?"
```

---

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: **"Would a senior engineer say this is overcomplicated?"** If yes, simplify.

### Examples

```kotlin
// ❌ Overcomplicated (200 lines)
interface DataFetcher<T> {
    suspend fun fetch(): T
}

interface CacheStrategy {
    fun shouldCache(): Boolean
    fun getCacheKey(): String
}

class ConfigurableGoalFetcher(
    private val cacheStrategy: CacheStrategy,
    private val errorHandler: ErrorHandler,
    private val retryPolicy: RetryPolicy
) : DataFetcher<Goal> {
    // 150 more lines of abstraction...
}

// ✅ Simple (10 lines)
class GoalRepository(private val api: GoalApi) {
    suspend fun fetchGoal(id: String): Goal = api.getGoal(id)
}
```

```kotlin
// ❌ Unnecessary Flexibility
fun loadData(
    cachingEnabled: Boolean = true,
    retryCount: Int = 3,
    timeout: Duration = 30.seconds,
    onProgress: ((Float) -> Unit)? = null
) { ... }

// ✅ Just What's Needed
suspend fun loadData(): Result<Data> = repository.getData()
```

---

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

### When Editing Existing Code

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

### When Your Changes Create Orphans

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

**The test:** Every changed line should trace directly to the user's request.

### Examples

```kotlin
// ❌ Non-Surgical Change
// User asked: "Add null check for userName"

fun displayUser(user: User) {
-   println("Name: ${user.name}")  // Changed formatting (unrelated)
-   println("Email: ${user.email}") // Improved adjacent code (unrelated)
+   val name = user.name ?: "Unknown"  // Added null check (requested)
+   println("Name: $name")
+   println("Email: ${user.email.lowercase()}")  // Added lowercase (unrequested)
}

// ✅ Surgical Change
// User asked: "Add null check for userName"

fun displayUser(user: User) {
-   println("Name: ${user.name}")
+   val name = user.name ?: "Unknown"
+   println("Name: $name")
    println("Email: ${user.email}")  // Left unchanged
}
```

```kotlin
// ❌ Over-Cleanup
// User asked: "Remove unused import X"

- import com.example.X  // Requested removal
- import com.example.Y  // Pre-existing dead code (removed without asking)
- import com.example.Z  // Pre-existing dead code (removed without asking)

// ✅ Only Clean Your Mess
// User asked: "Remove unused import X"

- import com.example.X  // Requested removal
  import com.example.Y  // Left unchanged (not your mess)
  import com.example.Z  // Left unchanged (not your mess)

// (Mention to user: "Note: Y and Z also appear unused. Should I remove them?")
```

---

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

### For Multi-Step Tasks: State a Brief Plan

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

**Strong success criteria** let you loop independently.
**Weak criteria** (e.g., "make it work") require constant clarification.

### Examples

```
❌ Weak Goal:
"Fix the login bug."
(No clear success criteria - what confirms it's fixed?)

✅ Strong Goal:
"Fix the login bug where empty passwords are accepted.
Success criteria:
1. Write test: empty password → login fails
2. Implement validation
3. Verify: test passes"
```

```
❌ Vague Plan:
"Refactor the ViewModel."
(No verification steps)

✅ Verifiable Plan:
"Refactor ViewModel to extract business logic to UseCase.
1. Run existing tests → verify: all pass (baseline)
2. Extract loadData() to LoadDataUseCase → verify: tests still pass
3. Extract validation to ValidateInputUseCase → verify: tests still pass
4. Remove unused code → verify: tests still pass"
```

---

## Summary

| Principle | Key Question |
|-----------|--------------|
| **Think Before Coding** | "Am I making assumptions I should clarify?" |
| **Simplicity First** | "Would a senior engineer call this overengineered?" |
| **Surgical Changes** | "Does every change trace directly to the request?" |
| **Goal-Driven Execution** | "Can I verify success independently?" |

---

## When to Relax These Guidelines

- **Trivial tasks**: Single-line fixes, obvious changes
- **Prototyping**: Explicitly marked as experimental
- **User explicitly requests**: "Add flexibility for future use"

**Default stance:** Err on the side of caution. Quality > Speed.
