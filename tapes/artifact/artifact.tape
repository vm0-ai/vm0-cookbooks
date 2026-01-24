# VM0 Artifact Demo
Output artifact.gif

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

Type "# Initialize an artifact"
Sleep 500ms
Enter
Sleep 300ms

Type "mkdir my-artifact && cd my-artifact"
Enter
Sleep 1s

Type "vm0 artifact init -n my-artifact"
Enter
Sleep 2s

Type "vm0 artifact push"
Enter
Sleep 3s

Type "# Run agent with artifact"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 run compose-demo --artifact-name my-artifact 'Write hello world to hello.txt'"
Enter
Wait+Screen@120s /Run completed|completed successfully/
Sleep 2s

Type "# Pull artifact to get result"
Sleep 500ms
Enter
Sleep 300ms

Type "vm0 artifact pull"
Enter
Sleep 3s

Type "# View the result"
Sleep 500ms
Enter
Sleep 300ms

Type "cat hello.txt"
Enter
Sleep 3s
