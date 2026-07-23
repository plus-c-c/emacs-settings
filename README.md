# Emacs Configuration

Modular Emacs 30.2 configuration for multi-environment workflows (Linux/Hyprland, Windows, macOS).

## Structure

```
~/.emacs.d/
├── early-init.el          # GC, GUI suppression, encoding
├── init.el                # Entry point
├── init.d/                # Modular configuration
│   ├── init-load-path.el  # Module loader
│   ├── init-packages.el   # Package management
│   ├── ui/                # Interface
│   ├── edit/              # Editing
│   ├── dev/               # Development
│   ├── app/               # Applications
│   ├── org/               # Org-mode
│   └── util/              # Utilities
├── site-lisp/             # Local packages
└── elp/                   # Installed packages
```

## Features

### UI (`ui/`)
- **Theme**: Dracula with all-the-icons
- **Dashboard**: Startup screen with recent files, projects, agenda
- **Fonts**: Configurable with fallback probes
- **Frame**: Tab-bar with M-s-* keybindings
- **Buffer**: Line numbers, mode-line customization

### Editing (`edit/`)
- **Completion**: Ivy, Counsel, Swiper with hydra
- **GPTel**: AI integration (Ollama, DeepSeek) with `C-c g`
- **Movement**: mwim (C-a/C-e), move-dup (M-P/M-N)
- **Parentheses**: highlight-parentheses, vundo (undo tree)
- **Auto-save**: Silent auto-save with trailing whitespace cleanup
- **Snippets**: Yasnippet with S-TAB expansion

### Development (`dev/`)
- **LSP**: lsp-bridge with hydra (`C-c l`)
- **DAP**: dape with language-specific hydras (`C-c D`, `C-c d`)
- **Projectile**: Project management with hydra (`C-c p`)
- **Treemacs**: File explorer with projectile integration
- **Tree-sitter**: Auto-installation with fingerprint pairing
- **Languages**:
  - Emacs Lisp: flymake diagnostics
  - Python: debugpy DAP
  - TypeScript/JavaScript: js-debug DAP
  - Bash: bash-debug DAP
  - Java: JDTLS + java-debug DAP
  - R: ess-tracebug with custom hydra
  - Racket: racket-debug-mode with custom hydra

### Applications (`app/`)
- **OpenCode**: AI coding assistant with vterm (`C-c o`)
  - Session management, project selection
  - Model/agent selection
  - Hydra menus for quick access
- **EAF**: Emacs Application Framework
  - Browser, PDF viewer, image viewer
  - Video player, music player
  - File manager, terminal
  - Per-app hydras (`C-c e`)
- **Magit**: Git integration
- **Paper Import**: PubMed, arXiv, CrossRef APIs

### Org-mode (`org/`)
- **Capture**: Quick note capture
- **Agenda**: Task management with hydra (`C-c a`)
- **Roam**: Knowledge management
- **Ref**: Reference management with hydra (`C-c r`)
- **Export**: LaTeX (Chinese support), HTML

### Utilities (`util/`)
- **Network**: Cached connectivity check
- **Device**: Platform-specific methods

---

## AI Integration

Two AI systems integrated:

### 1. GPTel (`edit/config-gptel.el`)

General-purpose LLM client for chat/completion.

**Keybindings**: `C-c g` (menu), `C-c G` (buffer)

**Backends**:

| Backend | Type | Models |
|---------|------|--------|
| Ollama-stream | Local | deepseek-r1, gemma3 |
| Ollama | Local | deepseek-r1, gemma3 |
| DeepSeek | API | deepseek-chat |

**Directives**: default, programming, writing, chat

**Features**: Streaming responses, org-mode output, expert commands

### 2. OpenCode (`app/config-opencode.el`)

AI coding assistant with LSP integration, terminal-based.

**Keybindings**: `C-c o` (main hydra), `C-c h` (session hydra)

**Session Hydra Keys**:
- Session: `n` new, `x` kill, `r` rename, `F` fork, `C` compact, `X` abort
- Add: `f` file, `b` buffer, `R` region, `A` subagent
- Model: `m` select, `v` variant, `a` cycle agent, `M` toggle MCP
- Navigate: `s` select, `c` child, `p` parent
- Share: `h` share, `u` unshare, `L` consult
- Misc: `y` yank code, `Y` copy conversation

**LSP Servers** (in `~/.config/opencode/opencode.jsonc`):

| Language | Command | Extensions |
|----------|---------|------------|
| Bash | bash-language-server | .sh, .bash |
| C/C++ | clangd | .c, .h, .cpp, .hpp |
| Python | pyright-langserver | .py |
| TypeScript | typescript-language-server | .ts, .tsx, .js |
| JSON | vscode-json-languageserver | .json, .jsonc |
| Elisp | elisp-lsp-server | .el |
| Racket | racket-langserver | .rkt, .rktl |

### 3. OpenCode Status (`app/config-opencode-status.el`)

Enhanced mode-line display for OpenCode sessions.

**Indicators**: Network (●), spinner, agent, model, context %, labels (📎), status (⏳/🚀)

### Comparison

| Feature | GPTel | OpenCode |
|---------|-------|----------|
| Purpose | General AI chat | AI coding assistant |
| Interface | Buffer-based | Terminal (vterm) |
| LSP | No | Yes (via config) |
| Backends | Ollama, DeepSeek | OpenCode server |
| Session | No | Yes |
| Code yank | No | Yes |

## Key Bindings

### Global
| Key | Command |
|-----|---------|
| `C-c g` | GPTel menu |
| `C-c o` | OpenCode hydra |
| `C-c w` | Browse web (EAF) |
| `C-c p` | Projectile hydra |
| `C-c a` | Org-agenda hydra |
| `C-c r` | Reference hydra |
| `C-c e` | EAF app hydra |
| `C-c D` | Start Dape |
| `C-c l` | LSP-bridge hydra |

### Projectile Hydra (`C-c p`)
| Key | Command |
|-----|---------|
| `f` | Find file |
| `b` | Switch buffer |
| `d` | Find directory |
| `e` | Recent files |
| `t` | Treemacs |
| `l` | LSP hydra |
| `d` | DAP hydra |
| `m` | Magit |

### DAP Hydra (`C-c d` when debug active)
| Key | Command |
|-----|---------|
| `i` | Info panel |
| `b` | Toggle breakpoint |
| `s` | Step in |
| `o` | Step out |
| `n` | Next |
| `c` | Continue |
| `r` | Restart |
| `q` | Quit |

## Installation

```bash
# Clone
git clone <repo> ~/.emacs.d

# Start Emacs (will auto-install packages)
emacs
```

## Dependencies

- Emacs 30.2+
- ripgrep (for counsel-projectile)
- fd (for projectile)
- curl (for API calls)
- Racket (for racket-mode)
- R (for ess)
- Java JDK (for JDTLS)
- Node.js (for js-debug)

## Platform Notes

### Linux (Hyprland)
- EAF uses wlroots window manager
- Auto-focus fix for QT windows

### Windows
- Pasteex for image pasting
- WebDAV path: `z:/mobile/org`

### macOS
- Native title bar
- iCloud sync path

## Customization

Edit files in `~/.emacs.d/init.d/`:
- `ui/` - Visual settings
- `edit/` - Editing behavior
- `dev/` - Development tools
- `app/` - Applications
- `org/` - Org-mode config

Each module uses `use-package` with deferred loading for performance.
