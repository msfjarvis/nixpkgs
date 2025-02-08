{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nixVersions,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "nil";
  version = "2e24c9834e3bb5aa2a3701d3713b43a6fb106362";

  src = fetchFromGitHub {
    owner = "oxalica";
    repo = pname;
    rev = version;
    hash = "sha256-DCIVdlb81Fct2uwzbtnawLBC/U03U2hqx8trqTJB7WA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Q4wBZtX77v8CjivCtyw4PdRe4OZbW00iLgExusbHbqc=";

  nativeBuildInputs = [
    (lib.getBin nixVersions.latest)
  ];

  env.CFG_RELEASE = version;

  # might be related to https://github.com/NixOS/nix/issues/5884
  preBuild = ''
    export NIX_STATE_DIR=$(mktemp -d)
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Yet another language server for Nix";
    homepage = "https://github.com/oxalica/nil";
    changelog = "https://github.com/oxalica/nil/releases/tag/${version}";
    license = with licenses; [
      mit
      asl20
    ];
    maintainers = with maintainers; [
      figsoda
      oxalica
    ];
    mainProgram = "nil";
  };
}
