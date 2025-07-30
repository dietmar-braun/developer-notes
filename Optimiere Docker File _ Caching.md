---
created: 2025-07-30T17:56:51+02:00
modified: 2025-07-30T18:11:55+02:00
---

# Optimiere Docker File / Caching

1st Version
```
FROM diamol/node:2e
 
ENV TARGET="blog.sixeyed.com"
ENV METHOD="HEAD"
ENV INTERVAL="3000"
 
WORKDIR /web-ping
COPY app.js .
 
CMD ["node", "/web-ping/app.js"]
```

2nd version
``` 
FROM diamol/node:2e
 
CMD ["node", "/web-ping/app.js"]
 
ENV TARGET="blog.sixeyed.com" \
    METHOD="HEAD" \
    INTERVAL="3000"
 
WORKDIR /web-ping
COPY app.js .
```

If Something changed, all other sequences are build new! **Ignores the Cache**
