#!/usr/bin/python3

import sys
from argparse import ArgumentParser
from subprocess import run, PIPE, STDOUT
from os import path, remove

def parse_args(args):
    """Parses command-line arguments."""
    parser = ArgumentParser(description="Install Azure Monitor Agent for Linux.")
    parser.add_argument(
        "--dcr-id",
        required=False,
        help="(Optional) The immutable ID of the Data Collection Rule to associate with the agent."
    )
    return parser.parse_args(args)

def combine_command(command):
    """Joins a list of command arguments into a single string for logging."""
    return " ".join(command)

def execute_command(command, cwd=None):
    """Executes a shell command, logs it, and raises an exception on failure."""
    print(f"Executing: {combine_command(command)}")
    results = run(command, stdout=PIPE, stderr=STDOUT, cwd=cwd, text=True)
    if results.returncode != 0:
        raise Exception(f"Command failed with exit code {results.returncode}\nOutput:\n{results.stdout}")
    print(results.stdout)
    return results

def main():
    """Main function to download, install, and configure the AMA."""
    args = parse_args(sys.argv[1:])
    installer_script = "AMAInstall.sh"

    try:
        # 1. Download the installer script
        download_url = "https://aka.ms/AMA-Linux-Installer-Script"
        execute_command(["wget", "-O", installer_script, download_url])

        # 2. Make the script executable
        execute_command(["chmod", "+x", installer_script])

        # 3. Run the installer, passing the DCR ID if provided
        install_command = [f"./{installer_script}"]
        if args.dcr_id:
            print(f"Data Collection Rule ID provided. Associating agent with DCR: {args.dcr_id}")
            install_command.extend(["--dcr-id", args.dcr_id])

        execute_command(install_command)

        print("\nSUCCESS: The Azure Monitor Agent artifact was applied successfully.")
        return 0

    except Exception as e:
        print(f"\nERROR: An error occurred during installation.\n{e}", file=sys.stderr)
        return 1

    finally:
        # 4. Clean up the downloaded script
        if path.exists(installer_script):
            print(f"Cleaning up installer script: {installer_script}")
            remove(installer_script)

if __name__ == "__main__":
    sys.exit(main())