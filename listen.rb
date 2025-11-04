class Listen < Formula
  include Language::Python::Virtualenv

  desc "Minimal audio transcription tool - 100% on-premise"
  homepage "https://github.com/gmoqa/listen"
  url "https://github.com/gmoqa/listen/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  depends_on "python@3.11"
  depends_on "portaudio"
  depends_on "ffmpeg"

  def install
    virtualenv_install_with_resources

    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install resources
    venv.pip_install "openai-whisper>=20230314"
    venv.pip_install "sounddevice>=0.4.6"
    venv.pip_install "numpy>=1.24.0"

    (libexec/"lib/python3.11/site-packages").install "listen.py"

    (bin/"listen").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/python" "#{libexec}/lib/python3.11/site-packages/listen.py" "$@"
    EOS
    chmod 0755, bin/"listen"
  end

  test do
    assert_match "usage: listen", shell_output("#{bin}/listen --help")
  end
end
