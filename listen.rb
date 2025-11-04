class Listen < Formula
  desc "Minimal audio transcription tool - 100% on-premise"
  homepage "https://github.com/gmoqa/listen"
  url "https://github.com/gmoqa/listen/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "3a5801c73455179d45ca9c7d10a5a189dac6cc9d3c596e17248d6d270b6b1af7"
  license "MIT"

  depends_on "python@3.11"
  depends_on "portaudio"
  depends_on "ffmpeg"

  def install
    libexec.install "listen.py"
    libexec.install "requirements.txt"

    (bin/"listen").write <<~EOS
      #!/bin/bash
      if [ ! -d "#{libexec}/venv" ]; then
        python3.11 -m venv "#{libexec}/venv"
        source "#{libexec}/venv/bin/activate"
        pip install --quiet -r "#{libexec}/requirements.txt"
      else
        source "#{libexec}/venv/bin/activate"
      fi
      exec python "#{libexec}/listen.py" "$@"
    EOS
  end

  test do
    assert_match "usage: listen", shell_output("#{bin}/listen --help")
  end
end
