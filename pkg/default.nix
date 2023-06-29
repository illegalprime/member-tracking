with import (import ./nixpkgs.nix) {};

let
  fetchMixDeps = callPackage ./fetch-mix-deps.nix {
    inherit (beam.packages.erlangR24) hex rebar rebar3;
    elixir = beam.packages.erlangR24.elixir_1_14;
  };

  buildMix = callPackage ./build-mix.nix {
    inherit (beam.packages.erlangR24) hex rebar rebar3;
    elixir = beam.packages.erlangR24.elixir_1_14;
    inherit fetchMixDeps;
  };
in
buildMix {
  pname = "member-tracking";
  version = "0.1.0";
  mixSha256 = "sha256-m/mu5YVA08oMh/Bt2jM2BeNJb9M7J7OJICbmT6iTEag=";
  src = builtins.fetchGit ../.;

  impureEnvVars = [
    "DATABASE_URL" "SECRET_KEY_BASE"
  ];
}
