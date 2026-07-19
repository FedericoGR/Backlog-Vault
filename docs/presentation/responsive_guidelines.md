# Responsive presentation guidelines

Backlog Vault chooses layout from available width, never solely from the host
platform.

## Breakpoints and bounds

| Token | Width | Intended use |
|---|---:|---|
| `BvBreakpoints.mobile` | 600 | compact padding and single-column composition below this width |
| `navigationRail` | 840 | labeled rail at or above; bottom navigation below |
| `libraryWide` | 900 | library table/sidebar decisions |
| `detailWide` | 920 | wide game detail/form composition |
| `desktop` | 1200 | widest dashboards/workspaces |
| `BvLayout.readableContentWidth` | 960 | forms, Settings and linear workflows |
| `BvLayout.wideContentWidth` | 1200 | dashboards and bulk workspaces |
| `BvLayout.dialogContentWidth` | 720 | maximum dialog work area where applicable |

Use `LayoutBuilder` when a component depends on its parent's constraints. Use
`MediaQuery` only for device-level concerns such as view insets or text scale.
Do not branch on `Platform.isWindows` for visual composition.

## Composition rules

- Narrow phones: one column, bottom navigation, wrapping actions, lazy compact
  lists instead of tables, scrollable forms/dialog content.
- Large phones and medium windows: allow wrapping grids and two-column field
  groups only when labels remain readable.
- Wide windows: constrain prose/forms, use table or side panels when they add
  scanability, and keep primary actions visible.
- Preserve the same ViewModel, filters, validation and navigation at every
  width. Responsive layout must not create a parallel workflow.
- Use `BvPageScaffold` for page padding and maximum width. A feature-private
  constraint is acceptable for a genuinely unique composition.

## Interaction and testing

Use standard Material controls for keyboard, focus, hover and touch targets.
Icon-only actions require localized tooltips. Any critical new composition must
have at least one narrow and one wide widget test; test large text when wrapping
or vertical fit is non-trivial. Avoid screenshot-only assertions.
