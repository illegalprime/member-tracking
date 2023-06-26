{ pkgs ? import (import ./pkg/nixpkgs.nix) {}}:
let
  inherit (pkgs) mkShell stdenv darwin;
  inherit (pkgs.lib) optional optionals;
  pwd = toString ./.;
in

mkShell {
  name = "phoenix";

  buildInputs = with pkgs; [
    elixir_1_14
    postgresql_15
    nodejs-16_x
    yarn
    git
  ]
  # For file_system on Linux.
  ++ optional stdenv.isLinux pkgs.inotify-tools
  # For file_system on macOS.
  ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    CoreFoundation
    CoreServices
  ]);

  MIX_HOME = "${pwd}/.mix";
  PGDATA = "${pwd}/_data";
  ESBUILD_BIN = "${pkgs.esbuild}/bin/esbuild";
  TAILWIND_BIN = "${pkgs.nodePackages.tailwindcss}/bin/tailwind";

  # expose all our scripts in the path
  shellHook = ''
    export PATH="''${PATH}:${pwd}/scripts"
    export NODE_PATH="''${NODE_PATH}:${pwd}/deps"
    export NODE_PATH="''${NODE_PATH}:${pkgs.callPackage ./pkg/node-modules.nix {}}"
    export GOOGLE_APPLICATION_CREDENTIALS="${pwd}/secrets/gcloud.json";
  '';
}
