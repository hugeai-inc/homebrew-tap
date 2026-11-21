# Homebrew formula for mc-cli, the Mission Control command-line (the `mc` command).
# Prebuilt binaries; not built from source. Install:
#
#   brew tap hugeai-inc/tap
#   brew install mc-cli
#
# The tap repository is hugeai-inc/homebrew-tap (Homebrew's "hugeai-inc/tap").
# Archives are published on this public repository because hugeai-inc/mission-control is private.
class McCli < Formula
  desc "Run a hundred agents like you run one: the Mission Control command-line"
  homepage "https://github.com/hugeai-inc/mission-control"
  version "0.5.0"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/hugeai-inc/homebrew-tap/releases/download/mc-cli%2Fv0.5.0/mc-cli_0.5.0_darwin_arm64.tar.gz"
      sha256 "152a9303cb232c582a7f0f9487f94ba5eacd44e305303dc72987c35812aa939b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/hugeai-inc/homebrew-tap/releases/download/mc-cli%2Fv0.5.0/mc-cli_0.5.0_darwin_amd64.tar.gz"
      sha256 "59a2d39679ca6960c5a5678afc965a4dc20d7ecd68e346ab9fb2e7c762b6a381"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/hugeai-inc/homebrew-tap/releases/download/mc-cli%2Fv0.5.0/mc-cli_0.5.0_linux_arm64.tar.gz"
      sha256 "19f6f7ab31495018c64e2cf16b24240142fbde8ea80589a970e5a58b1535ca0d"
    end
    if Hardware::CPU.intel?
      url "https://github.com/hugeai-inc/homebrew-tap/releases/download/mc-cli%2Fv0.5.0/mc-cli_0.5.0_linux_amd64.tar.gz"
      sha256 "8f692dceaa0193442fd3aeae89d0e7bb38ccf74d0e2686c0d6cbbb6eef4e3b54"
    end
  end

  conflicts_with "midnight-commander", because: "both install an `mc` binary"

  def install
    bin.install "mc"
    generate_completions_from_executable(bin/"mc", shell_parameter_format: :cobra)
  end

  test do
    assert_match "mc-cli #{version}", shell_output("#{bin}/mc version --plain")
    assert_match '"ok": true', shell_output("#{bin}/mc config --json")
    assert_match "unknown command", shell_output("#{bin}/mc nope --plain 2>&1", 1)
  end
end
