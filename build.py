#!/usr/bin/env python3
"""Executable script for building nt.sqlite"""

if __name__ == "__main__":
    from sql import build_ntsqlite

    build_ntsqlite(verbose=True)
