---
name: tdd
description: Test-driven development. Use when implementing any feature or fixing bugs, before writing implementation code.
---

# Test-Driven Development

TDD is the red → green loop.
Write a failing test first, see it fail for the expected behavioral reason, then write minimal code that makes it pass.
Refactoring is not part of the loop. It belongs to the review stage, not the red → green implementation cycle.

Core principle: If you didn't watch the test fail before writing the implementation, you don't know if it tests the right thing.

Every section applies on every cycle: consult them before and during the loop, not after.

When exploring the codebase, read `GLOSSARY.md` (if it exists) so test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification: "user with valid cart can checkout" tells you exactly what capability exists, and it survives refactors because it doesn't care about internal structure.

## Seams: where tests go

A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything, so agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

Ask: "What's the public interface, and which seams should we test?" Give each proposed seam a one-line note on what it catches and what it misses.

When the shape of that interface is itself in question (how deep the module is, where the seam belongs, what the interface should expose), call the Skill tool with "codebase-design" for the vocabulary. It is the shared source of the module, interface, depth, seam, adapter, leverage and locality terms, and it is a reference to consult, not a session to run.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological**: the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec.
- **Horizontal slicing**: writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead: one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the failing test first, confirm it fails for the expected reason, then write the simplest code that makes it pass. Don't anticipate future tests or add speculative features.
- **Confirm the test fails for the expected behavioral reason.** If it fails due to a non-behavioral problem (typo, import error, compile error, incorrect setup), fix the test and rerun until the failure is meaningful. Do not proceed to Green until the failing test is valid.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to the review stage, not the red → green implementation cycle.

## Definition of done

Done means all of these are true:

- Every behavior you implemented went through the loop in this order: you wrote the test, watched it fail for the expected behavioral reason, wrote the simplest code that makes it pass, then watched it pass.
- No implementation code exists beyond what a failing test required.

A test written after its implementation does not count, even if it passes, because it never showed it could fail. If you find that you wrote code before its test, the slice is not done. Revert or stash that code, run the test and watch it fail for the expected reason, then restore the code and watch the test pass.
