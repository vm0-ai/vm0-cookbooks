# VM0 Compose Demo
Output compose.gif

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

Type "# Upload agent to VM0 cloud"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 compose vm0.yaml"
Enter
Wait+Screen@60s /Compose created|Compose version exists/
Sleep 3s
