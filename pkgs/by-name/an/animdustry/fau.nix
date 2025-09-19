{
  fetchFromGitHub,
  buildNimPackage,
}:
buildNimPackage {
  pname = "fau";
  version = "0-unstable-2022-04-22";

  src = fetchFromGitHub {
    owner = "Anuken";
    repo = "fau";
    rev = "adbf05f2a83af3a277b50a4457b5f3e90469060a";
    hash = "sha256-0CnMKh+vgcrJRdMuOSSIcVLqRtfpFrQyH/UekpRbBOU=";
    fetchSubmodules = true;
  };

  requiredNimVersion = 1;
  lockFile = ./lock.json;
}
