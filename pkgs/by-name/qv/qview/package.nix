{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  x11Support ? true,
}:

stdenv.mkDerivation rec {
  pname = "qview";
  version = "7.0";

  src = fetchFromGitHub {
    owner = "jurplel";
    repo = "qView";
    rev = version;
    hash = "sha256-kFptDhmFu9LX99P6pCfxRbu4iVhWl4br+n6LO+yrGsw=";
  };

  qmakeFlags = lib.optionals (!x11Support) [ "CONFIG+=NO_X11" ];

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qttools
    libsForQt5.qtimageformats
    libsForQt5.qtsvg
  ]
  ++ lib.optionals x11Support [ libsForQt5.qtx11extras ];

  meta = with lib; {
    description = "Practical and minimal image viewer";
    mainProgram = "qview";
    homepage = "https://interversehq.com/qview/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ acowley ];
    platforms = platforms.all;
  };
}
