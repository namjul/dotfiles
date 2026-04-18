---
name: zx-markdown-scaffold
description: Generate executable zx Markdown scripts with inline documentation, proper globals, and ready-to-run code blocks.
license: MIT
compatibility: pi
metadata:
  audience: developers
  workflow: automation
---

# zx Markdown Scaffold

Creates executable markdown scripts using Google's zx library. These scripts combine documentation with executable code blocks that can be run directly.

## When to Use

- Creating automation scripts that need inline documentation
- Building reusable command-line tools
- Prototyping shell workflows with JavaScript/TypeScript
- Creating self-documenting build scripts

## Usage

Invoke this skill with a description of the script you want to create:

"Create a zx markdown script that [description]"

The skill will generate:
1. A `.md` file with embedded executable code blocks
2. Proper zx globals usage (no imports needed)
3. Error handling and user feedback
4. Documentation explaining the script


Lookout: the markdown file cannot contain a executable codeblock that references itself!

## Script Structure

Generated scripts follow this pattern:

```markdown
# Script Title

Description of what the script does.

## Usage

`zx script-name.md`
```

## Prerequisites

What the user needs before running.

---

```js
// zx code block - executed by zx
const result = await $`command`
echo(chalk.green("Done!"))
```
```

## Available Globals

When writing zx markdown scripts, these are available without imports:

- `$` - Execute shell commands
- `cd()` - Change directory
- `fetch()` - HTTP requests
- `question()` - Interactive prompts
- `echo()` - Print output
- `chalk` - Terminal colors
- `fs` - File system operations
- `path` - Path manipulation
- `glob` - File globbing
- `argv` - Command line arguments
- `stdin()` - Read from stdin

## Examples

### Basic file processor

```markdown
# File Processor

Processes files in a directory.

## Usage

`zx process-files.md ./input`

---

```js
const inputDir = argv._[0] || '.'
const files = await glob(`${inputDir}/*`)

for (const file of files) {
  echo(chalk.blue(`Processing: ${file}`))
  await $`wc -l ${file}`
}
```
```

### Interactive script

```markdown
# Project Setup

Sets up a new project interactively.

---

```js
const name = await question('Project name: ')
const type = await question('Type (node/python): ')

await $`mkdir -p ${name}`
cd(name)

if (type === 'node') {
  await $`npm init -y`
} else {
  await $`python -m venv venv`
}

echo(chalk.green(`Created ${name}`))
```
```

## Best Practices

1. **Use `echo()` not `console.log()`** - Works better with zx
2. **Prefer zx globals over Node imports** - `path`, `fs`, `chalk` are already available
3. **Use template literals with `$`** - `` await $`ls ${dir}` ``
4. **Handle errors with try/catch** - zx throws on non-zero exit codes by default
5. **Use `$.verbose = false`** to suppress command echoing
6. **Use `argv` for CLI arguments** - Access with `argv._[0]`, `argv.flag`

## Output

The skill creates a file named based on your description:
- Input: "script that backups files"
- Output: `./backup-files.md`

## Customization

After generation, you can modify:
- The documentation sections
- Add more code blocks (all `js`, `ts`, `bash` blocks execute)
- Change error handling
- Add configuration via YAML frontmatter
- Use `$({ quiet: true })` for silent command execution
