# reflex-snap-upload-example

These instructions are for `stack` users.

First install the backend. This will place `upload-backend` in `~/.local/bin` (you should have in your $PATH):

    cd backend && stack setup && stack install
    
A compiled version of the frontend is already included in `serve/static/js/all.js`. If you'd rather compile yourself:

    cd frontend && stack setup && stack build
    
Then copy all.js from `$(stack --local-install-root)` to the above path.

Finally start the backend:

    cd serve && upload-backend
    
and visit http://localhost:8000. Check for uploaded files in `serve/upload`.
