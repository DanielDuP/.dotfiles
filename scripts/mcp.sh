#!/usr/bin/env bash

# Remote MCP servers registered with harnesses that keep MCP config in
# app-managed files (Codex: ~/.codex/config.toml, Claude Code: ~/.claude.json).
# Those files also hold state each app writes itself, so they are not stowed;
# servers are registered through each harness's own `mcp add` CLI instead.
#
# Keep in sync with:
#   stow/opencode/.config/opencode/opencode.json
#   stow/cursor/.cursor/mcp.json
MCP_SERVERS=(
	"linear https://mcp.linear.app/mcp"
	"sentry https://mcp.sentry.dev/mcp"
	"posthog https://mcp.posthog.com/mcp?readonly=true"
	"notion https://mcp.notion.com/mcp"
)

# https://developers.openai.com/codex/extend/mcp
# `codex mcp add <name> --url <url>` writes [mcp_servers.<name>] to
# ~/.codex/config.toml, shared by the Codex CLI, IDE extension, and desktop app.
# OAuth: `codex mcp login <name>`.
setup_codex_mcp_servers() {
	if ! hash codex &>/dev/null; then
		warn "codex not installed, skipping Codex MCP servers"
		return
	fi

	local entry name url
	for entry in "${MCP_SERVERS[@]}"; do
		read -r name url <<<"$entry"
		if codex mcp get "$name" &>/dev/null; then
			info "Codex MCP server '$name' already configured"
		else
			info "Adding Codex MCP server '$name'"
			codex mcp add "$name" --url "$url"
		fi
	done
}

# https://code.claude.com/docs/en/mcp
# `claude mcp add --transport http --scope user <name> <url>` writes the server
# to ~/.claude.json so it loads in all projects. OAuth: `/mcp` inside Claude Code.
setup_claude_mcp_servers() {
	if ! hash claude &>/dev/null; then
		warn "claude not installed, skipping Claude Code MCP servers"
		return
	fi

	local entry name url
	for entry in "${MCP_SERVERS[@]}"; do
		read -r name url <<<"$entry"
		if claude mcp get "$name" &>/dev/null; then
			info "Claude Code MCP server '$name' already configured"
		else
			info "Adding Claude Code MCP server '$name'"
			claude mcp add --transport http --scope user "$name" "$url"
		fi
	done
}

setup_mcp_servers() {
	setup_codex_mcp_servers
	setup_claude_mcp_servers
}
