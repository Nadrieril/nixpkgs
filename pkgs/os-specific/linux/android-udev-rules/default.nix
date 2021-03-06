{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "android-udev-rules-${version}";
  version = "20160805";

  src = fetchFromGitHub {
    owner = "M0Rf30";
    repo = "android-udev-rules";
    rev = version;
    sha256 = "0sdf3insqs73cdzmwl3lqy7nj82f1lprxd3vm0jh3qpf0sd1k93c";
  };

  installPhase = ''
    install -D 51-android.rules $out/lib/udev/rules.d/51-android.rules
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/M0Rf30/android-udev-rules";
    description = "Android udev rules list aimed to be the most comprehensive on the net";
    platforms = platforms.linux;
    license = licenses.gpl3;
    maintainers = with maintainers; [ abbradar ];
  };
}
