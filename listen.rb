class Listen < Formula
  desc "Minimal audio transcription tool - 100% on-premise"
  homepage "https://github.com/gmoqa/listen"
  url "https://github.com/gmoqa/listen/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "6ad2e157e09be3b9cac4beffe120bcea12beb71b326d44384c4d07a4c5cfbff9"
  license "MIT"

  depends_on "rust" => :build
  depends_on "cmake" => :build

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    assert_match "listen 2.1.0", shell_output("#{bin}/listen --version")
    assert_match "Usage:", shell_output("#{bin}/listen --help")
  end

  def caveats
    <<~EOS
      First run will download the Whisper model (~140MB).
      Model is cached at: ~/.cache/whisper/

      Requirements:
      - Microphone access

      The Rust implementation is 150x faster than Python!
    EOS
  end
end
