{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  makeWrapper,
  pkg-config,
  bash,
  libusb1,
  qt5,
  wget,
  zenity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imsprog";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "bigbigmdm";
    repo = "IMSProg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5aDQgpZ8sS7YZAE/L0WH1nnlBZY7R68XbsAssWkGTYQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    qt5.wrapQtAppsHook
    qt5.qttools
  ];

  buildInputs = [
    bash # for patching the shebang in bin/IMSProg_database_update
    libusb1
    qt5.qtbase
    qt5.qtwayland
  ];

  # change default hardcoded path for chip database file, udev rules et al
  postPatch = ''
    while IFS= read -r -d "" file ; do
      substituteInPlace "$file" \
        --replace-quiet '/usr/bin/' "$out/bin/" \
        --replace-quiet '/usr/lib/' "$out/lib/" \
        --replace-quiet '/usr/share/' "$out/share/"
    done < <(grep --files-with-matches --null --recursive '/usr/' .)
  '';

  postFixup = ''
    wrapProgram $out/bin/IMSProg_database_update \
      --prefix PATH : "${
        lib.makeBinPath [
          wget
          zenity
        ]
      }"
  '';

  doInstallCheck = true;

  meta = {
    changelog = "https://github.com/bigbigmdm/IMSProg/releases/tag/v${finalAttrs.version}";
    description = "Free I2C EEPROM programmer tool for CH341A device";
    homepage = "https://github.com/bigbigmdm/IMSProg";
    license = with lib.licenses; [
      gpl3Plus
      gpl2Plus
      lgpl21Only
    ];
    mainProgram = "IMSProg";
    maintainers = with lib.maintainers; [ wucke13 ];
    platforms = lib.platforms.unix;
  };
})
