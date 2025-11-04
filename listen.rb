class Listen < Formula
  desc "Minimal audio transcription tool - 100% on-premise"
  homepage "https://github.com/gmoqa/listen"
  url "https://github.com/gmoqa/listen/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "3a5801c73455179d45ca9c7d10a5a189dac6cc9d3c596e17248d6d270b6b1af7"
  license "MIT"

  uses_from_macos "python"

  def install
    libexec.install "listen.py"
    libexec.install "requirements.txt"

    (bin/"listen").write <<~EOS
      #!/bin/bash
      PYTHON=$(command -v python3 || command -v python)
      if [ ! -d "#{libexec}/venv" ]; then
        $PYTHON -m venv "#{libexec}/venv"
        source "#{libexec}/venv/bin/activate"
        pip install --quiet -r "#{libexec}/requirements.txt"
      else
        source "#{libexec}/venv/bin/activate"
      fi
      exec python "#{libexec}/listen.py" "$@"
    EOS
  end

  test do
    system bin/"listen", "--help"
  end

  def caveats
    <<~EOS
      This tool requires:
      - Python 3.8+
      - portaudio (for audio recording)
      - ffmpeg (for audio processing)

      Install dependencies with:
        brew install portaudio ffmpeg

      Or if you prefer system packages, install them manually.
    EOS
  end
end
