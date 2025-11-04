class Listen < Formula
  desc "Minimal audio transcription tool - 100% on-premise"
  homepage "https://github.com/gmoqa/listen"
  url "https://github.com/gmoqa/listen/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "34a952001197d0039d23407fc7721dbf145cb8a983a762a62748a5ce9ddd3c20"
  license "MIT"

  uses_from_macos "python"

  def install
    libexec.install "listen.py"
    libexec.install "requirements.txt"

    (bin/"listen").write <<~EOS
      #!/bin/bash
      PYTHON=$(command -v python3 || command -v python)
      VENV_DIR="#{libexec}/venv"

      if [ ! -d "$VENV_DIR" ]; then
        echo "Setting up listen (first run)..."
        $PYTHON -m venv "$VENV_DIR" || {
          echo "Error: Could not create virtual environment."
          exit 1
        }
        source "$VENV_DIR/bin/activate"
        pip install --quiet --upgrade pip
        pip install --quiet -r "#{libexec}/requirements.txt" || {
          echo "Error: Could not install dependencies."
          exit 1
        }
        echo "Setup complete!"
      fi
      source "$VENV_DIR/bin/activate"
      exec python "#{libexec}/listen.py" "$@"
    EOS
  end

  test do
    system bin/"listen", "--help"
  end

  def caveats
    <<~EOS
      First run will download Whisper models (~150MB for base model).
      This happens automatically and only once.

      Requirements:
      - Python 3.8+ (included in macOS)
      - Microphone access

      No Command Line Tools needed!
    EOS
  end
end
