---
name: ralph-init
description: Use when starting a Ralph Loop implementation - creates specs through REQUIRED bidirectional prompting and user sign-off. Use before running ralph-run.
---

# Ralph Init: Create Specs for Ralph Loop

## Overview

Prepare a Ralph Loop by creating spec files through **mandatory bidirectional prompting**. Each iteration runs with fresh context, so specs must be complete and signed off BEFORE execution.

**Core principle:** You cannot create specs alone. You and the user must ask each other questions until fully aligned.

## When to Use

- Starting a Ralph Loop implementation
- Have a feature/phase to implement autonomously
- Need to create specs that Claude will execute without you present

## Red Flags - STOP

You are violating this skill if:
- You create specs without asking the user questions
- You present finished specs without requiring sign-off
- You skip the bidirectional prompting phase
- You don't check for existing design docs first

**If you do any of these, delete your work and restart this skill.**

## Phase 1: Gather Existing Context

First, check what already exists:

```bash
# Check for design docs
ls docs/plans/*-design.md

# Check project conventions
cat CLAUDE.md
cat MEMORY.md  # if exists
```

**If design doc exists:** You'll extract from it, but STILL do Phase 2.
**If no design doc:** You'll create from scratch via Phase 2.

## Phase 2: Bidirectional Prompting (MANDATORY)

**This phase is NOT optional.** You must ask questions until aligned.

### You Ask the User

Ask ONE question at a time. Wait for answer before next question.

Required topics to cover:
1. **Scope:** What's in scope? What's explicitly out of scope?
2. **Acceptance criteria:** How do we know it's done?
3. **Edge cases:** What could go wrong?
4. **Patterns:** Any existing code patterns to follow?
5. **Assumptions:** What are you assuming that might be wrong?

Continue until user says they have no more to add.

### Let the User Ask You

After your questions, ask: "What questions do you have for me about this implementation?"

Answer their questions. This reveals YOUR implicit assumptions.

**Stop condition:** Both you and user have no more questions.

## Phase 3: Write Spec Files

Create directory: `specs/{phase-name}/`

### spec.md (Requirements + Design)

```markdown
# [Phase Name]

## Goal
[One sentence - what this builds]

## Scope
**In scope:**
- [item 1]
- [item 2]

**Out of scope:**
- [item 1]

## Acceptance Criteria
- [ ] [criterion 1]
- [ ] [criterion 2]

## Technical Design
[Key decisions, data model, API changes]

## Edge Cases
| Case | Handling |
|------|----------|
| [case] | [how to handle] |
```

### implementation-plan.md (Checkboxed Tasks)

```markdown
# Implementation Plan: [Phase Name]

Complete tasks IN ORDER. Mark `- [ ]` as `- [x]` when done.

---

## [Section 1]

- [ ] Task 1.1: [specific action]
- [ ] Task 1.2: [specific action]

## [Section 2]

- [ ] Task 2.1: [specific action]

---

## Status
(Add when ALL tasks complete)
- [x] COMPLETE
```

**Task rules:**
- Each task = ONE action (2-5 minutes)
- Be specific (exact file paths, exact changes)
- Include test tasks after implementation tasks

### context.md (Project Conventions)

```markdown
# Context: [Phase Name]

## Commands
- Test: `[exact command]`
- Build: `[exact command]`
- Lint: `[exact command]`

## Key Patterns
[Code examples of patterns to follow]

## File Locations
- Models: `path/`
- APIs: `path/`
```

### PROMPT.md (Per-Iteration Instructions)

```markdown
# Ralph Loop: [Phase Name]

## Step 1: Read Specs
1. Read `specs/{phase}/spec.md`
2. Read `specs/{phase}/implementation-plan.md`
3. Read `specs/{phase}/context.md`

## Step 2: Pick ONE Task
Find the first `- [ ]` in implementation-plan.md.
This is your ONLY task for this iteration.

## Step 3: Implement
Follow patterns from context.md. Keep changes minimal.

## Step 4: Test
Write/run test. Fix if fails. Must pass before marking complete.

## Step 5: Mark Complete
Edit implementation-plan.md: change `- [ ]` to `- [x]`

## Step 6: Report
Summarize: task, files changed, test result.
```

## Phase 4: User Sign-Off (MANDATORY)

**You cannot skip this.**

Present all files to user:

```
Please review these files line by line:

1. specs/{phase}/spec.md
2. specs/{phase}/implementation-plan.md
3. specs/{phase}/context.md
4. PROMPT.md

Reply with "approved" or provide feedback.
```

**If user provides feedback:**
- Make changes
- Re-present for approval
- Repeat until approved

**Only proceed after explicit "approved" or "looks good".**

## Phase 5: Verify Setup

Checklist:
- [ ] `specs/{phase}/spec.md` exists
- [ ] `specs/{phase}/implementation-plan.md` exists with `- [ ]` tasks
- [ ] `specs/{phase}/context.md` exists
- [ ] `PROMPT.md` exists
- [ ] User has signed off

**Context budget:** Warn if combined specs > 15,000 tokens (~60,000 characters).

## Output

After completion:
- `specs/{phase}/spec.md`
- `specs/{phase}/implementation-plan.md`
- `specs/{phase}/context.md`
- `PROMPT.md`
- User sign-off received

Ready to run: `/ralph-run`
