{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  aiofiles,
  aiohttp,
  aiosqlite,
  asyncprawcore,
  update-checker,
  coveralls,
  asynctest,
  mock,
  packaging,
  pre-commit,
  pytest,
  pytest-asyncio,
  pytest-vcr,
  sphinx,
  sphinx-rtd-dark-mode,
  sphinx-rtd-theme,
  sphinxcontrib-trio,
  testfixtures,
  urllib3,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "asyncpraw";
  version = "7.7.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qYt8qFrH6CDqnVw9lWKaDXpxN8XIMbpiFwJb1TJ7UJs=";
  };

  patches = [
  	./unpin-dependencies.patch
  ];

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    aiofiles
    aiohttp
    aiosqlite
    asyncprawcore
    update-checker
  ];

  passthru.optional-dependencies = {
    ci = [ coveralls ];
    dev = [
      asynctest
      mock
      packaging
      pre-commit
      pytest
      pytest-asyncio
      pytest-vcr
      sphinx
      sphinx-rtd-dark-mode
      sphinx-rtd-theme
      sphinxcontrib-trio
      testfixtures
      urllib3
      vcrpy
    ];
    lint = [
      pre-commit
      sphinx
      sphinx-rtd-dark-mode
      sphinx-rtd-theme
      sphinxcontrib-trio
    ];
    readthedocs = [
      sphinx
      sphinx-rtd-dark-mode
      sphinx-rtd-theme
      sphinxcontrib-trio
    ];
    test = [
      asynctest
      mock
      pytest
      pytest-asyncio
      pytest-vcr
      testfixtures
      urllib3
      vcrpy
    ];
  };

  pythonImportsCheck = [ "asyncpraw" ];

  meta = with lib; {
    description = "Async PRAW, an abbreviation for \"Asynchronous Python Reddit API Wrapper\", is a python package that allows for simple access to Reddit's API";
    homepage = "https://pypi.org/project/asyncpraw/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
  };
}
