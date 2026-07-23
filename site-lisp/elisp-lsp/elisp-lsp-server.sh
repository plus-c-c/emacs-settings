#!/bin/bash
# elisp-lsp-server.sh - LSP server for Emacs Lisp via Emacs daemon
# Reads LSP messages from stdin, processes via emacsclient, writes to stdout

set -euo pipefail

DAEMON_EVAL=""
IN_BODY=0
CONTENT_LENGTH=0
BODY=""

send_response() {
    local resp="$1"
    local len=${#resp}
    printf "Content-Length: %d\r\n\r\n%s" "$len" "$resp" >&3
}

# Ensure daemon has our library loaded
emacsclient -e "(progn
  (add-to-list 'load-path \"$HOME/.emacs.d/site-lisp/elisp-lsp\")
  (unless (fboundp 'elisp-lsp-daemon-init)
    (require 'elisp-lsp-daemon)
    (elisp-lsp-daemon-init)))" >/dev/null 2>&1

# Main loop - read from stdin (fd 0), write to stdout (fd 3)
exec 3>&1

while IFS= read -r line || [[ -n "$line" ]]; do
    # Handle Content-Length header
    if [[ "$line" =~ ^Content-Length:\ ([0-9]+) ]]; then
        CONTENT_LENGTH="${BASH_REMATCH[1]}"
        IN_BODY=1
        BODY=""
        continue
    fi
    
    # Empty line marks end of headers
    if [[ "$line" == $'\r' ]] || [[ -z "$line" ]]; then
        if [[ $IN_BODY -eq 1 ]] && [[ $CONTENT_LENGTH -gt 0 ]]; then
            # Read body
            BODY=$(head -c "$CONTENT_LENGTH" <&0)
            
            # Call daemon to process
            RESULT=$(emacsclient -e "(elisp-lsp-process-message $(printf '%s' "$BODY" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'))" 2>/dev/null)
            
            # Send response if any
            if [[ -n "$RESULT" ]] && [[ "$RESULT" != "nil" ]]; then
                send_response "$RESULT"
            fi
            
            IN_BODY=0
            CONTENT_LENGTH=0
            BODY=""
        fi
        continue
    fi
done
