#!/usr/bin/env node

import { execSync } from "node:child_process";
import process from "node:process";
import { Readability } from "@mozilla/readability";
import { JSDOM } from "jsdom";
import TurndownService from "turndown";
import { gfm } from "turndown-plugin-gfm";

const url = process.argv[2];

if (!url) {
  console.log("Usage: browser-content.js <url>");
  console.log("\nExtracts readable content from a URL as markdown.");
  console.log("\nExamples:");
  console.log("  browser-content.js https://example.com");
  console.log(
    "  browser-content.js https://en.wikipedia.org/wiki/Rust_(programming_language)",
  );
  process.exit(1);
}

const outerHTML = execSync(
  `agent-browser --profile Default read --raw ${url}`,
  {
    encoding: "utf8",
  },
);

// Extract with Readability
const doc = new JSDOM(outerHTML, { url });
const reader = new Readability(doc.window.document);
const article = reader.parse();

// Convert to markdown
function htmlToMarkdown(html) {
  const turndown = new TurndownService({
    headingStyle: "atx",
    codeBlockStyle: "fenced",
  });
  turndown.use(gfm);
  turndown.addRule("removeEmptyLinks", {
    filter: (node) => node.nodeName === "A" && !node.textContent?.trim(),
    replacement: () => "",
  });

  // Convert HTML to markdown string
  let markdown = turndown.turndown(html);

  // Clean up specific markdown formatting issues
  markdown = markdown.replace(/\[\\?\[\s*\\?\]\([^)]*\)/g, ""); // Remove escaped link patterns
  markdown = markdown.replace(/ +/g, " "); // Collapse multiple spaces to single space
  markdown = markdown.replace(/\s+,/g, ","); // Remove spaces before commas
  markdown = markdown.replace(/\s+\./g, "."); // Remove spaces before periods
  markdown = markdown.replace(/\n{3,}/g, "\n\n"); // Limit consecutive newlines to max 2

  return markdown.trim(); // Remove leading/trailing whitespace
}

const content = htmlToMarkdown(article.content);
console.log(`URL: ${url}`);
if (article?.title) console.log(`Title: ${article.title}`);
if (article?.byline) console.log(`Author: ${article.byline}`);
console.log("");
console.log(content);

execSync(`agent-browser close`);

process.exit(0);
