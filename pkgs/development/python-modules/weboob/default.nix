{ buildPythonPackage, fetchurl, stdenv, isPy27
, nose, pillow, prettytable, pyyaml, dateutil, gdata
, requests, mechanize, feedparser, lxml, gnupg, pyqt5
, libyaml, simplejson, cssselect, futures, pdfminer
, termcolor, google_api_python_client, html2text
, unidecode
}:

buildPythonPackage rec {
  pname = "weboob";
  version = "1.5";

  src = fetchurl {
    url = "https://git.weboob.org/weboob/weboob/uploads/007b56516cfeeea4d5c7e97fd3a1ba1f/${pname}-${version}.tar.gz";
    sha256 = "1c9z9gid1mbm1cakb2wj6jjkbrmji8y8ac46iqpih9x1h498bhbs";
  };

  postPatch = ''
    # Disable doctests that require networking:
    sed -i -n -e '/^ *def \+pagination *(.*: *$/ {
      p; n; p; /"""\|'\'\'\'''/!b

      :loop
      n; /^ *\(>>>\|\.\.\.\)/ { h; bloop }
      x; /^ *\(>>>\|\.\.\.\)/bloop; x
      p; /"""\|'\'\'\'''/b
      bloop
    }; p' weboob/browser/browsers.py weboob/browser/pages.py
  '';

  setupPyBuildFlags = ["--xdg"];

  checkInputs = [ nose ];

  nativeBuildInputs = [ pyqt5 ];

  propagatedBuildInputs = [ pillow prettytable pyyaml dateutil
    gdata requests feedparser lxml gnupg pyqt5 libyaml
    simplejson cssselect pdfminer termcolor
    html2text unidecode ]
    ++ stdenv.lib.optionals isPy27 [ mechanize futures google_api_python_client ]
    ++ stdenv.lib.optionals (!isPy27) [ google_api_python_client ];

  checkPhase = ''
    nosetests
  '';

  meta = {
    homepage = http://weboob.org;
    description = "Collection of applications and APIs to interact with websites without requiring the user to open a browser";
    license = stdenv.lib.licenses.agpl3;
  };
}

