{
  lib,
  buildPythonPackage,
  fetchPypi,
  uv-build,
  aiohttp,
  aiolimiter,
  pycryptodome,
  async-mega-py,
  python-dotenv,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "async-mega-py";
  version = "2.4.1";
  pyproject = true;

  src = fetchPypi {
    pname = "async_mega_py";
    inherit (finalAttrs) version;
    hash = "sha256-CpdcyIAvruFMTwG+HH+mH8U6y91iWHIt509oORnEfVs=";
  };

  build-system = [
    uv-build
  ];

  dependencies = [
    aiohttp
    aiolimiter
    pycryptodome
  ];

  optional-dependencies = {
    cli = [
      async-mega-py
    ];
    default = [
      python-dotenv
      rich
    ];
  };

  pythonImportsCheck = [
    "mega"
  ];

  # Upstream uses overly strict, fresh version specifiers
  pythonRelaxDeps = true;

  # `build-system` requirements are seemingly not covered by pythonRelaxDeps
  postPatch = ''
    sed -i 's/requires = \["uv_build.*"\]/requires = ["uv_build"]/' pyproject.toml
  '';

  meta = {
    description = "Python library for the Mega.nz and Transfer.it API";
    homepage = "https://pypi.org/project/async-mega-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
})
