#!/usr/bin/env nix-shell
#!nix-shell -i bash -A frontend.env

set -eu

cd frontend
cabal configure --ghcjs
cabal build
cd ..

builddir=frontend/dist/build/frontend/frontend.jsexe
jsdir=serve/static/js

mkdir -p $jsdir

copyjs () {
  cp $builddir/$1.js $jsdir/$2.js
}

copyjs lib lib
copyjs rts rts
copyjs out app
cat $builddir/runmain.js >> $jsdir/app.js
