{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatch-vcs,
  hatchling,
  requests,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "stashapi";
  # Weird version just to appease hatch-vcs
  version = "0.1.0rc0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "stg-annon";
    repo = "stashapi";
    rev = "a11927d7e1a63de187a40b1452ba09b27a5d6af0";
    hash = "sha256-NMKizRSVd8fDQYzreKehSsfajBIA0G1+IP2MF+XkgH8=";
  };

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    requests
    typing-extensions
  ];

  pythonImportsCheck = [
    "stashapi"
  ];

  meta = {
    description = "Api wrapper";
    homepage = "https://github.com/stg-annon/stashapi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
