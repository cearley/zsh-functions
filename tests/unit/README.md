# Unit Tests

This directory is reserved for unit tests targeting complex algorithmic logic in helper functions.

## Current Status

**No unit tests currently exist** because all functions in `autoload/` are thin shell wrappers around external commands. Integration tests provide optimal coverage for this type of code.

## When to Add Unit Tests

Add unit tests to this directory when functions develop:

1. **Complex parsing logic** (e.g., semantic version comparison with prerelease/build metadata)
2. **Algorithmic code** (e.g., calculations, data transformations)
3. **Stateful logic** (e.g., multi-step state machines)
4. **Expensive operations** that need to be mocked for performance

## Guidelines

See [docs/TESTING_STRATEGY.md](../../docs/TESTING_STRATEGY.md) for detailed guidelines on when and how to add unit tests.

**Key principle:** Test at the appropriate level of abstraction for the code's nature.

- Thin shell wrappers → Integration tests
- Complex algorithms → Unit tests
- Hybrid functions → Both, targeting the right layers
