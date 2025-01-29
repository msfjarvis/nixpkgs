{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  fetchpatch,
  nixosTests,
}:

buildGoModule {
  pname = "alps";
  version = "0-unstable-2025-08-05";

  src = fetchFromSourcehut {
    owner = "~migadu";
    repo = "alps";
    rev = "eb78a277cfdc212bac90bead46243104e9fecd6a";
    hash = "sha256-YerfVObIa6VW7fM4XiRCgdj0GgJ5jD3nf8cGmLoFUBs=";
  };

  vendorHash = "sha256-dlRKYKPkObf4mWUD9s4VwIbw0dOYnH1U5eS1RE0fu9s=";

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

  meta = {
    description = "Simple and extensible webmail";
    homepage = "https://git.sr.ht/~migadu/alps";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      booklearner
      madonius
      hmenke
    ];
    mainProgram = "alps";
  };
}
