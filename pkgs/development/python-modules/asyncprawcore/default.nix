{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  aiohttp,
  yarl,
  coveralls,
  asyncprawcore,
  packaging,
  pre-commit,
  ruff,
  mock,
  pytest,
  pytest-asyncio,
  pytest-vcr,
  urllib3,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "asyncprawcore";
  version = "2.4.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OjNZ5c0evmHVRKCdS17Kexbt/RfeBwgahBX8eU97ti4=";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    aiohttp
    yarl
  ];

  passthru.optional-dependencies = {
    ci = [ coveralls ];
    dev = [
      asyncprawcore
      packaging
    ];
    lint = [
      pre-commit
      ruff
    ];
    test = [
      mock
      pytest
      pytest-asyncio
      pytest-vcr
      urllib3
      vcrpy
    ];
  };

  pythonImportsCheck = [ "asyncprawcore" ];

  meta = with lib; {
    description = "Low-level asynchronous communication layer for Async PRAW 7";
    homepage = "https://pypi.org/project/asyncprawcore/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
