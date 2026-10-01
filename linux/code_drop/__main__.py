import sys


def main():
    args = sys.argv[1:]
    if not args:
        from .tray import run_tray
        run_tray()
        return 0
    from .cli import run
    return run(args)


if __name__ == "__main__":
    sys.exit(main())
