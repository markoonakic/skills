---
name: ralph-run
description: Use when executing a Ralph Loop after specs are created and signed off via ralph-init. NOT for implementing features yourself.
---

# Ralph Run: Execute the Ralph Loop

## Overview

Run the Ralph Loop bash script that executes `claude -p` in a loop with **fresh context each iteration**. Specs created by `/ralph-init` guide each iteration.

**Core principle:** You are NOT implementing. You are RUNNING a script that implements.

## When to Use

- Specs exist in `specs/{phase}/` directory
- User has signed off on specs (via `/ralph-init`)
- You want autonomous execution, not manual implementation

## When NOT to Use

- No specs exist yet → Use `/ralph-init` first
- Specs not signed off → Get sign-off first
- You want to implement yourself → Just implement, don't use Ralph

## Red Flags - STOP

You are violating this skill if:
- You start implementing the feature yourself
- You skip checking if `ralph-loop.sh` exists
- You don't verify prerequisites
- You modify specs during execution (specs are source of truth)

**If you implement instead of running the script, stop. This skill is about execution, not implementation.**

## What is the Ralph Loop?

The Ralph Loop is a **bash script** that:

```bash
while not complete:
    claude -p "$(cat PROMPT.md)"  # Fresh context each time
    # Claude reads specs, picks ONE task, implements, tests, marks [x]
```

**Key insight:** Each iteration gets a FRESH context window. The specs are the source of truth, not conversation history.

## Relationship: Skill vs Script

| Component | Purpose |
|-----------|---------|
| This skill (`/ralph-run`) | Guide for running the loop |
| `ralph-loop.sh` | The actual bash script that executes |
| `PROMPT.md` | Instructions given to Claude each iteration |
| `specs/` | Source of truth for what to build |

**You invoke `/ralph-run` → It runs `ralph-loop.sh` → Script runs `claude -p` in a loop**

## Phase 1: Check Prerequisites

Before running, verify:

```bash
# Check specs exist
ls specs/*/spec.md specs/*/implementation-plan.md specs/*/context.md

# Check PROMPT.md exists
ls PROMPT.md

# Check ralph-loop.sh exists
ls ralph-loop.sh
```

**If `ralph-loop.sh` missing:**
- Check if template exists: `~/.claude/templates/ralph-loop.sh`
- Copy to project: `cp ~/.claude/templates/ralph-loop.sh .`
- Make executable: `chmod +x ralph-loop.sh`

**If specs missing:**
- Run `/ralph-init` first

## Phase 2: Verify Sign-Off

Ask user: "Have you reviewed and approved the specs?"

If no → Stop. Get sign-off first via `/ralph-init` Phase 4.

## Phase 3: Run the Loop

Execute the bash script:

```bash
./ralph-loop.sh [phase-name]
```

The script will:
1. Show iteration count
2. Count remaining unchecked tasks
3. Run `claude -p "$(cat PROMPT.md)"` with fresh context
4. Pause for review (press Enter to continue)
5. Stop when `[x] COMPLETE` found or max iterations hit

## Monitoring Progress

Watch `specs/{phase}/implementation-plan.md`:
- `- [ ]` = pending
- `- [x]` = complete

Remaining tasks = count of `- [ ]`

## Modes (Optional)

The script may support flags:

| Flag | Default | Description |
|------|---------|-------------|
| `--max-iterations` | 50 | Safety limit |
| `--no-pause` | false | Don't pause between iterations |

## Phase 4: Review Results

After loop completes:

1. **Check tests:** `cd backend && uv run pytest -v`
2. **Review changes:** `git diff`
3. **Check implementation-plan.md:** All tasks marked `[x]`?

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Script not found | Copy from `~/.claude/templates/ralph-loop.sh` |
| Specs not found | Run `/ralph-init` first |
| Tests failing | Stop loop, review recent changes, fix spec or code |
| Context errors | Specs may be too large (>15k tokens), consolidate |

## Summary

1. Check prerequisites (specs, PROMPT.md, ralph-loop.sh)
2. Verify user signed off on specs
3. Run `./ralph-loop.sh [phase]`
4. Monitor implementation-plan.md for progress
5. Review results after completion

**Remember: You RUN the loop, you don't IMPLEMENT the feature.**
