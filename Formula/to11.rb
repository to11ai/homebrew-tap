# typed: false
# frozen_string_literal: true

class To11 < Formula
  desc "Company skills for your coding agent"
  homepage "https://github.com/to11ai/to11-cli"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/to11ai/to11-cli/releases/download/v0.5.0/to11_0.5.0_darwin_arm64.tar.gz"
      sha256 "931b5bc3cb8c78cb51f6600b8d126809908e9eb1fd32fd916ed23046fc7bb840"
    end
    on_intel do
      url "https://github.com/to11ai/to11-cli/releases/download/v0.5.0/to11_0.5.0_darwin_amd64.tar.gz"
      sha256 "1e08dc870c00e3e687a16e1dc28fd0a93d3aabdc4320fedf440ce0dfe3fdff05"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/to11ai/to11-cli/releases/download/v0.5.0/to11_0.5.0_linux_arm64.tar.gz"
      sha256 "63487baeba28fbe29918612c9299fa68b7205975e92ee85518e57a2cf8f4a156"
    end
    on_intel do
      url "https://github.com/to11ai/to11-cli/releases/download/v0.5.0/to11_0.5.0_linux_amd64.tar.gz"
      sha256 "ae8f0f2f80d525ec71931b1e43f8255986aaf35e138c20fd7b57ab7240e75377"
    end
  end

  def install
    bin.install "to11"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/to11 --version")
  end
end
