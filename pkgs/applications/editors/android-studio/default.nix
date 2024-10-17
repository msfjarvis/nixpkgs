{ callPackage, makeFontsConf, buildFHSEnv, tiling_wm ? false }:

let
  mkStudio = opts: callPackage (import ./common.nix opts) {
    fontsConf = makeFontsConf {
      fontDirectories = [];
    };
    inherit buildFHSEnv;
    inherit tiling_wm;
  };
  stableVersion = {
    version = "2024.2.1.10"; # "Android Studio Ladybug | 2024.2.1 Patch 1"
    sha256Hash = "sha256-rsIlwZ5Q16JUos93JhNgeYT3NSGYJ3PP2vmMWnIlPj8=";
  };
  betaVersion = {
    version = "2024.2.1.8"; # "Android Studio Ladybug | 2024.2.1 RC 1"
    sha256Hash = "sha256-Kb/1+g9rIuU/pAO1ue5h0+BU7OCE09QqV9XFoiJxBL4=";
  };
  latestVersion = {
    version = "2024.2.2.5"; # "Android Studio Ladybug Feature Drop | 2024.2.2 Canary 5"
    sha256Hash = "sha256-LlGjk0dSHVI5u/b942S5iu4RHv1D4KWg2Ge1TL47pvg=";
  };
in {
  # Attributes are named by their corresponding release channels

  stable = mkStudio (stableVersion // {
    channel = "stable";
    pname = "android-studio";
  });

  beta = mkStudio (betaVersion // {
    channel = "beta";
    pname = "android-studio-beta";
  });

  dev = mkStudio (latestVersion // {
    channel = "dev";
    pname = "android-studio-dev";
  });

  canary = mkStudio (latestVersion // {
    channel = "canary";
    pname = "android-studio-canary";
  });
}
