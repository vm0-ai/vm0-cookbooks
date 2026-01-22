# Tapes

This folder contains VHS tape files for generating VM0 CLI demo GIFs.

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

## Generate GIF

```bash
vhs <name>.tape
```
