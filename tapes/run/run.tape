# VM0 Run Demo
Output run.gif

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

Type "# Run an agent"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 run compose-demo 'What is 2+2?'"
Enter
Wait+Screen@120s /Run completed|completed successfully/
Sleep 3s
