import { assertNever, file, init, path } from "fig";

init(import.meta.dirname);

if (import.meta.main) {
  const sub = Deno.args[0] as 'files';

  switch (sub) {

    // case "download": {
    //   console.log("Install darkman");
    //   await command('ghq', ['get', 'git@gitlab.com/WhyNotHugo/darkman.git'])
    //   break;
    // }

    // case "install": {
    //   const ghqRootResult = await command('ghq', ['root'])
    //   if (ghqRootResult.ok) {
    //     await command('make', [], { chdir: `${ghqRootResult.value.stdout.trim()}/gitlab.com/WhyNotHugo/darkman` });
    //     await command('make', ['install', 'PREFIX=~/.local/bin'], { sudo: true })
    //   }
    //   break;
    // }

    case "files": {
      const target = path.home.join(".local/share/");
      await file({
        state: 'copy',
        path: target.toString(),
        src: path.aspect.join("files", 'dark-mode.d').toString()
      })
      await file({
        state: 'copy',
        path: target.toString(),
        src: path.aspect.join("files", 'light-mode.d').toString()
      })
      break;
    }

    default:
      assertNever(sub);
  }
}
