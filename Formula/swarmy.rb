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
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.8/swarmy-0.2.8-universal-apple-darwin.tar.gz"
    sha256 "bcce326b46cac28cfd06f8f1bffb7aeba65d141f188d3e3563d1357e15c30d9d"
  elsif Hardware::CPU.arm?
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.8/swarmy-0.2.8-aarch64-unknown-linux-musl.tar.gz"
    sha256 "374d4c7b533469e884d79709d7f36f481c88731265dd929fa1d8d4aa1b966d3c"
  else
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.8/swarmy-0.2.8-x86_64-unknown-linux-musl.tar.gz"
    sha256 "b8360c5664596e712f7c6a6d27194731ede264801c39d52a0036e4b966cdd7fd"
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
