# Homebrew formula for the tap koorchik/homebrew-tap (`brew install koorchik/tap/swarmy`).
# This file is the source of truth: the release workflow fills in its placeholders (the version,
# the repository and the checksums from the release's SHA256SUMS, `tools/dist.sh formula`) and
# commits the result to the tap as Formula/swarmy.rb. Do not edit the tap's copy by hand.
class Swarmy < Formula
  desc "Live swarm, spend and limits of Claude Code, Antigravity and Codex agents"
  homepage "https://github.com/koorchik/swarmy"
  license any_of: ["MIT", "Apache-2.0"]

  # `brew install --HEAD koorchik/tap/swarmy` builds the main branch from source.
  head do
    url "https://github.com/koorchik/swarmy.git", branch: "main"
    depends_on "rust" => :build
  end

  # Prebuilt static binaries: one universal binary for macOS (Apple silicon and Intel), musl
  # builds for Linux.
  if OS.mac?
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.1/swarmy-0.2.1-universal-apple-darwin.tar.gz"
    sha256 "a4c430980441aabd9696cc5697b617f977edc0051ef57e81e27beab087d80ecf"
  elsif Hardware::CPU.arm?
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.1/swarmy-0.2.1-aarch64-unknown-linux-musl.tar.gz"
    sha256 "38eff1d3700aa1d244387f1f8e19d730def1594a95ae9c87acd173a3d324b169"
  else
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.1/swarmy-0.2.1-x86_64-unknown-linux-musl.tar.gz"
    sha256 "459a7dd3fa2f1ce6abc70d53d94c2c53396da4441b95450ae2cccacc3502497b"
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
      (man1/"swarmy.1").write Utils.safe_popen_read(bin/"swarmy", "man")
      generate_completions_from_executable(bin/"swarmy", "completions")
    else
      bin.install "swarmy"
      man1.install "man/swarmy.1"
      bash_completion.install "completions/swarmy.bash" => "swarmy"
      zsh_completion.install "completions/_swarmy"
      fish_completion.install "completions/swarmy.fish"
    end
  end

  test do
    assert_match(/^swarmy \d+\.\d+\.\d+/, shell_output("#{bin}/swarmy --version"))
    assert_match "swarmy", shell_output("#{bin}/swarmy completions bash")
    assert_match "swarmy", shell_output("#{bin}/swarmy man")
  end
end
