class QasaCodeagent < Formula
  desc "AI coding agent wrapper for non-technical staff"
  homepage "https://github.com/qasase/qasa-codeagent"
  url "https://github.com/qasase/qasa-codeagent/archive/refs/tags/v1.0.0.tar.gz"
  sha256 ""
  license "MIT"

  depends_on "ruby"

  def install
    ENV["GEM_HOME"] = libexec
    system "gem", "build", "qasa-codeagent.gemspec"
    system "gem", "install", "--no-document", "qasa-codeagent-1.0.0.gem",
           "--install-dir", libexec
    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    assert_match "qasa-codeagent", shell_output("#{bin}/qasa-codeagent version")
  end
end
