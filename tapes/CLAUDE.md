# Tapes

This folder contains VHS tape files for generating VM0 CLI demo GIFs.

## Recording Principles

- **Prefer interactive mode**: When a command supports interactive prompts (e.g., `vm0 init`, `vm0 artifact init`), use interactive mode instead of flags. Press `Enter` to accept defaults rather than using `-n` or `--name` flags.
- **Use comments**: Add comment lines (e.g., `Type "# Step description"`) to explain what each step does.
- **Allow sufficient pauses**: Add adequate `Sleep` durations between commands for readability, especially after long-running commands (8s+ after agent runs).

## Creating New Tapes

Reference `template.tape` for base styling:

```tape
# Terminal settings
Set Shell bash
Set FontSize 22
Set FontFamily "Menlo"
Set Width 1200
Set Height 900
Set Padding 30
Set Theme "Dracula"
Set TypingSpeed 50ms
```

## Waiting for `vm0 run` to Complete

When running agents with `vm0 run`, use `Wait+Screen` to wait for completion:

```tape
Type "vm0 run my-agent 'do something'"
Enter
Wait+Screen@120s /Run completed successfully/
Sleep 8s
```

- Use the exact pattern `/Run completed successfully/` - do not use partial matches like `/Run completed/` which may trigger early
- Set a reasonable timeout (e.g., `@120s` for 2 minutes)
- Add a `Sleep` after the wait to let viewers see the result before the next command

## Generate GIF

```bash
vhs <name>.tape
```
