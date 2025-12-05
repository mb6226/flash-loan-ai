"""
CLI runner to launch components programmatically. Works cross-platform; on Windows it can open components in new PowerShell windows.
Usage:
python scripts/cli.py start --component inference
python scripts/cli.py start --component all
"""
import argparse
import subprocess
import sys
import os
import platform

COMPONENTS = {
    'inference': ['python', '-m', 'src.ai.inference'],
    'listeners': ['python', '-m', 'src.blockchain.listeners'],
    'mempool_monitor': ['python', '-m', 'src.blockchain.mempool_monitor'],
}


def start_component(component: str, open_in_new_window: bool = False, shell_venv: str | None = None):
    if component not in COMPONENTS:
        raise ValueError('Unknown component: ' + component)

    cmd = COMPONENTS[component]

    if open_in_new_window and platform.system() == 'Windows':
        # Use powershell Start-Process to open a new window and run the command
        venv_activate = shell_venv and os.path.join(shell_venv, 'Scripts', 'Activate.ps1')

        if venv_activate and os.path.exists(venv_activate):
            full_cmd = f"& '{venv_activate}'; { ' '.join(cmd) }"
        else:
            full_cmd = ' '.join(cmd)

        # Wrap the command so PowerShell runs it in a new window
        subprocess.Popen(['powershell', '-NoExit', '-Command', full_cmd], cwd=os.getcwd())
        return True

    # Otherwise run as a background process using subprocess
    subprocess.Popen(cmd, cwd=os.getcwd())
    return True


def start_all(open_in_new_window: bool = False, shell_venv: str | None = None):
    procs = []
    for comp in COMPONENTS:
        res = start_component(comp, open_in_new_window=open_in_new_window, shell_venv=shell_venv)
        procs.append(res)
    return procs


def main(argv=None):
    parser = argparse.ArgumentParser(description='CLI to start flash-loan-ai components')
    subparsers = parser.add_subparsers(dest='cmd')

    start = subparsers.add_parser('start', help='start components')
    start.add_argument('--component', choices=list(COMPONENTS.keys()) + ['all'], default='all')
    start.add_argument('--new-window', action='store_true', help='Open component in new OS-specific window (Windows: PowerShell)')
    start.add_argument('--venv', type=str, default='./venv/', help='Path to virtual environment root')

    args = parser.parse_args(argv)

    if args.cmd == 'start':
        if args.component == 'all':
            start_all(open_in_new_window=args.new_window, shell_venv=args.venv)
        else:
            start_component(args.component, open_in_new_window=args.new_window, shell_venv=args.venv)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
