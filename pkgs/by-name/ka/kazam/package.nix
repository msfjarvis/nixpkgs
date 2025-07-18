{
  lib,
  fetchFromGitHub,
  replaceVars,
  python3Packages,
  gst_all_1,
  wrapGAppsHook3,
  gobject-introspection,
  gtk3,
  libwnck,
  keybinder3,
  intltool,
  libcanberra-gtk3,
  libappindicator-gtk3,
  libpulseaudio,
  libgudev,
}:

python3Packages.buildPythonApplication {
  pname = "kazam";
  version = "unstable-2021-06-22";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "niknah";
    repo = "kazam";
    rev = "13f6ce124e5234348f56358b9134a87121f3438c";
    sha256 = "1jk6khwgdv3nmagdgp5ivz3156pl0ljhf7b6i4b52w1h5ywsg9ah";
  };

  nativeBuildInputs = [
    gobject-introspection
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk3
    libwnck
    keybinder3
    libappindicator-gtk3
    libgudev
  ];

  build-system = with python3Packages; [
    setuptools
    distutils-extra
  ];

  dependencies = with python3Packages; [
    pygobject3
    pyxdg
    pycairo
    dbus-python
    xlib
  ];

  patches = [
    # Fix paths
    (replaceVars ./fix-paths.patch {
      libcanberra = libcanberra-gtk3;
      inherit libpulseaudio;
    })
  ];

  # no tests
  doCheck = false;

  pythonImportsCheck = [ "kazam" ];

  meta = with lib; {
    description = "Screencasting program created with design in mind";
    homepage = "https://github.com/niknah/kazam";
    license = licenses.lgpl3;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "kazam";
  };
}
