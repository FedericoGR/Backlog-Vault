# Presentation component guidelines

## Shared components

Place a component in `core/design_system` only when it has multiple real
consumers and no feature dependency.

- `BvPageScaffold`: routed page chrome, responsive padding and optional width.
- `BvLoadingState`: localized, centered indeterminate loading.
- `BvEmptyState`: feature-owned empty/no-result copy and optional action.
- `BvErrorState`: safe localized error plus optional paired retry action.
- `BvAsyncActionButton`: primary async action with double-submit prevention and
  busy semantics.
- `BvFeedback`: exactly one transient message for an explicit action; never pass
  an exception or secret.
- `BvProgressPanel`: progress and an optional paired localized cancel action.
- `BvPanel`, `BvSurface`, `BvSection`, `BvChip`, `BvStatusBanner`: existing
  visual primitives based on theme and spacing tokens.

Do not add a global component for a one-feature dialog, card or button. Keep it
private in the feature, or in a `part` when it is a cohesive section of one
owning library.

## Async and feedback rules

- Disable an async action before awaiting it and restore state in `finally`.
- Check `mounted` before using state/context after `await`.
- Picker cancellation is a neutral result.
- Show one success or failure message, not a dialog and snackbar together.
- Typed destructive confirmation remains feature-owned and localized.
- Convert infrastructure/domain failures to safe copy before rendering.
- Loading, empty, filtered-empty, missing credentials and provider failure are
  distinct states.

## Styling and localization

Use `ThemeData`, `ColorScheme`, `BvThemeExtension`, `BvSpacing`, `BvRadii`,
`BvBreakpoints` and `BvLayout`. A one-off dimension may remain local when it
expresses content geometry rather than a repeated token. All functional copy
comes from `AppLocalizations`; provider names and persisted domain values may
remain stable identifiers while their visible labels are localized.

## File division

Divide by responsibility or workflow stage. Dart `part` files are appropriate
when private helpers must share one page state and exposing public APIs would be
worse. Avoid a file per control. Record remaining files above 300 lines and the
reason they remain cohesive.
