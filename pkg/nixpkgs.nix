builtins.fetchTarball {
  name = "nixpkgs-darwin-22.11-";
  sha256 = "1h0yd0xka6wj9sbbq34gw7a9qlp044b7dhg16bmn8bv96ix55vzj";
  url = let rev = "a08e061a4ee8329747d54ddf1566d34c55c895eb"; in
    "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
}
