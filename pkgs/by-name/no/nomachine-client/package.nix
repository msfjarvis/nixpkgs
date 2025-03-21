{
  lib,
  stdenv,
  file,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  jsoncpp,
  libpulseaudio,
}:
let
  versionMajor = "8.13";
  versionMinor = "1";
  versionBuild_x86_64 = "1";
  versionBuild_i686 = "1";
in
stdenv.mkDerivation rec {
  pname = "nomachine-client";
  version = "${versionMajor}.${versionMinor}";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://download.nomachine.com/download/${versionMajor}/Linux/nomachine_${version}_${versionBuild_x86_64}_x86_64.tar.gz";
        sha256 = "sha256-8rxlxdtGU8avpvYJr+bpnsy5v91sqtlij/MCGWrcanY=";
      }
    else if stdenv.hostPlatform.system == "i686-linux" then
      fetchurl {
        url = "https://download.nomachine.com/download/${versionMajor}/Linux/nomachine_${version}_${versionBuild_i686}_i686.tar.gz";
        sha256 = "sha256-Ekyxc4wODjqWhp0aINhaPGLy9lh6Rt9AmxIt1ulE8Go=";
      }
    else
      throw "NoMachine client is not supported on ${stdenv.hostPlatform.system}";

  # nxusb-legacy is only needed for kernel versions < 3
  postUnpack = ''
    mv $(find . -type f -name nxrunner.tar.gz) .
    mv $(find . -type f -name nxplayer.tar.gz) .
    rm -r NX/
    tar xf nxrunner.tar.gz
    tar xf nxplayer.tar.gz
    rm $(find . -maxdepth 1 -type f)
    rm -r NX/share/src/nxusb-legacy
    rm NX/bin/nxusbd-legacy NX/lib/libnxusb-legacy.so
  '';

  nativeBuildInputs = [
    file
    makeWrapper
    autoPatchelfHook
  ];
  buildInputs = [
    jsoncpp
    libpulseaudio
  ];

  installPhase = ''
    rm bin/nxplayer bin/nxrunner

    mkdir -p $out/NX
    cp -r bin lib share $out/NX/

    ln -s $out/NX/bin $out/bin

    for i in share/icons/*; do
      if [[ -d "$i" ]]; then
        mkdir -p "$out/share/icons/hicolor/$(basename $i)/apps"
        cp "$i"/* "$out/share/icons/hicolor/$(basename $i)/apps/"
      fi
    done

    mkdir $out/share/applications
    cp share/applnk/player/xdg/*.desktop $out/share/applications/
    cp share/applnk/runner/xdg-mime/*.desktop $out/share/applications/

    mkdir -p $out/share/mime/packages
    cp share/applnk/runner/xdg-mime/*.xml $out/share/mime/packages/

    for i in $out/share/applications/*.desktop; do
      substituteInPlace "$i" --replace /usr/NX/bin $out/bin
    done
  '';

  postFixup = ''
    makeWrapper $out/bin/nxplayer.bin $out/bin/nxplayer --set NX_SYSTEM $out/NX
    makeWrapper $out/bin/nxrunner.bin $out/bin/nxrunner --set NX_SYSTEM $out/NX

    # libnxcau.so needs libpulse.so.0 for audio to work, but doesn't
    # have a DT_NEEDED entry for it.
    patchelf --add-needed libpulse.so.0 $out/NX/lib/libnxcau.so
  '';

  dontBuild = true;
  dontStrip = true;

  meta = with lib; {
    description = "NoMachine remote desktop client (nxplayer)";
    homepage = "https://www.nomachine.com/";
    mainProgram = "nxplayer";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = {
      fullName = "NoMachine 7 End-User License Agreement";
      url = "https://www.nomachine.com/licensing-7";
      free = false;
    };
    maintainers = with maintainers; [ talyz ];
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
