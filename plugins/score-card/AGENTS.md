# Repository Guidelines

## Project Structure & Module Organization
- `src/` contains plugin code; notable areas include `components/` (React views such as `ScoreCardTable` and `EntityScoreCardTable`), `api/` (clients and types), and `config/` (display policies and helpers).
- Tests live next to implementation files as `*.test.ts(x)`; sample fixtures are in `sample-data/`.
- Entry points for the plugin sit in `src/index.ts` and `src/plugin.ts`; shared helpers live under `src/components/ScoreCard/helpers/`.

## Build, Test, and Development Commands
- `yarn install` — install dependencies for the workspace.
- `yarn test score-card` — run the score-card plugin test suite (used for React/TypeScript unit tests).
- `yarn lint` — run lint checks if configured in the workspace; fix lint issues before sending PRs.
- When unsure, prefer running commands from `plugins/score-card/` to scope work to this plugin.

## Coding Style & Naming Conventions
- TypeScript + React; prefer functional components and hooks.
- Indentation is 2 spaces; keep lines readable and avoid trailing whitespace.
- Name components in `PascalCase`, hooks in `camelCase` prefixed with `use`, and test descriptions in clear, behavior-focused language.
- Use existing helpers (e.g., `scoreToColorConverter`, `getWarningPanel`, `useDisplayConfig`) instead of duplicating logic.

## Testing Guidelines
- Use Jest with React Testing Library (`render`, `findByTestId`, etc.) and `act` for async state.
- Keep tests colocated with the code under test; mirror file names (e.g., `ScoreCardTable.test.tsx`).
- Prefer `findBy*`/`waitFor` for async UI assertions; avoid brittle timing assumptions.
- Run `yarn test score-card` before submitting changes; add focused tests for new behavior and edge cases.

## Commit & Pull Request Guidelines
- Follow the existing commit style seen in history: concise imperative messages (e.g., `feat: Add score table display policies`).
- For PRs, include a short summary of changes, testing performed (`yarn test score-card`), and any screenshots for UI changes.
- Link to relevant issues or tickets and call out any known limitations or follow-up items.

## Security & Configuration Tips
- Keep API clients and configuration under `src/api/` and `src/config/`; avoid hardcoding secrets or tokens.
- Use environment variables or Backstage configuration for credentials; never commit sensitive data.

## Score JSON data shape

The plugin is a thin renderer over JSON files produced by an external pipeline.
Authoritative shape lives in [`src/api/types.ts`](./src/api/types.ts);
human-readable spec is in the plugin [README's "JSON data format" section](./README.md#json-data-format).
Reference fixtures: [`sample-data/all.json`](./sample-data/all.json) (board) and
[`sample-data/default/<kind>/<name>.json`](./sample-data/default/) (detail).

When changing types, parsing, or rendering, keep the following invariants in
mind — they are all easy to break unintentionally:

- **The hierarchy is fixed at 3 levels — areas do not nest.**
  `EntityScore → areaScores[] → scoreEntries[]`, full stop.
  `EntityScoreArea` has no `areaScores` of its own and `EntityScoreEntry` is
  a leaf. The renderers (`ScoreCardTable`, `getScoreTableEntries`,
  `areaColumn`) only walk those two levels — adding nested fields to the
  types without touching the column-per-area table layout produces JSON that
  silently doesn't render. Producers needing sub-grouping must flatten with
  title prefixes (e.g. `L1: …`, `L2: …` entry titles inside one area).
  Don't accept "let's just nest areas" as a quick fix — it's a type change
  *and* a renderer rewrite.
- **Two URL shapes off one base.** `ScoringDataJsonClient.getAllScores` fetches
  `<jsonDataUrl>all.json` and expects an array; `getScore(entity)` fetches
  `<jsonDataUrl><namespace>/<kind>/<name>.json` (lower-cased, `namespace`
  defaulting to `default`) and expects a single object. Don't change one
  without the other.
- **Per-entity override via annotation.** `scorecard/jsonDataUrl` on a catalog
  entity bypasses path construction entirely — the URL is fetched verbatim,
  for both the detail view and (when an entity is in scope) the table view.
  Tests for URL construction must cover the annotation branch.
- **Entity join is by name.** `EntityScore.entityRef.name` is matched against
  catalog `metadata.name`. Owner/reviewer extension in `extendEntityScore`
  depends on this — breaking the join silently drops owner chips and avatars.
- **`fetchAllEntities` toggles two very different catalog calls.** Off (the
  default since #5) uses `catalogApi.getEntitiesByRefs` to avoid the
  `414 Request-URI Too Large` failure mode on large catalogs; on, it pulls
  every entity and filters client-side. Both code paths must keep working.
- **`scoreSuccess` is the only thing that drives color.** `scoreToColorConverter`
  switches on the `ScoreSuccessEnum` values; anything outside the enum
  (including `"unknown"`, arbitrary strings, or arrays — yes, the sample data
  has an array) falls through to neutral grey. Don't add new color states
  without extending both the enum and the converter.
- **`scoreLabel` overrides `scorePercent` visually** when present, but isn't
  used for sorting or filtering — sort/filter logic should stay on the
  numeric `scorePercent`.
- **`details` is Markdown.** It's rendered through the same Markdown path as
  Backstage docs; if you change the renderer, smoke-test with the sample data
  (it has links, bold, and long paragraphs).
- **`wikiLinkTemplate` is `{field}` interpolation over `EntityScoreEntry`.**
  Any new field on the entry type becomes available as a template variable —
  keep field names stable across producer regenerations.
- The `@template.json` file in `sample-data/` carries fields the **plugin does
  not consume** (`howToScore`, `scoreChoices`, `scoreChecks`). Those are inputs
  to the producer pipeline; ignore them when reasoning about render code.
