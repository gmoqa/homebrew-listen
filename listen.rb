class Listen < Formula
  desc "Minimal audio transcription tool - 100% on-premise"
  homepage "https://github.com/gmoqa/listen"
  url "https://github.com/gmoqa/listen/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "39249cdc1c162861b6e670013c48b0a377b4063890d6d34e3bc1a089bd340bb6"
  license "MIT"

  depends_on "ffmpeg"
  uses_from_macos "python"

  def install
    libexec.install "listen.py"
    libexec.install "config.py"
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

  def post_install
    # Setup venv and install dependencies during brew install
    venv_dir = libexec/"venv"
    python = which("python3") || which("python")

    unless venv_dir.exist?
      system python, "-m", "venv", venv_dir
    end

    system venv_dir/"bin/pip", "install", "--upgrade", "pip", "--quiet"
    system venv_dir/"bin/pip", "install", "-r", libexec/"requirements.txt", "--quiet"

    # Pre-download Whisper model
    ohai "Downloading Whisper model (this may take a moment)..."
    system venv_dir/"bin/python", "-c",
           "import whisper; whisper.load_model('base')"

    # Mark setup as done
    (libexec/".setup_done").write ""

    # Create first_run marker so user doesn't see the hint
    first_run_marker = Pathname(Dir.home)/".local/share/listen/.first_run_done"
    first_run_marker.parent.mkpath
    first_run_marker.write ""
  end

  test do
    system bin/"listen", "--help"
  end

  def caveats
    <<~EOS
      Whisper model has been pre-downloaded during installation.
      Ready to use immediately!

      Requirements:
      - Python 3.8+ (included in macOS)
      - Microphone access

      No Command Line Tools needed!
    EOS
  end
end
