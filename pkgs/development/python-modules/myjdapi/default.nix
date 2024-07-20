{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  pycryptodome,
  requests,
}:

buildPythonPackage rec {
  pname = "myjdapi";
  version = "1.1.7";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OmxW+xRgjhRyFOfGpkmfbW7AR1AsJMsRt3ojzz726pI=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    pycryptodome
    requests
  ];

  pythonImportsCheck = [ "myjdapi" ];

  meta = with lib; {
    description = "Library to use My.Jdownloader API in an easy way";
    homepage = "https://pypi.org/project/myjdapi";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
