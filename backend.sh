#!/usr/bin/env nix-shell
#!nix-shell -i bash -A backend.env

set -eu

cd "backend"
cabal configure
cabal build
cd ..

mkdir -p serve/log
cd serve
[ -d tmp ] || mkdir tmp
[ -d upload ] || mkdir upload
../backend/dist/build/backend/backend
