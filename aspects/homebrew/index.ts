import { assertNever, command, init, when, resource } from "fig";

init(import.meta.dirname);

if (import.meta.main) {
  if (!when(["darwin", "debian"])) {
    Deno.exit(0);
  }

  const sub = Deno.args[0] as "update" | "cleanup" | "brew"

  switch (sub) {
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
