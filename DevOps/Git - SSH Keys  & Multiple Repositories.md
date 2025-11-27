---
created: 2025-11-27T11:41:30+01:00
modified: 2025-11-27T13:34:04+01:00
---

# Git - SSH Keys  & Multiple Repositories

# Create a SSH Key:

```bash
$ ssh-keygen -t ed25519 -C "test@rest.de" 
```

## SSH-Agent 
Start ssh-agent in background:

```bash
$ eval "(ssh-agent -s)"
```

Add ssh-key to ssh-agent:

```bash
ssh-add ~/.SSH/[private_key]
```

## Multiple Repositories 
### Define SSH-config

Define ~/.ssh/config

``` 
Host github.com-repo-1
       Hostname github.com 
       IdentifyFile=/home/[user]/.ssh/[key]

Host github.com-repo-2
       Hostname github.com 
       IdentifyFile=/home/[user]/.ssh/[key]

```

Adjust remote origin
```
git remote add origin git@github.com-repo-1:[repository_path]
```
