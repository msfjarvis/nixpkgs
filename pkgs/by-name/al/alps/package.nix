{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  fetchpatch,
  nixosTests,
}:

buildGoModule {
  pname = "alps";
  version = "0-unstable-2025-11-26";

  src = fetchFromSourcehut {
    owner = "~migadu";
    repo = "alps";
    rev = "bd6a860d88e9ee02fc051f8596b042e7381b38fa";
    hash = "sha256-btrZp95Lts6wyO3kL5fppeCrtrGP9/s0x0ZAJL1D9ik=";
  };

  vendorHash = "sha256-dxmuxXnQVIFl7jdEn8tMfE/5QsdHmgujDHm53a+bxoE=";

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
