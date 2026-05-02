# Contributing to the CoreWeave fork of the Oriflame Backstage plugins

This is the CoreWeave fork of [Oriflame/backstage-plugins](https://github.com/Oriflame/backstage-plugins), released independently under the `@coreweave` npm scope. Contributions are welcome — see the issue tracker for [this repository](https://github.com/coreweave/oriflame-backstage-plugins/issues).

We aim to stick as closely as possible to the [Backstage contribution guidelines](https://github.com/backstage/backstage/blob/master/CONTRIBUTING.md). If something is not covered in this document, assume that the appropriate Backstage guideline applies.

## Types of Contributions

This repository hosts the plugins we maintain — contributions are welcome both at the repo level and within individual plugins.

### Report bugs

File a bug as an issue [here](https://github.com/coreweave/oriflame-backstage-plugins/issues/new?assignees=&labels=bug&template=bug_template.md).

### Fix bugs or build new features

Look through the GitHub issues for bugs or problems other users are reporting. If you're hitting one yourself, feel free to contribute a fix.

### Submit feedback

The best way to send feedback is to file [an issue](https://github.com/coreweave/oriflame-backstage-plugins/issues/new).

If you're proposing a feature:

- Explain in detail how it would work.
- Explain the wider context — what are you trying to achieve?
- Keep the scope as narrow as possible to make it easier to implement.

### Write E2E tests

As the number of plugins grows, so does the importance of good E2E tests. E2E tests live in `packages/app/e2e-tests/` with one file per plugin; follow that pattern when adding tests for a new plugin. The shared `test-entity.yaml` under `packages/entities` is intended for this purpose.

[Playwright](https://playwright.dev/) is the test engine. To run e2e tests locally you'll need [browser dependencies installed](https://playwright.dev/docs/browsers#install-system-dependencies) — typically `npx playwright install-deps`.

## Get Started

So… ready to jump in? Let's go. 💯 👏

Start by reading the repository [README](./README.md) to get set up for local development.

## Commits signing

We require all commits to be signed. See [signing-commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits) and [telling-git-about-your-signing-key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key).

Set the signing identity on the GitHub-noreply email associated with your account, e.g. `git config user.email <user>@users.noreply.github.com`.

## Coding Guidelines

We use the `backstage-cli` to build, serve, lint, test and package all plugins. The [Backstage coding guidelines](https://github.com/backstage/backstage/blob/master/CONTRIBUTING.md#coding-guidelines) apply.

## Creating Changesets

We use [changesets](https://github.com/changesets/changesets) to drive releases. Include a changeset with any pull request that touches a published package — this is what produces the version bump and the `CHANGELOG.md` entry.

### When to use a changeset

Any time a patch, minor, or major change (per [Semantic Versioning](https://semver.org)) is made to a published package under `plugins/`. Changesets aren't needed for documentation, build utilities, or workspace-private packages (anything in `packages/*`).

### How to create a changeset

1. Run `yarn changeset` (or `make changeset`).
2. Select the packages you want to include.
3. Choose the impact: `major` for breaking changes, `minor` for new features, `patch` for bug fixes / dependency bumps.
4. Write a short user-facing note. See [examples of well-written changesets](https://backstage.io/docs/getting-started/contributors#writing-changesets).
5. Commit the generated `.changeset/*.md` and push it on your PR branch.

For more detail see [adding a changeset](https://github.com/changesets/changesets/blob/main/docs/adding-a-changeset.md).

## Releasing plugins and packages

Releases are fully automated via `.github/workflows/release.yml`, which uses [`changesets/action`](https://github.com/changesets/action). The flow:

1. PRs land on `main` carrying `.changeset/*.md` files.
2. Push to `main` triggers `release.yml`. With unreleased changesets present, the workflow opens (or updates) a **Release new version(s)** PR that bumps `package.json` versions, updates each `CHANGELOG.md`, and removes the consumed `.changeset/*.md` files.
3. Merging the **Release new version(s)** PR triggers `release.yml` again. With no remaining changesets and bumped versions detected, the workflow:
   - Builds the workspace (`yarn tsc:full && yarn backstage-cli repo build`).
   - Publishes each non-private workspace to npm (`--access public --tolerate-republish`).
   - Creates a GitHub release per published package.

Renovate-bot PRs that bump dependencies get a `.changeset/*.md` generated automatically by `.github/workflows/renovate-changesets.yml`, so they flow through the same release path.

### Prerequisites

Before the first release works end to end, the repository needs:

- `NPM_TOKEN` repository secret — an [automation-style token](https://docs.npmjs.com/creating-and-viewing-access-tokens) with publish access to the `@coreweave` npm scope. Set under **Settings → Secrets and variables → Actions**.
- Each published package's `package.json` must have `"publishConfig": { "access": "public" }` (already configured for `@coreweave/backstage-plugin-score-card`).
- The `@coreweave` org on npm must have at least one maintainer with the publish role; the automation token must belong to that maintainer.

The `GITHUB_TOKEN` used by `release.yml` is the workflow-scoped one issued by Actions; no extra setup needed.

### Manual release

CI is the supported path. If CI is unavailable and you need to publish from a local checkout:

```bash
# 1. Apply pending changesets locally (bumps versions, regenerates yarn.lock).
yarn release

# 2. Build everything that ships.
yarn tsc:full
yarn backstage-cli repo build

# 3. Auth Yarn to npm.
yarn config set -H 'npmAuthToken' "<your-npm-automation-token>"

# 4. Publish.
yarn workspaces foreach --all --no-private --verbose npm publish --access public --tolerate-republish

# 5. Commit the version bumps + lock and push to main.
git add -A && git commit -m 'chore: release packages' && git push
```

After a manual release, push the matching `vX.Y.Z` tags by hand if you want them on GitHub — `release.yml` handles tagging automatically when it does the publish.

## Code of Conduct

We follow the [Spotify FOSS code of conduct](https://github.com/backstage/backstage/blob/master/CODE_OF_CONDUCT.md) used by the Backstage project.

If you experience or witness unacceptable behavior — or have any other concerns — please report it by [opening an issue](https://github.com/coreweave/oriflame-backstage-plugins/issues/new) or contacting a maintainer privately.

## Security Issues?

See [SECURITY.md](./SECURITY.md).
