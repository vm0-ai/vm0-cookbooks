# VM0 Quickstart Demo
Output quickstart.gif

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
Sleep 1s

Type "# 1. Initialize a new agent"
Sleep 1s
Enter
Sleep 1s

Type "vm0 init"
Enter
Sleep 2s

# Accept default name
Enter
Sleep 3s

Type "# 2. Upload to VM0 cloud"
Sleep 1s
Enter
Sleep 1s

Type "vm0 compose vm0.yaml"
Enter
Wait+Screen@60s /Compose created|Compose version exists/
Sleep 3s

Type "# 3. Run the agent"
Sleep 1s
Enter
Sleep 1s

Type "vm0 run quickstart 'What is 2+2?'"
Enter
Wait+Screen@120s /Run completed|completed successfully/
Sleep 4s
