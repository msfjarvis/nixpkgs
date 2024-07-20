{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-trio";
  version = "1.2.0";
  pyproject = true;

  src = fetchPypi {
    pname = "sphinxcontrib_trio";
    inherit version;
    hash = "sha256-w7KGa78QmT0QFo6q9UMpzogotxJj67BtLx8CuuZ8C80=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [ sphinx ];

  pythonImportsCheck = [ "sphinxcontrib_trio" ];

  meta = with lib; {
    description = "Make Sphinx better at documenting Python functions and methods";
    homepage = "https://pypi.org/project/sphinxcontrib-trio/";
    license = with licenses; [
      mit
      asl20
    ];
    maintainers = with maintainers; [ ];
  };
}
