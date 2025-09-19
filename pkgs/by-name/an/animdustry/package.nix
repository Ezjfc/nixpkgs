{
  stdenv,
  lib,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  fetchFromGitHub,
  buildNimPackage,
  callPackage,
  libX11,
  libXcursor,
  libXrandr,
  libXinerama,
  libXi,
  libGL,
  libXxf86vm,
  libpulseaudio,
  fau ? callPackage ./fau.nix { }
}: let
  soloud = fetchFromGitHub {
    owner = "Anuken";
    repo = "soloud";
    rev = "60f27d7d63d2d3e6712e09cd7457320c68959f11";
    hash = "sha256-WGQH3fPeAvZ/7jKqW3tg5/Y1Hz3taeH8xX9c45t/RpA=";
    fetchSubmodules = true;
  };
in buildNimPackage (finalAttrs: {
  pname = "animdustry";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "Anuken";
    repo = "animdustry";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZEcjZ6eowwKDYbMX1INXYEtBVhBT6JlHekQlESgjiRM";
  };

  buildInputs = [
    stdenv.cc.cc.lib
    libX11
    libXcursor
    libXrandr
    libXinerama
    libXi
    libGL
    libXxf86vm
  ];
  nativeBuildInputs = [
    fau
    autoPatchelfHook
    copyDesktopItems
  ];
  runtimeDependencies = [
    libpulseaudio
  ];

  nimFlags = [
    "--app:gui"
    "-d:danger"
    "--path:\"${fau.src}/src\""

    "-d:NimblePkgVersion=${finalAttrs.version}"
  ];
  requiredNimVersion = 1;
  lockFile = ./lock.json;

  # WARNING: Accessing /tmp highly impure, should workaround Animdustry src.
  preBuild = ''
    [ -e "/tmp/soloud" ] && echo "assertion error: /tmp/soloud not empty"
    cp -r ${soloud} /tmp/soloud
    ${fau}/bin/faupack -p:"./assets-raw/sprites" -o:"./assets/atlas" --outlineFolder=outlined
  '';

  installPhase = ''
    runHook preInstall

    mv $out/bin/main $out/bin/animdustry
    install -Dm644 ./assets/icon.png $out/share/icons/hicolor/64x64/apps/animdustry.png

    runHook postInstall
  '';

  desktopItems = makeDesktopItem {
      name = "Animdustry";
      exec = "animdustry";
      icon = "animdustry";
      desktopName = "Animdustry";
      categories = [ "Game" ];
    };

  meta = {
    homepage = "https://github.com/Anuken/animdustry";
    downloadPage = "https://github.com/Anuken/animdustry/releases";
    description = "Anime gacha rhythm game";
    longDescription = ''
      The anime gacha bullet hell rhythm game that was created as a Mindustry (2022) April 1st event.
    '';
    license = with lib.licenses; [
      unfree
      cc-by-30
      cc-by-nd-30
    ];
    platforms = with lib.platforms; unix ++ windows;
    maintainers = with lib.maintainers; [
      Ezjfc
    ];
  };
})
