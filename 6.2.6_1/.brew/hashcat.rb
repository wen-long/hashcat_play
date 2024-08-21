class Hashcat < Formula
  desc "World's fastest and most advanced password recovery utility"
  homepage "https://hashcat.net/hashcat/"
  url "https://hashcat.net/files/hashcat-6.2.6.tar.gz"
  mirror "https://github.com/hashcat/hashcat/archive/refs/tags/v6.2.6.tar.gz"
  sha256 "b25e1077bcf34908cc8f18c1a69a2ec98b047b2cbcf0f51144dcf3ba1e0b7b2a"
  license "MIT"
  revision 1
  version_scheme 1
  head "https://github.com/hashcat/hashcat.git", branch: "master"

  livecheck do
    url :homepage
    regex(/href=.*?hashcat[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "gnu-sed" => :build
  depends_on macos: :high_sierra # Metal implementation requirement
  depends_on "minizip"
  depends_on "xxhash"

  uses_from_macos "zlib"

  on_linux do
    depends_on "opencl-headers" => :build
    depends_on "opencl-icd-loader"
    depends_on "pocl"
  end

  # Fix 'failed to create metal library' on macos
  # extract from hashcat version 66b22fa, remove this patch when version released after 66b22fa
  patch :DATA

  def install
    args = %W[
      CC=#{ENV.cc}
      PREFIX=#{prefix}
      USE_SYSTEM_XXHASH=1
      USE_SYSTEM_OPENCL=1
      USE_SYSTEM_ZLIB=1
      ENABLE_UNRAR=0
    ]
    system "make", *args
    system "make", "install", *args
    bin.install "hashcat" => "hashcat_bin"
    (bin/"hashcat").write_env_script bin/"hashcat_bin", XDG_DATA_HOME: share
  end

  test do
    ENV["XDG_DATA_HOME"] = testpath
    mkdir testpath/"hashcat"
    assert_match "Hash-Mode 0 (MD5)", shell_output("#{bin}/hashcat_bin --benchmark -m 0 -D 1,2 -w 2")
  end
end

__END__
diff --git a/OpenCL/inc_vendor.h b/OpenCL/inc_vendor.h
index c39fce952..0916a30b3 100644
--- a/OpenCL/inc_vendor.h
+++ b/OpenCL/inc_vendor.h
@@ -12,7 +12,7 @@
 #define IS_CUDA
 #elif defined __HIPCC__
 #define IS_HIP
-#elif defined __METAL_MACOS__
+#elif defined __METAL__
 #define IS_METAL
 #else
 #define IS_OPENCL