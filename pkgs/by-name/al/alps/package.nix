{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  fetchpatch,
  nixosTests,
}:

buildGoModule rec {
  pname = "alps";
  version = "2025-01-29";

  src = fetchFromSourcehut {
    owner = "~migadu";
    repo = "alps";
    rev = "e50745066a375a18e25fd1b0b14f6cfa1df30814";
    hash = "sha256-QDV5nBlLcmiLS6/5jaw8+7+czCCuhQ80FHpvSmXwzcg=";
  };

  vendorHash = "sha256-6ElVEplnP/p6mpqPk9tQp2E0B3J65g3uKDWZSi970U8=";

  ldflags = [
    "-s"
    "-w"
    "-X main.themesPath=${placeholder "out"}/share/alps/themes"
    "-X git.sr.ht/~migadu/alps.PluginDir=${placeholder "out"}/share/alps/plugins"
  ];

  postPatch = ''
    substituteInPlace plugin.go --replace "const PluginDir" "var PluginDir"
  '';

  postInstall = ''
    mkdir -p "$out/share/alps"
    cp -r themes plugins "$out/share/alps/"
  '';

  proxyVendor = true;

  passthru.tests = { inherit (nixosTests) alps; };

  meta = with lib; {
    description = "Simple and extensible webmail";
    homepage = "https://git.sr.ht/~migadu/alps";
    license = licenses.mit;
    maintainers = with maintainers; [
      booklearner
      madonius
      hmenke
    ];
    mainProgram = "alps";
  };
}
