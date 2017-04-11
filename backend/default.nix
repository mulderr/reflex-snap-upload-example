{ mkDerivation, base, bytestring, directory, filepath
, MonadCatchIO-transformers, mtl, snap-core, snap-loader-static
, snap-server, stdenv, text, time
}:
mkDerivation {
  pname = "backend";
  version = "0.1";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base bytestring directory filepath MonadCatchIO-transformers mtl
    snap-core snap-loader-static snap-server text time
  ];
  description = "Project Synopsis Here";
  license = stdenv.lib.licenses.bsd3;
}
