#!/usr/bin/env python3
"""Serve Crystal Lane's Godot Web export with the correct WASM MIME type."""

from __future__ import annotations

import argparse
import http.server
import os
import socketserver


class WasmHandler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".js": "application/javascript",
        ".mjs": "application/javascript",
        ".pck": "application/octet-stream",
        ".png": "image/png",
        ".svg": "image/svg+xml",
        ".html": "text/html",
    }

    def end_headers(self) -> void:
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


def main() -> None:
    parser = argparse.ArgumentParser(description="Serve Crystal Lane Web build")
    parser.add_argument("--port", type=int, default=43180)
    parser.add_argument("--root", default=os.path.join(os.path.dirname(__file__), "..", "build", "web"))
    args = parser.parse_args()
    root = os.path.abspath(args.root)
    if not os.path.isdir(root):
        raise SystemExit(f"Web build not found: {root}\nRun ./export-web.sh first.")
    os.chdir(root)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("0.0.0.0", args.port), WasmHandler) as httpd:
        print(f"Crystal Lane Web — http://127.0.0.1:{args.port}/  (root {root})")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
