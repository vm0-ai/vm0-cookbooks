# vm0-cookbooks

## 101-intro

```
cd claude-files
vm0 volume init
vm0 volume push
```

```
cd lancy-files
vm0 artifact init
vm0 artifact push
```

```
vm0 build demo.yaml
vm0 run demo --artifact-name lancy-files "echo hello to hello.md"
```

```
cd lancy-files
vm0 artifact pull
cat hello.md
```

## resume & continue
vm0 run resume <checkpoint> "prompt"
vm0 run continue <session> "prompt"
