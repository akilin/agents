# Integration tests

## Rules
- Do not add integration tests for behavior that can be covered by unit tests.
- For writes, assert the persisted state by reading it back, not only the status code or return value. Unit tests never verify persistence, so this is the only place it is checked.
- Do not test framework-guaranteed behavior, such as global authorization, unless the feature adds custom behavior.
