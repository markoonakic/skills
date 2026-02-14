# Skills

Personal Claude Code skills for autonomous coding workflows.

## Ralph Loop

The `ralph/` directory contains a complete Ralph Loop implementation following the methodology from the Ralph Wiggum Loop video.

### Skills

| Skill | Description |
|-------|-------------|
| `ralph-init` | Create specs through bidirectional prompting + mandatory user sign-off |
| `ralph-run` | Execute the Ralph Loop bash script (NOT implement yourself) |

### Files

```
ralph/
├── ralph-init/
│   └── SKILL.md          # Skill for creating specs
├── ralph-run/
│   └── SKILL.md          # Skill for running the loop
└── ralph-loop.sh         # Bash script template
```

### Installation

Symlink to the Claude cache directory (where skills are actually loaded from):

```bash
# Skills go in the cache directory
ln -s ~/skills/ralph/ralph-init ~/.claude/plugins/cache/claude-plugins-official/superpowers/4.3.0/skills/
ln -s ~/skills/ralph/ralph-run ~/.claude/plugins/cache/claude-plugins-official/superpowers/4.3.0/skills/

# Template goes in templates directory
ln -s ~/skills/ralph/ralph-loop.sh ~/.claude/templates/
```

**Note:** Check your superpowers version (4.3.0 in path above) and adjust if different.

### Usage

1. `/ralph-init` - Create specs through interactive Q&A
2. `/ralph-run` - Execute the autonomous implementation loop

### Key Principles

- **Fresh context per iteration** - Each `claude -p` call gets clean context
- **Specs as source of truth** - Not conversation history
- **One task per iteration** - Prevents context rot
- **Mandatory sign-off** - User must approve every line before execution
