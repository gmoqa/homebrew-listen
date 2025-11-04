class Listen < Formula
  desc "Minimal audio transcription tool - 100% on-premise"
  homepage "https://github.com/gmoqa/listen"
  url "https://github.com/gmoqa/listen/archive/refs/tags/v1.0.6.tar.gz"
  sha256 "45d242d2bf67a9cf42986580821b1a408c5f8b18f741766552c1ebb509e87b86"
  license "MIT"

  depends_on "ffmpeg"
  uses_from_macos "python"

  def install
    libexec.install "listen.py"
    libexec.install "requirements.txt"

    (bin/"listen").write <<~EOS
      #!/bin/bash
      set -e
      PYTHON=$(command -v python3 || command -v python)
      VENV_DIR="#{libexec}/venv"
      SETUP_DONE="#{libexec}/.setup_done"

      if [ ! -f "$SETUP_DONE" ]; then
        echo "Setting up listen (first run)..."

        if [ ! -d "$VENV_DIR" ]; then
          $PYTHON -m venv "$VENV_DIR" || {
            echo "Error: Could not create virtual environment."
            exit 1
          }
        fi

        source "$VENV_DIR/bin/activate"

        echo "Installing Python dependencies..."
        pip install --upgrade pip > /dev/null 2>&1
        pip install -r "#{libexec}/requirements.txt" || {
          echo "Error: Could not install dependencies."
          echo "Try running: brew reinstall listen"
          exit 1
        }

        touch "$SETUP_DONE"
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
