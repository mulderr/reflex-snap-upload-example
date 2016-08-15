#!/bin/sh

./develop.hs upload-frontend ../serve/static/js/ |& grep -v '^Ignoring that'
