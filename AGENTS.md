# Repository Guidelines

CoreWeave fork of the Oriflame Backstage plugins. A Yarn workspaces monorepo
that publishes plugin packages to npm under the `@coreweave` scope and ships a
demo Backstage app used for local dev and end-to-end tests.

## This is a PUBLIC repository

This repo is published at `github.com/coreweave/oriflame-backstage-plugins`
with `PUBLIC` visibility, and the plugins under `plugins/` ship to the public
npm registry. **Nothing CoreWeave-internal may be added** — not in code,
docs, comments, fixtures, commit messages, PR descriptions, or changesets.
That includes:

- Internal hostnames, URLs, IPs, dashboards, or runbooks.
- References to internal-only repos (e.g. anything under `coreweave/` on
  GitHub with `INTERNAL` or `PRIVATE` visibility), internal Slack channels,
  Jira/Linear projects, PagerDuty services, or oncall rotations.
- Customer names, account IDs, cluster names, or any operational data.
- Employee names beyond what's already attributed via public git history.
- Secrets, tokens, credentials, or paths into internal infra.

Before committing, scan the diff for these. If you need to reference an
internal concept to explain something here, generalize it (describe the
shape, not the system). When in doubt, keep it out.

## Layout

- `plugins/` — published plugins (currently just `score-card`, published as
  `@coreweave/backstage-plugin-score-card`). New plugins go here. See
  `plugins/score-card/AGENTS.md` for plugin-local guidance, including the
  shape of the JSON files the score-card plugin consumes (also documented
  for end users in `plugins/score-card/README.md` § "JSON data format").
- `packages/app` — private demo Backstage frontend used for `yarn dev` and as
  the host for Playwright e2e tests in `packages/app/e2e-tests/`.
- `packages/backend` — private demo Backstage backend that pairs with `app`.
- `packages/entities` — sample catalog entities and templates wired into the
  demo app; `test-entity.yaml` is the entity used by e2e tests.
- `.changeset/` — pending changesets that drive version bumps and changelogs.
- `.github/workflows/` — CI, release-prepare, release-publish, and Renovate
  changeset automation.
- `scripts/` — release helpers and the Apache-2.0 copyright header template
  enforced on every source file.

## Toolchain

- Node `20.x`, Yarn `4.1.1` (Berry — `.yarnrc.yml`, do not run npm).
- Backstage CLI (`@backstage/cli`) for build/test/lint at the package level;
  `backstage-cli repo …` runs across the workspace.
- TypeScript `~5.4`, React 18, Material UI v4 (Backstage convention).
- Jest + React Testing Library for unit tests; Playwright for e2e.
- Spotify Prettier config; ESLint with `eslint-plugin-notice` enforcing the
  Apache-2.0 header from `scripts/copyright-header.txt` — every new
  `.ts`/`.tsx`/`.js` file must start with that header or lint will fail.

## Common commands (run from repo root unless noted)

- `yarn install` — install workspace dependencies.
- `yarn dev` — run app + backend + a static fixture server concurrently.
- `yarn build` — `backstage-cli repo build --all`.
- `yarn tsc` / `yarn tsc:full` — typecheck (`tsc:full` cleans first, used in CI).
- `yarn test` — Jest across the workspace.
- `yarn test <name>` — scope to a package, e.g. `yarn test score-card`.
- `yarn test:e2e` — Playwright; will start app/backend automatically via
  `playwright.config.ts`. CI runs `yarn playwright install --with-deps` first.
- `yarn lint` — lint changed files since `origin/main`; `yarn lint:all` for
  the whole repo.
- `yarn fix` — `backstage-cli repo fix` (auto-fix lint/format).
- `yarn lint:type-deps` — verifies declared `dependencies` vs. actual usage;
  CI fails if out of sync.
- `yarn new` — scaffold a new plugin under the `@coreweave` scope at version `0.0.0`.

## Conventions

- Functional React components, hooks named `useFoo`, components `PascalCase`.
- Tests live next to the code as `*.test.ts(x)`; prefer `findBy*` / `waitFor`
  over fixed timeouts.
- Keep API clients and types under each plugin's `src/api/`, configuration
  schemas in `config.d.ts` (declared via `configSchema` in `package.json`).
- Don't hardcode secrets; read from Backstage config (`app-config.yaml`).

## Releases (changesets)

1. Make changes in a branch.
2. Run `yarn changeset`, pick affected published packages, choose `patch` /
   `minor` / `major`, write a short user-facing note, commit the generated
   `.changeset/*.md`.
3. Open a PR. CI (`.github/workflows/ci.yml`) runs config check, lint,
   `tsc:full`, build, type-deps check, Jest, and Playwright.
4. On merge to `main`, `release-prepare.yml` opens a "Release new version(s)"
   PR that bumps versions and updates `CHANGELOG.md`.
5. Merging that PR triggers `release-publish.yml`, which tags, creates a
   GitHub release, and publishes changed plugins to npm.

Renovate-generated PRs get changesets auto-added by `renovate-changesets.yml`.

## Pull requests

- Follow the template in `.github/PULL_REQUEST_TEMPLATE.md`: tests added,
  changeset included (when a published package changed), screenshots for UI
  changes, docs updated.
- Conventional-style commit subjects are used in history (`feat:`, `fix:`,
  `chore:`, `test:`, `ci:`); keep them imperative and scoped where useful
  (e.g. `fix(score-card): …`).
- This fork's `main` is the default base; upstream is Oriflame's repo but we
  release independently under `@coreweave`.

## Commit signing

Commits in this repo are GPG-signed. If a commit fails with
`gpg failed to sign the data` / `failed to write commit object`, the GPG
agent is locked or the key is unavailable. Retry the same commit **without**
the signature (`git commit --no-gpg-sign …` or with `commit.gpgsign=false`
just for that command), keep working, and at the end of the session remind
the user to re-sign the unsigned commits (e.g.
`git rebase --exec 'git commit --amend --no-edit -S' <base>`).
Do not skip hooks, only the signature.

## Gotchas

- `pull_request_target` is used in CI so forks can run the build; don't add
  steps that execute untrusted PR code with elevated permissions.
- `packages/*` are `"private": true` and intentionally not published — only
  things under `plugins/` ship to npm.
- The `notice/notice` ESLint rule **replaces** non-matching headers, so a
  wrong header in a new file will be silently rewritten on `yarn fix`; double
  check after running it.
- Material UI v4 is pinned; don't pull in v5 components without a coordinated
  upgrade — Backstage core components still rely on v4.
