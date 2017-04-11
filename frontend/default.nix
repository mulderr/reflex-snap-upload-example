{ mkDerivation, base, ghcjs-base, ghcjs-dom, mtl, reflex
, reflex-dom, stdenv, text
}:
mkDerivation {
  pname = "frontend";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base ghcjs-base ghcjs-dom mtl reflex reflex-dom text
  ];
  homepage = "https://github.com/githubuser/ghcjs-upload#readme";
  description = "Initial project template from stack";
  license = stdenv.lib.licenses.bsd3;
}
