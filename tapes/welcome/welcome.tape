# VM0 Welcome Demo
Output welcome.gif

# Terminal settings
Set Shell bash
Set FontSize 22
Set FontFamily "Menlo"
Set Width 1200
Set Height 900
Set Padding 30
Set Theme "Dracula"
Set TypingSpeed 50ms

# Start demo
Sleep 500ms

Type "# Create a new VM0 agent"
Sleep 500ms
Enter
Enter
Sleep 300ms

Type "vm0 init"
Enter
Sleep 2s

# Accept default name
Enter
Sleep 2s

Type "vim AGENTS.md"
Enter
Sleep 5s

# Delete all content and enter insert mode
Type "ggdGi"
Sleep 500ms

# Type the new content
Type "Get the first article from HackerNews and write its title to result.md"
Sleep 500ms

# Exit insert mode and save
Escape
Sleep 300ms
Type ":wq"
Enter
Sleep 1s
Enter

Type "# Start the agent"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 cook start"
Enter
Wait+Screen@120s /Run completed successfully/
Sleep 8s

Type "cat artifact/result.md"
Enter
Sleep 5s
