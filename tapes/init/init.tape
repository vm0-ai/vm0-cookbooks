# VM0 Init Demo
Output init.gif

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

Type "# Initialize a new VM0 agent"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 init"
Enter
Sleep 2s

# Accept default name
Enter
Sleep 2s

Type "# View generated files"
Sleep 500ms
Enter
Sleep 300ms

Type "ls -la"
Enter
Sleep 2s

Type "cat vm0.yaml"
Enter
Sleep 3s

Type "cat AGENTS.md"
Enter
Sleep 3s
