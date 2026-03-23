# koribot24 · Emacs Config

> `M-x my-help` inside Emacs for the full reference.

## Setup

**With internet**
```bash
git clone <repo> ~/.emacs.d && emacs
M-x install-default-packages
```

**Offline / exact restore**
```bash
git clone <repo> ~/.emacs.d && emacs
M-x install-packages-from-lock
```

## Package System

| | |
|---|---|
| `package.default` | Your explicit list. Edit this. Auto-updated on install/delete. |
| `package.lock/manifest.el` | `name=url@commit [:dep-of parent]`. Auto-generated. |
| `package.lock/*.tar.gz` | One archive per pkg + dep. Commit to git. |

- `package-install` → archives pkg + deps, records `:dep-of`, updates `package.default`
- `package-delete` → removes pkg + all its recorded deps, resyncs `package.lock/`

## Commands

| Command | |
|---|---|
| `install-default-packages` | Install from `package.default`, archive everything |
| `install-packages-from-lock` | Extract archives into `elpa/`, no internet |
| `view-package-lock` | Show lock contents |
| `cfg` / `cfg-file` | Open config dir / `init.el` |
| `my-help` | Open in-editor reference |
| `my-mode` | Switch major mode with fuzzy search |
| `my-theme-switch` | Switch theme interactively |

## Theme System

Themes are defined in `configs/theme.el`. Each theme is a plist with `:name`, `:base`, `:faces`, and `:lsp` keys.

| Theme | Base | Notes |
|---|---|---|
| Default | tango-dark | Warm amber tones |
| Rosé Pine | modus-vivendi | Dark purple, pink accents, gold cursor |

**Font selection** is automatic per OS:
- **Linux** → `DejaVu Sans Mono`
- **Windows** → `Lucida Console`
- **macOS** → `Menlo`
- Falls back to `monospace` if not found

To add a new theme, append a new `(list :name ... :base ... :faces ... :lsp ...)` entry to `my-themes` in `configs/theme.el`.

## Structure

```
~/.emacs.d/
├── early-init.el
├── init.el
├── package.default
├── help.org
├── package.lock/
│   ├── manifest.el
│   └── *.tar.gz
└── configs/
    ├── completion.el
    ├── custom.el
    ├── dirs.el
    ├── functions.el
    ├── keybindings.el
    ├── language-mode.el
    ├── theme.el
    └── ui.el
```