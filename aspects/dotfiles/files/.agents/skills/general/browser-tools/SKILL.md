---
name: browser-tools
description: Interactive browser automation. Use when you need to interact with web pages, test frontends, extract content, or when browser interaction is required.
---

# Browser Tools

## Setup

Run once before first use:

```bash
cd {baseDir}/browser-tools
npm install
```

## Extract Page Content

```bash
{baseDir}/browser-content.js https://example.com
```

Navigate to a URL and extract readable content as markdown. Uses Mozilla Readability for article extraction and Turndown for HTML-to-markdown conversion. Works on pages with JavaScript content (waits for page to load).
