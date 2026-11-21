# Huge AI Homebrew Tap

This repository is the public Homebrew tap for [Mission Control](https://github.com/hugeai-inc/mission-control) and other Huge AI tools.

Homebrew's short name for this repository is `hugeai-inc/tap`.

## Install mc-cli

```sh
brew install hugeai-inc/tap/mc-cli
mc version --plain
```

Or:

```sh
brew tap hugeai-inc/tap
brew install mc-cli
```

The formula installs a prebuilt `mc` binary for macOS and Linux (amd64 and arm64). It conflicts with Homebrew's `midnight-commander` package, which also installs an `mc` command.

### Curl installer (no Homebrew)

```sh
curl -fsSL https://raw.githubusercontent.com/hugeai-inc/homebrew-tap/main/install.sh | sh
```

A specific version:

```sh
curl -fsSL https://raw.githubusercontent.com/hugeai-inc/homebrew-tap/main/install.sh | sh -s -- --version v0.5.0
```

The installer verifies the SHA256 checksum before installing to `/usr/local/bin` (or `$PREFIX/bin`).

## What's in this tap

- **mc-cli**: The Mission Control command-line tool for managing agent teams

## Releases

Each `mc-cli` release is built and signed in the private `hugeai-inc/mission-control` repository. Because those assets are not public, the archives, `SHA256SUMS`, and signature bundle are published here (`mc-cli/vX.Y.Z`) so Homebrew and the curl installer can fetch them.

GitHub artifact attestations are created by `.github/workflows/attest-release.yml` when a release is published on this repository.

## Verification

```sh
shasum -a 256 -c SHA256SUMS

# Cosign keyless signature of SHA256SUMS (when SHA256SUMS.sigstore.json is attached)
cosign verify-blob --bundle SHA256SUMS.sigstore.json \
  --certificate-identity-regexp '^https://github.com/(hugeai-inc|stevenzeiler)/mission-control/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  SHA256SUMS

gh attestation verify mc-cli_0.5.0_darwin_arm64.tar.gz --repo hugeai-inc/homebrew-tap
```
