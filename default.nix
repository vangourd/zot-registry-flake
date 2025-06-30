{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkgs,
}:

buildGoModule rec {
  pname = "zot";
  version = "2.1.5";
  nativeBuildInputs = [ pkgs.which pkgs.binutils pkgs.git ];

  src = fetchFromGitHub {
    owner = "project-zot";
    repo = "zot";
    rev = "v${version}";
    hash = "sha256-MWmCttGYNvZBGFgR+em5dvId7rme7J7EZuSXKjlD0p8=";
  };

  doCheck = false;

  vendorHash = "sha256-flXWc33tr+ARvLd9ooHUYz7TB1pnsrul1DuRlDP2Fp4=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Zot - A scale-out production-ready vendor-neutral OCI-native container image/artifact registry (purely based on OCI Distribution Specification)";
    homepage = "https://github.com/project-zot/zot";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "zot";
  };
}
