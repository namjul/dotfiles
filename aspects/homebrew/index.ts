import { assertNever, fail, init, command, resource, path } from "fig";
import { question } from "zx";

init(import.meta.dirname);

if (import.meta.main) {
  const sub = Deno.args[0] as "install" | "update" | "cleanup" | "brew"

  switch (sub) {
    case "install": {
      console.log("Install $brew https://brew.sh/")
      const answer = await question("Confirm that Homebrew is installed(y|n)", {
        choices: ["y", "n"],
      });
      if (answer !== 'y') {
        fail("User aborted");
      }
      break;
    }

    case "update": {
      await command('brew', ['update']);
      break;
    }

    case "brew": {
      const src = resource.file('Brewfile');
      await command('brew', ['bundle', `--file=${src.toString()}`]);
      break;
    }

    case "cleanup": {
      await command('brew', ['cleanup']);
      break;
    }

    default:
      assertNever(sub);
  }
}
