{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  requests,
  requests-toolbelt,
  six,
}:

buildPythonPackage rec {
  pname = "mediafire";
  version = "0.6.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-oa3+/0PfthHVYMkg9uwYoFtRl7KxUJOwhZHkXOh5NT4=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    requests
    requests-toolbelt
    six
  ];

  pythonImportsCheck = [ "mediafire" ];

  meta = with lib; {
    description = "Python MediaFire client library";
    homepage = "https://pypi.org/project/mediafire";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
