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
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.7/swarmy-0.2.7-universal-apple-darwin.tar.gz"
    sha256 "42880bcf4ffecd106fee74605d24b9366bebebf8e3b53c23c0fac66dced772c5"
  elsif Hardware::CPU.arm?
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.7/swarmy-0.2.7-aarch64-unknown-linux-musl.tar.gz"
    sha256 "3a5c0131b87e882ad5ef50e3fe0232ed0dc153528ddebb5efda6bedec14bedb5"
  else
    url "https://github.com/koorchik/swarmy/releases/download/v0.2.7/swarmy-0.2.7-x86_64-unknown-linux-musl.tar.gz"
    sha256 "d3ad61cbb7526026206979dda17d3ca95ea860ec62093148716127bd223bb156"
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
