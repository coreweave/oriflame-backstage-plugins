# oriflame-backstage-plugins

CoreWeave fork of the [Oriflame Backstage plugins](https://github.com/Oriflame/backstage-plugins). Plugins under `plugins/` are published to npm under the `@coreweave` scope; `packages/app` and `packages/backend` are a private demo Backstage instance used for local dev and Playwright e2e tests.

## Getting started

Plugins live in `./plugins`. You can run a plugin in isolated mode by navigating to its folder and running `yarn dev` or `yarn start:dev` (see each plugin's README). To run the demo Backstage host with all plugins integrated, run `yarn dev` from the repo root. `yarn test` runs the Jest suite. For more information see [CONTRIBUTING.md](./CONTRIBUTING.md).

Prerequisites are [the same as for Backstage](https://backstage.io/docs/getting-started/#prerequisites). Please use Node.js `20.x`.

## List of plugins

Name | Version | Description
---------|----------|----------
 [score-card](https://github.com/coreweave/oriflame-backstage-plugins/blob/main/plugins/score-card/README.md) | [![npm version](https://badge.fury.io/js/@coreweave%2Fbackstage-plugin-score-card.svg)](https://badge.fury.io/js/@coreweave%2Fbackstage-plugin-score-card) | Visualizes service-maturity scoring data so teams can discuss what to focus on next.

## Workflows

GitHub Actions handle CI, the version-bump PR, and npm publishing. The release flow is the standard [`changesets/action`](https://github.com/changesets/action) pattern: a single `release.yml` opens (or updates) a "Release new version(s)" PR whenever there are unreleased changesets on `main`, and publishes to npm + creates GitHub releases when that PR merges.

In overview:

- Open a PR with your code changes plus a `yarn changeset` entry. [CI](#ci-workflow) runs lint, type-check, build, tests, and Playwright e2e.
- On merge to `main`, [Release](#release-workflow) opens (or updates) a `Release new version(s)` PR that bumps versions, regenerates changelogs, and clears `.changeset/`.
- When that PR merges, the same workflow publishes the bumped packages to npm and creates a GitHub release per package.

Manual publishing is documented in [CONTRIBUTING.md](./CONTRIBUTING.md#manual-release).

### CI workflow

[![CI pipeline](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/ci.yml/badge.svg)](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/ci.yml)

Source: `.github/workflows/ci.yml`

Runs on `pull_request_target` and on push to `main`: config check, lint, `tsc:full`, build, type-deps verify, Jest, and Playwright e2e.

### Release workflow

[![Release](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/release.yml/badge.svg)](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/release.yml)

Source: `.github/workflows/release.yml`

Runs on push to `main`. If there are unreleased changesets, opens or updates a `Release new version(s)` PR. If the previous push was the merge of that PR (no remaining changesets, package versions bumped), publishes the changed packages to npm and creates a GitHub release per package.

Requires the `NPM_TOKEN` repository secret with publish access to `@coreweave/*`.

### Renovate: Validate configuration

[![Renovate: Validate configuration](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/renovate-validation.yml/badge.svg)](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/renovate-validation.yml)

Source: `.github/workflows/renovate-validation.yml`

Runs on PRs that touch `renovate.json` to validate the configuration.

### Renovate: Generate changeset

[![Renovate: Generate changeset](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/renovate-changesets.yml/badge.svg)](https://github.com/coreweave/oriflame-backstage-plugins/actions/workflows/renovate-changesets.yml)

Source: `.github/workflows/renovate-changesets.yml`

Runs on Renovate-bot PRs that bump `yarn.lock`, auto-generating a `.changeset/*.md` so the bumped packages get a patch release.

## Thank you note

When creating this repository (pipelines, e2e tests, monorepo setup...) we were inspired a lot by a following repository [roadie-backstage-plugins](https://github.com/RoadieHQ/roadie-backstage-plugins).
