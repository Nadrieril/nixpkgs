{ stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  name = "rtl8814au-${kernel.version}-${version}";
  version = "4.3.21";

  src = fetchFromGitHub {
    owner = "ScrambledAuroras";
    repo = "rtl8814AU";
    rev = "ccac303ca68e5c3465311bda9d29433aac894e42";
    sha256 = "0v5ckpm4c6sqhn1kdgb0namw4a1chq16rbhzzxbjwj1rh1fk2mnn";
  };

  hardeningDisable = [ "pic" ];

  NIX_CFLAGS_COMPILE="-Wno-error=incompatible-pointer-types";

  patchPhase = ''
    substituteInPlace ./Makefile --replace /lib/modules/ "${kernel.dev}/lib/modules/"
    substituteInPlace ./Makefile --replace '$(shell uname -r)' "${kernel.modDirVersion}"
    substituteInPlace ./Makefile --replace /sbin/depmod #
    substituteInPlace ./Makefile --replace '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  meta = {
    description = "Driver for Realtek 802.11ac, rtl8814au, provides the 8814au mod";
    homepage = "https://github.com/ScrambledAuroras/rtl8814AU";
    license = stdenv.lib.licenses.gpl2;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
