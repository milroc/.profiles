---
name: manage-skills
description: Manage personal Claude Code skills stored in the dotfiles repo. Use when the user wants to create, list, edit, sync, or remove custom slash commands.
argument-hint: <list|create|edit|sync|remove> [skill-name]
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Manage Skills

You are managing Claude Code skills stored in the user's `dotfiles` repo. Skills are stored in `claude/skills/<name>/SKILL.md` and symlinked to `~/.claude/skills/` via `bootstrap.sh`.

The `dotfiles` repo location is determined by finding the directory containing this skill file.

## Subcommands

Parse the user's argument to determine which subcommand to run.

### `list`

1. Glob for `claude/skills/*/SKILL.md` in the dotfiles repo
2. For each skill found, read its frontmatter and display:
   - Name
   - Description
   - Whether it's symlinked to `~/.claude/skills/`
3. Present as a concise table or list

### `create <name>`

1. Validate `<name>` is kebab-case (lowercase, hyphens only)
2. Create `claude/skills/<name>/SKILL.md` in the dotfiles repo with this template:

```markdown
---
name: <name>
description: TODO — describe when this skill should be used
argument-hint: [optional-args]
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# <Name>

TODO — write instructions for what Claude should do when this skill is invoked.
```

3. Run the sync step to symlink it immediately
4. Tell the user to edit the SKILL.md to fill in the TODOs

### `edit <name>`

1. Find `claude/skills/<name>/SKILL.md` in the dotfiles repo
2. Read it and present the contents to the user
3. Wait for the user to describe changes, then apply them with Edit

### `sync`

1. Find the dotfiles repo root (parent of `claude/skills/`)
2. Run:
```bash
mkdir -p "$HOME/.claude/skills"
for skill_dir in <repo>/claude/skills/*/; do
  skill_name="$(basename "$skill_dir")"
  ln -sfn "$skill_dir" "$HOME/.claude/skills/$skill_name"
done
```
3. Also clean up any dead symlinks in `~/.claude/skills/`
4. Report what was linked/unlinked

### `remove <name>`

1. Confirm with the user before deleting
2. Remove `claude/skills/<name>/` from the dotfiles repo
3. Remove the symlink from `~/.claude/skills/<name>`
4. Report what was removed
