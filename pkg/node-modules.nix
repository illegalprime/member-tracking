{ mkYarnModules }:
let
  js = mkYarnModules {
    pname = "assets";
    version = "1.0.0";
    packageJSON = ../assets/package.json;
    yarnLock = ../assets/yarn.lock;
  };
in
"${js}/node_modules"
