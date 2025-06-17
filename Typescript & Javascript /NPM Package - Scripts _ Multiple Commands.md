---
created: 2025-06-17T09:28:26+02:00
modified: 2025-06-17T09:35:47+02:00
---

# NPM Package - Scripts | Multiple Commands

Install concurrently:
```
npm i --save-dev concurrently
```

Use concurrently in scripts, eg. with NextJS:
```
"scripts": {
    "json-server": "json-server --watch json_server/db.json --port 8080",
    "dev": "next dev --turbopack",
    "dev-json-server": "concurrently \"json-server\" \"dev\"",
}
```
