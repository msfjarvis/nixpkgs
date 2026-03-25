{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  python3,
}:
let
  py = python3 // {
    pkgs = python3.pkgs.overrideScope (
      final: prev: {
        # Requires "wand<0.7"
        wand = prev.wand.overridePythonAttrs (prev: rec {
          version = "0.6.13";
          format = "setuptools";
          pyproject = null;
          src = prev.src.override {
            tag = version;
            hash = "sha256-WEVExbo8jLhV5Mf3WX4YM8YPeapdtPOc3EJbpbtIq14=";
          };
        });
      }
    );
  };
in
py.pkgs.buildPythonApplication rec {
  pname = "calibre-web";
  version = "0.6.26-unstable-2026-03-01";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "janeczku";
    repo = "calibre-web";
    # remember changing this back (and changelog below) to tag after new release come out
    rev = "6157f5027c979aa05f8d97a09f1388ceb3085ac5";
    hash = "sha256-1ljMsf8Puvq4ELUSi8Vl3T7EHcd7MO3zGgT4j5PYsT0=";
  };

  patches = [
    # default-logger.patch switches default logger to /dev/stdout. Otherwise calibre-web tries to open a file relative
    # to its location, which can't be done as the store is read-only. Log file location can later be configured using UI
    # if needed.
    ./default-logger.patch
    # DB migrations adds an env var __RUN_MIGRATIONS_ANDEXIT that, when set, instructs calibre-web to run DB migrations
    # and exit. This is gonna be used to configure calibre-web declaratively, as most of its configuration parameters
    # are stored in the DB.
    ./db-migrations.patch
  ];

  # calibre-web doesn't follow setuptools directory structure.
  postPatch = ''
    mkdir -p src/calibreweb
    mv cps.py src/calibreweb/__init__.py
    mv cps src/calibreweb

    substituteInPlace pyproject.toml \
      --replace-fail 'cps = "calibreweb:main"' 'calibre-web = "calibreweb:main"'
  '';

  build-system = with py.pkgs; [ setuptools ];

  dependencies = with py.pkgs; [
    apscheduler
    babel
    bleach
    chardet
    cryptography
    flask
    flask-babel
    flask-httpauth
    flask-limiter
    flask-principal
    flask-wtf
    iso-639
    lxml
    netifaces-plus
    pycountry
    pypdf
    python-magic
    pytz
    regex
    requests
    sqlalchemy
    tornado
    unidecode
    urllib3
    wand
  ];

  optional-dependencies = {
    comics = with py.pkgs; [
      comicapi
      natsort
    ];

    gdrive = with py.pkgs; [
      gevent
      google-api-python-client
      greenlet
      httplib2
      oauth2client
      pyasn1-modules
      # https://github.com/NixOS/nixpkgs/commit/bf28e24140352e2e8cb952097febff0e94ea6a1e
      # pydrive2
      pyyaml
      rsa
      uritemplate
    ];

    gmail = with py.pkgs; [
      google-api-python-client
      google-auth-oauthlib
    ];

    # We don't support the goodreads feature, as the `goodreads` package is
    # archived and depends on other long unmaintained packages (rauth & nose)
    # goodreads = [ ];

    kobo = with py.pkgs; [ jsonschema ];

    ldap = with py.pkgs; [
      flask-simpleldap
      python-ldap
    ];

    metadata = with py.pkgs; [
      faust-cchardet
      html2text
      markdown2
      mutagen
      py7zr
      pycountry
      python-dateutil
      rarfile
      scholarly
    ];

    oauth = with py.pkgs; [
      flask-dance
      sqlalchemy-utils
    ];
  };

  pythonRelaxDeps = [
    "apscheduler"
    "bleach"
    "cryptography"
    "flask"
    "flask-limiter"
    "lxml"
    "pypdf"
    "regex"
    "requests"
    "tornado"
    "unidecode"
    "wand"
  ];

  nativeCheckInputs = lib.concatAttrValues optional-dependencies;

  pythonImportsCheck = [ "calibreweb" ];

  passthru = {
    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux { inherit (nixosTests) calibre-web; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
    homepage = "https://github.com/janeczku/calibre-web";
    # revert back to tag based changelog
    # changelog = "https://github.com/janeczku/calibre-web/releases/tag/${src.tag}";
    changelog = "https://github.com/janeczku/calibre-web/compare/0.6.26...${src.rev}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "calibre-web";
    platforms = lib.platforms.all;
  };
}
