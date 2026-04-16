import { assertNever, file, init, path, template, variable } from "fig";

init(import.meta.dirname);

if (import.meta.main) {
  const sub = Deno.args[0] as "dir" | "files" | "templates";

  switch (sub) {
    case "dir": {
      await file({ path: "~/.config", state: "directory" });
      break;
    }
    case "files": {
      const files = await variable.paths("files");

      const hardlinkFiles = new Set([
        ".config/bat/config",
        ".config/redshift/redshift.conf",
        ".config/rofi/config.rasi",
        ".config/btop/btop.conf",
      ]);
      for (const src of files) {
        const encrypted = src.toString().endsWith(".encrypted");
        if (encrypted) {
          await file({
            force: true,
            path: path.home.join(src.strip(".encrypted")).toString(),
            src: path.aspect.join("files", src)
              .toString(),
            state: "encrypted",
          });
          continue;
        }

        if (hardlinkFiles.has(src.toString())) {
          await file({
            force: true,
            path: path.home.join(src).toString(),
            src: path.aspect.join("files", src).toString(),
            state: "hardlink",
          });
          continue;
        }

        await file({
          force: true,
          path: path.home.join(src).toString(),
          src: path.aspect.join("files", src).toString(),
          state: "link",
        });
      }

      break;
    }
    case "templates": {
      const templates = await variable.paths("templates");

      for (const src of templates) {
        await template({
          path: path.home.join(src.strip(".tmpl")).toString(),
          src: path.aspect.join("templates", src).toString(),
        });
      }
      break;
    }
    default:
      assertNever(sub);
  }
}
