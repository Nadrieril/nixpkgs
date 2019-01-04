{ lib, buildPythonPackage, fetchPypi, isPy27
, cssselect
, dateutil
, feedparser
, futures
, gdata
, gnupg
, google_api_python_client
, html2text
, libyaml
, lxml
, mechanize
, nose
, pdfminer
, pillow
, prettytable
, pyqt5
, pyyaml
, requests
, simplejson
, termcolor
, unidecode
}:

buildPythonPackage rec {
  pname = "weboob";
  version = "1.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1c9z9gid1mbm1cakb2wj6jjkbrmji8y8ac46iqpih9x1h498bhbs";
  };

  # Patch tests for python3 compatibility
  patches = stdenv.lib.optionals (!isPy27) [ ./weboob-1.3-python3-tests.patch ];

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

  setupPyBuildFlags = ["--qt" "--xdg"];

  checkInputs = [ nose ];

  nativeBuildInputs = [ pyqt5 ];

  propagatedBuildInputs = [
    cssselect
    dateutil
    feedparser
    gdata
    gnupg
    google_api_python_client
    html2text
    libyaml
    lxml
    pdfminer
    pillow
    prettytable
    pyqt5
    pyyaml
    requests
    simplejson
    termcolor
    unidecode
  ]
  ++ lib.optionals isPy27 [ mechanize futures ];

  checkPhase = ''
    nosetests
  '';

  meta = {
    homepage = http://weboob.org;
    description = "Collection of applications and APIs to interact with websites without requiring the user to open a browser";
    license = lib.licenses.agpl3;
  };
}
