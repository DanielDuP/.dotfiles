# Agent skills

Skill content lives once in `skills/<name>/SKILL.md`. The `agent-skills` Stow
package installs per-skill adapters into `.claude/skills`, `.cursor/skills`, and
`.agents/skills` so Claude Code, Cursor, Codex, and OpenCode share the same
instructions without replacing existing global skill directories.

Supporting executables live under `scripts/` and are installed by the
`agent-tools` Stow package.
