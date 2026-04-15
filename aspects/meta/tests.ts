import { file, line, path, template, variable } from "fig";

type FileResult = Awaited<ReturnType<typeof file>>;
type TemplateResult = Awaited<ReturnType<typeof template>>;
type LineResult = Awaited<ReturnType<typeof line>>;

console.log("=== Fig Meta ===\n");
console.log("Platform:", variable.get("platform"));
console.log("Hostname:", variable.get("hostname"));
console.log("User:", variable.get("user"));
console.log("");

const metaDir = path.home.join(".config", "fig-meta");
const configPath = metaDir.join("meta.conf").toString();
console.log("1. Applying static files...");
const files = await variable.paths("files");
for (const src of files) {
  const result = await file({
    force: true,
    path: metaDir.join(src).toString(),
    src: path.aspect.join("files", src).toString(),
    state: "link",
  });
  assertOk(`file link ${src}`, result);
  console.log(`  ✓ ${src}`);
}

console.log("\n2. Applying hardlink...");
const hardlinkResult = await file({
  force: true,
  path: metaDir.join("state.json").toString(),
  src: path.aspect.join("files", "hard-state.json").toString(),
  state: "hardlink",
});
assertOk("hardlink state.json", hardlinkResult);
console.log("  ✓ hard-state.json (hardlink)");

console.log("\n3. Rendering templates...");
const templates = await variable.paths("templates");
for (const tmpl of templates) {
  const result = await template({
    path: metaDir.join(tmpl.strip(".tmpl")).toString(),
    src: path.aspect.join("templates", tmpl).toString(),
  });
  assertOk(`template ${tmpl}`, result);
  console.log(`  ✓ ${tmpl}`);
}

console.log("\n4. Managing line-in-file state...");
const configFileResult = await file({
  path: configPath,
  contents: "# Meta config file\n# Settings below\n",
  state: "file",
  force: true,
});
assertOk("config file write", configFileResult);

const lineResult = await line({
  path: configPath,
  line: "enabled=true",
  regexp: /^\s*#?\s*enabled\s*=/,
});
assertOk("line enabled=true", lineResult);
console.log("  ✓ Line applied");

const renderedTemplatePath = `${metaDir}/config.toml`;
const renderedTemplate = await Deno.readTextFile(renderedTemplatePath);
if (!renderedTemplate.includes("# Platform:")) {
  throw new Error(`expected platform header in ${renderedTemplatePath}`);
}

const metaConfig = await Deno.readTextFile(configPath);
if (!metaConfig.includes("enabled=true")) {
  throw new Error(`expected enabled=true in ${configPath}`);
}

console.log("\n=== Meta run complete ===");
console.log(`Check ${metaDir} for output files`);

function assertOk(name: string, result: FileResult | TemplateResult | LineResult): void {
  if ("error" in result) {
    throw new Error(`${name} failed: ${result.error.type}`);
  }
}
