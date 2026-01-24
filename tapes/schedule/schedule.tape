# VM0 Schedule Demo
Output schedule.gif

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

Type "# Schedule your agent with vm0 schedule"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 schedule init"
Enter
Sleep 2s

# Accept all interactive prompts with defaults
Enter
Sleep 1500ms
Enter
Sleep 1500ms
Enter
Sleep 1500ms
Enter
Sleep 1500ms
Enter
Sleep 2s

Type "# View generated schedule.yaml"
Sleep 500ms
Enter
Sleep 300ms

Type "cat schedule.yaml"
Enter
Sleep 3s

Type "# Deploy the schedule"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 schedule deploy"
Enter
Sleep 4s

Type "# List all schedules"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 schedule list"
Enter
Sleep 3s

Type "# Check schedule status"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 schedule status"
Enter
Sleep 4s
