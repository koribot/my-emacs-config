# Emacs Config

## Structure
```
~/.emacs.d/
├── early-init.el         # runs before init
├── init.el               # entry point, loads all modules
├── extensions.txt        # package names, edit this
├── extensions.lock       # pinned versions, auto-managed
├── package-cache/        # cached package tars, committed to git
├── configs/
│   ├── custom.el         # faces and variables, auto-managed by Emacs
│   ├── ui.el             # line numbers, dired, desktop save, indentation
│   ├── completion.el     # ivy, counsel, swiper
│   ├── language-mode.el  # language modes, dumb-jump
│   ├── functions.el      # custom functions, package management
│   ├── keybindings.el    # global keybindings
│   └── dirs.el           # recent/popular directory tracking
├── backups/              # auto-created
├── auto-saves/           # auto-created
├── eln-cache/            # native compiled elisp, auto-created
└── elpa/                 # installed packages, auto-created
```

## New Machine
1. Clone to `~/.emacs.d/`
2. Open Emacs, ignore errors
3. `M-x install-my-packages`
4. Restart

## After Stable Setup
- `M-x my-cache-all-packages`
- `M-x pin-all-packages-versions-to-extensions.lock`
- Commit including `package-cache/`

## Quick Help
- `M-x my-help` — opens help buffer inside Emacs with all commands and keybindings

## Package Commands
| Command | What it does |
|---|---|
| `install-my-packages` | reads extensions.txt, skips already installed, checks package-cache first for missing ones, falls back to MELPA if not cached, updates lock after |
| `view-upgradable-packages` | shows packages with newer versions available, press U to upgrade all, u for one, p to pin one, P to pin all |
| `upgrade-packages` | upgrades all to latest, purges old cache tar, saves new cache tar, updates lock |
| `upgrade-package-to-version` | upgrades one package, prompts for name and version, updates cache and lock |
| `pin-package-version` | writes a version to the lock file without reinstalling |
| `pin-all-packages-versions-to-extensions.lock` | writes all current installed versions to lock |
| `my-cache-all-packages` | tars all currently installed packages into package-cache/ |
| `view-package-cache` | shows what is in package-cache/ with sizes, press c to cache all, d to clear |
| `clear-package-cache` | deletes all cached tars |
| `sync-installed-packages-to-extensions.txt` | manually force rewrites extensions.txt and extensions.lock |

## Keybindings
| | |
|---|---|
| `C-x C-f` | open file |
| `C-x b` | switch buffer |
| `C-s` | search |
| `C-l` | up a directory |
| `C-c r` | recent dirs |
| `C-c p` | popular dirs |
| `C-,` | duplicate line/region |
| `C-tab` | next buffer/window |
| `C-S-tab` | prev buffer/window |
| `C-c m n/p/a/e` | multiple cursors |
| `F3/F4/F5` | macro record/stop/run |
| `M-.` | jump to definition |
| `M-,` | jump back |
| `M-x cfg` | config dir |
| `M-x cfg-file` | init.el |
| `C-h f` | describe function |
| `C-h k` | describe key |

## Docs
| Language | Command |
|---|---|
| C | `man 3 printf` or `M-x man` |
| Go | `go doc fmt.Println` |
| Python | `python3 -m pydoc os.path` |
| Rust | `rustup doc` or browser: docs.rs |
| JavaScript | browser: developer.mozilla.org |
| Lua | browser: lua.org/manual |
| Shell/syscalls | `man 2 open` |