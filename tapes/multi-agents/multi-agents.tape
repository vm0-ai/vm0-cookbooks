# VM0 Multi-Agents Demo
Output multi-agents.gif

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

Type "# Initialize shared artifact"
Sleep 1s
Enter
Sleep 1s

Type "mkdir my-artifact && cd my-artifact"
Enter
Sleep 2s

Type "vm0 artifact init"
Enter
Sleep 2s

# Accept default name
Enter
Sleep 3s

Type "vm0 artifact push"
Enter
Sleep 4s

Type "# Agent-1: Write a question"
Sleep 1s
Enter
Sleep 1s

Type "vm0 run agent-1 --artifact-name my-artifact 'Write 1+1=? to question.md'"
Enter
Wait+Screen@120s /Run completed|completed successfully/
Sleep 8s

Type "# Agent-2: Read question and write answer"
Sleep 1s
Enter
Sleep 1s

Type "vm0 run agent-2 --artifact-name my-artifact 'Read question.md and answer it in answer.md'"
Enter
Wait+Screen@120s /Run completed|completed successfully/
Sleep 3s

Type "# Pull artifact and show results"
Sleep 1s
Enter
Sleep 1s

Type "vm0 artifact pull"
Enter
Sleep 4s

Type "cat question.md"
Enter
Sleep 5s

Type "cat answer.md"
Enter
Sleep 6s
