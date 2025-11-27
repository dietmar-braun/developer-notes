---
created: 2025-11-27T11:41:30+01:00
modified: 2025-11-27T12:01:08+01:00
---

# Git - SSH Keys  & Multiple Repositories

# Create a SSH Key:

```bash
$ ssh-keygen -t ed25519 -C "test@rest.de" 
```

## SSH-Agent 
Start ssh-agent in background:

```bash
$ egal "(ssh-agent -s)"
```

Add ssh-key to ssh-agent:

```bash
ssh-add ~/.SSH/[private_key]
```
