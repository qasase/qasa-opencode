class QasaOpencode < Formula
  desc "Read-only OpenCode wrapper for Qasa business staff"
  homepage "https://github.com/qasase/qasa-opencode"
  url "https://github.com/qasase/qasa-opencode/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "81b9073c22caae706655c21a0328c8426c279425ae9aefa6a236bcb159675516"
  license "MIT"

  depends_on "ruby"
  depends_on "opencode"

  def install
    ENV["GEM_HOME"] = libexec
    system "gem", "build", "qasa-opencode.gemspec"
    system "gem", "install", "--no-document", "qasa-opencode-0.2.0.gem",
           "--install-dir", libexec
    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    assert_match "qasa-opencode", shell_output("#{bin}/qasa-opencode version")
  end
end
