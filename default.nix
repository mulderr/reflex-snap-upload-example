{ platform ? import ./deps/reflex-platform {}
}:

rec {
  backend = platform.ghc.callPackage ./backend {};
  frontend = platform.ghcjs.callPackage ./frontend {};
}
