# Homebrew formula for the tap koorchik/homebrew-tap (`brew install koorchik/tap/swarmy`).
# This file is the source of truth: the release workflow fills in 0.2.1, https://github.com/koorchik/swarmy and the
# @SHA256_*@ checksums from the release's SHA256SUMS (`tools/dist.sh formula`) and commits the
# result to the tap as Formula/swarmy.rb. Do not edit the tap's copy by hand.
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
    sha256 "53345dcaa3248c3b301c4736e07a458f6efe0708a2f5b1b22a806de4e289baff"
  elsif Hardware::CPU.arm?
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.1/swarmy-0.2.1-aarch64-unknown-linux-musl.tar.gz"
    sha256 "54cf88825b06e2167cf6b0fa011f9cbd7788825b90bc657272d517592b0527c4"
  else
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.1/swarmy-0.2.1-x86_64-unknown-linux-musl.tar.gz"
    sha256 "15380ce2fa812c2bc0cdb55f62e6064e2e2bb6b84768e92ee0a1c14699af5179"
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
