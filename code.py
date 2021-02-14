#!/usr/bin/env python3

"""
source: https://github.com/chvolkmann/code-connect

code.py allows arbitrary SSH terminals to launch
VSCode Remote SSH sessions via the "code" command
"""

# based on https://stackoverflow.com/a/60949722

import time
import subprocess as sp
import os
from distutils.spawn import find_executable
from typing import Iterable, List, Tuple
from pathlib import Path
import sys

MAX_IDLE_TIME = 4 * 60 * 60

def fail(*msgs, retcode=1):
    for msg in msgs:
        print(msg)
    exit(retcode)

def is_socket_open(path: Path) -> bool:
    try:
        # capture output to prevent printing to stdout/stderr
        proc = sp.run(['socat', '-u', 'OPEN:/dev/null', f'UNIX-CONNECT:{path.resolve()}'], capture_output=True)
        return (proc.returncode == 0)
    except FileNotFoundError:
        return False

def sort_by_access_timestamp(paths: Iterable[Path]) -> List[Tuple[float, Path]]:
    paths = [(p.stat().st_atime, p) for p in paths]
    paths = sorted(paths, reverse=True)
    return paths

def next_open_socket(socks: Iterable[Path]) -> Path:
    try:
        return next((sock for sock in socks if is_socket_open(sock)))
    except StopIteration:
        fail(
            'Could not find an open VS Code IPC socket.',
            '',
            'Please make sure to connect to this machine with a standard VS Code remote SSH session before using this tool.'
        )

def check_for_binaries():
    if find_executable('socat') is None:
        fail(
            '"socat" not found in $PATH, but is required for code-connect'
        )

def main(shell: str = None, max_idle_time: int = MAX_IDLE_TIME):
    check_for_binaries()

    # Determine shell for outputting the proper format
    if not shell:
        shell = os.getenv('SHELL', 'bash')
    shell_path = Path(shell)
    if shell_path.exists():
        # Just get the name of the binary
        shell = shell_path.name
    
    # Every entry in ~/.vscode-server/bin corresponds to a commit id
    # Pick the most recent one
    code_repos = sort_by_access_timestamp(Path.home().glob('.vscode-server/bin/*'))
    if len(code_repos) == 0:
        fail(
            'No installation of VS Code Server detected!',
            '',
            'Please connect to this machine through a remote SSH session and try again.',
            'Afterwards there should exist a folder under ~/.vscode-server'
        )

    _, code_repo = code_repos[0]

    code_binary = code_repo / 'bin' / 'code'

    # List all possible sockets for the current user
    # Some of these are obsolete and not listening
    uid = os.getuid()
    socks = sort_by_access_timestamp(Path(f'/run/user/{uid}/').glob('vscode-ipc-*.sock'))

    # Only consider the ones that were active N seconds ago
    now = time.time()
    socks = [sock for ts, sock in socks if now - ts <= max_idle_time]

    # Find the first socket that is open, most recently accessed first
    ipc_sock = next_open_socket(socks)

    args = sys.argv.copy()
    args[0] = code_binary

    # set the path to the proper ipc socket
    os.environ["VSCODE_IPC_HOOK_CLI"] = str(ipc_sock)

    # run the "code" subprocess
    proc = sp.run(args)
    exit(proc.returncode)

if __name__ == '__main__':
    main()