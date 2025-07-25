{ version, hash }:

{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  fusePackages,
  util-linux,
  gettext,
  shadow,
  meson,
  ninja,
  pkg-config,
  autoreconfHook,
  runtimeShell,
  udevCheckHook,
}:

let
  isFuse3 = lib.hasPrefix "3" version;
in
stdenv.mkDerivation rec {
  pname = "fuse";
  inherit version;

  src = fetchFromGitHub {
    owner = "libfuse";
    repo = "libfuse";
    rev = "${pname}-${version}";
    inherit hash;
  };

  patches =
    lib.optional (!isFuse3 && (stdenv.hostPlatform.isAarch64 || stdenv.hostPlatform.isLoongArch64))
      (fetchpatch {
        url = "https://github.com/libfuse/libfuse/commit/914871b20a901e3e1e981c92bc42b1c93b7ab81b.patch";
        sha256 = "1w4j6f1awjrycycpvmlv0x5v9gprllh4dnbjxl4dyl2jgbkaw6pa";
      })
    ++ (
      if isFuse3 then
        [
          ./fuse3-install.patch
          ./fuse3-Do-not-set-FUSERMOUNT_DIR.patch
        ]
      else
        [
          ./fuse2-Do-not-set-FUSERMOUNT_DIR.patch
          (fetchpatch {
            url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-fs/fuse/files/fuse-2.9.9-closefrom-glibc-2-34.patch?id=8a970396fca7aca2d5a761b8e7a8242f1eef14c9";
            sha256 = "sha256-ELYBW/wxRcSMssv7ejCObrpsJHtOPJcGq33B9yHQII4=";
          })
          ./fuse2-gettext-0.25.patch
        ]
    );

  nativeBuildInputs =
    if isFuse3 then
      [
        meson
        ninja
        pkg-config
      ]
      ++ lib.optionals (!stdenv.hostPlatform.isMusl) [ udevCheckHook ] # inf rec on musl, so skip
    else
      [
        autoreconfHook
        gettext
      ];

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
  ]
  ++ lib.optional isFuse3 "udev";

  mesonFlags = lib.optionals isFuse3 [
    "-Dudevrulesdir=/udev/rules.d"
    "-Duseroot=false"
    "-Dinitscriptdir="
    "-Dexamples=false" # examples fail on musl and are just generally useless
  ];

  # Ensure that FUSE calls the setuid wrapper, not
  # $out/bin/fusermount. It falls back to calling fusermount in
  # $PATH, so it should also work on non-NixOS systems.
  env.NIX_CFLAGS_COMPILE = ''-DFUSERMOUNT_DIR="/run/wrappers/bin"'';

  preConfigure = ''
    substituteInPlace lib/mount_util.c \
      --replace-fail "/bin/mount" "${lib.getBin util-linux}/bin/mount" \
      --replace-fail "/bin/umount" "${lib.getBin util-linux}/bin/umount"
    substituteInPlace util/mount.fuse.c \
      --replace-fail "/bin/sh" "${runtimeShell}"
  ''
  + lib.optionalString (!isFuse3) ''
    export MOUNT_FUSE_PATH=$bin/bin

    # Do not install these files for fuse2 which are not useful for NixOS.
    export INIT_D_PATH=$TMPDIR/etc/init.d
    export UDEV_RULES_PATH=$TMPDIR/etc/udev/rules.d

    # This is for `setuid=`, and needs root permission anyway.
    # No need to use the SUID wrapper.
    substituteInPlace util/mount.fuse.c \
      --replace-fail '"su"' '"${lib.getBin shadow.su}/bin/su"'
  '';

  # v2: no tests, v3: all tests get skipped in a sandbox
  doCheck = false;
  doInstallCheck = true;

  # Drop `/etc/fuse.conf` because it is a no-op config and
  # would conflict with our fuse module.
  postInstall = lib.optionalString isFuse3 ''
    rm $out/etc/fuse.conf
    mkdir $udev
    mv $out/etc $udev
  '';

  # Don't pull in SUID `fusermount{,3}` binaries into development environment.
  propagatedBuildOutputs = [ "out" ];

  meta = {
    description = "Library that allows filesystems to be implemented in user space";
    longDescription = ''
      FUSE (Filesystem in Userspace) is an interface for userspace programs to
      export a filesystem to the Linux kernel. The FUSE project consists of two
      components: The fuse kernel module (maintained in the regular kernel
      repositories) and the libfuse userspace library (this package). libfuse
      provides the reference implementation for communicating with the FUSE
      kernel module.
    '';
    homepage = "https://github.com/libfuse/libfuse";
    changelog = "https://github.com/libfuse/libfuse/releases/tag/fuse-${version}";
    platforms = lib.platforms.linux;
    license = with lib.licenses; [
      gpl2Only
      lgpl21Only
    ];
    maintainers = with lib.maintainers; [
      oxalica
    ];
    outputsToInstall = [ "bin" ];
  };
}
