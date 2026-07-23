#!/usr/bin/env python3
"""elisp-lsp-server: LSP server for Emacs Lisp via Emacs daemon."""

import sys
import json
import subprocess

def send_response(response):
    """Send JSON-RPC response to stdout."""
    body = json.dumps(response)
    sys.stdout.write(f"Content-Length: {len(body.encode())}\r\n\r\n{body}")
    sys.stdout.flush()

def send_notification(method, params):
    """Send JSON-RPC notification to stdout."""
    notif = {"jsonrpc": "2.0", "method": method, "params": params}
    body = json.dumps(notif)
    sys.stdout.write(f"Content-Length: {len(body.encode())}\r\n\r\n{body}")
    sys.stdout.flush()

def daemon_eval(form_str):
    """Evaluate a form in Emacs daemon."""
    try:
        result = subprocess.run(
            ["emacsclient", "-e", form_str],
            capture_output=True, text=True, timeout=5
        )
        return result.stdout.strip()
    except:
        return None

def daemon_eval_json(form_str):
    """Evaluate form in daemon, parse JSON result.
    The daemon returns JSON strings, which emacsclient quotes.
    We need double-parse: first unquote, then parse JSON."""
    raw = daemon_eval(form_str)
    if raw and raw != "nil" and raw != '"null"':
        try:
            parsed = json.loads(raw)
            if isinstance(parsed, str):
                return json.loads(parsed)
            return parsed
        except:
            return None
    return None

def read_message():
    """Read one LSP message from stdin."""
    content_length = 0
    
    # Read headers
    while True:
        line = sys.stdin.readline()
        if not line:
            return None
        line = line.strip()
        if line == "":
            break
        if line.startswith("Content-Length:"):
            content_length = int(line.split(":")[1].strip())
    
    if content_length == 0:
        return None
    
    # Read body
    body = sys.stdin.read(content_length)
    return json.loads(body)

def handle_request(msg):
    """Handle a JSON-RPC request."""
    method = msg.get("method")
    msg_id = msg.get("id")
    params = msg.get("params", {})
    
    if method == "initialize":
        return {"jsonrpc": "2.0", "id": msg_id, "result": {
            "capabilities": {
                "textDocumentSync": {"openClose": True, "change": 1, "save": True},
                "hoverProvider": True,
                "completionProvider": {"resolveProvider": False, "triggerCharacters": ["(", " ", "-"]},
                "publishDiagnostics": True
            }
        }}
    
    elif method == "initialized":
        return None
    
    elif method == "shutdown":
        return {"jsonrpc": "2.0", "id": msg_id, "result": None}
    
    elif method == "textDocument/hover":
        td = params.get("textDocument", {})
        uri = td.get("uri", "")
        pos = params.get("position", {})
        line = pos.get("line", 0)
        char = pos.get("character", 0)
        
        form = f'(elisp-lsp-hover-json "{uri}" {line} {char})'
        result = daemon_eval_json(form)
        return {"jsonrpc": "2.0", "id": msg_id, "result": result or {"contents": None}}
    
    elif method == "textDocument/completion":
        td = params.get("textDocument", {})
        uri = td.get("uri", "")
        pos = params.get("position", {})
        line = pos.get("line", 0)
        char = pos.get("character", 0)
        
        form = f'(elisp-lsp-complete-json "{uri}" {line} {char})'
        result = daemon_eval_json(form)
        return {"jsonrpc": "2.0", "id": msg_id, "result": result or {"isIncomplete": False, "items": []}}
    
    elif method == "textDocument/didOpen":
        td = params.get("textDocument", {})
        uri = td.get("uri", "")
        text = td.get("text", "")
        
        # Sync buffer
        escaped = text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
        form = f'(elisp-lsp-sync-buffer "{uri}" "{escaped}")'
        daemon_eval(form)
        
        # Get diagnostics
        diag_form = f'(elisp-lsp-diagnostics-json "{uri}")'
        diags = daemon_eval_json(diag_form)
        if diags:
            send_notification("textDocument/publishDiagnostics", {"uri": uri, "diagnostics": diags})
        
        return None
    
    elif method == "textDocument/didChange":
        td = params.get("textDocument", {})
        uri = td.get("uri", "")
        changes = params.get("contentChanges", [])
        
        if changes:
            new_text = changes[0].get("text", "")
            escaped = new_text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
            form = f'(elisp-lsp-sync-buffer "{uri}" "{escaped}")'
            daemon_eval(form)
        
        diag_form = f'(elisp-lsp-diagnostics-json "{uri}")'
        diags = daemon_eval_json(diag_form)
        if diags:
            send_notification("textDocument/publishDiagnostics", {"uri": uri, "diagnostics": diags})
        
        return None
    
    elif method == "textDocument/didSave":
        td = params.get("textDocument", {})
        uri = td.get("uri", "")
        
        diag_form = f'(elisp-lsp-diagnostics-json "{uri}")'
        diags = daemon_eval_json(diag_form)
        if diags:
            send_notification("textDocument/publishDiagnostics", {"uri": uri, "diagnostics": diags})
        
        return None
    
    return None

def main():
    """Main loop."""
    # Initialize daemon connection
    init_form = """(progn
      (add-to-list 'load-path \"~/.emacs.d/site-lisp/elisp-lsp\")
      (unless (fboundp 'elisp-lsp-daemon-init)
        (require 'elisp-lsp-daemon)
        (elisp-lsp-daemon-init)))"""
    daemon_eval(init_form)
    
    # Main LSP loop
    while True:
        msg = read_message()
        if msg is None:
            break
        
        response = handle_request(msg)
        if response:
            send_response(response)

if __name__ == "__main__":
    main()
