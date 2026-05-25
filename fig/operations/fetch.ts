import * as path from "@std/path";
import { Readable } from "node:stream";
import { finished } from "node:stream/promises";
import { createWriteStream } from "node:fs";

import { Result } from "@gordonb/result";
import { type Result as ResultType } from "@gordonb/result/result";
import { type Option } from "@gordonb/result/option";
import { fetch as zxFetch } from "zx";
import { file } from "./file.ts";

export type FetchError =
  | { type: "FETCH_FAILED"; url: string; dest: string; cause: unknown }
  | { type: "DOWNLOAD_FAILED"; url: string; cause: unknown };
export type FetchResult = ResultType<undefined, FetchError>;

export async function fetch({
  dest,
  encoding,
  force,
  mode,
  url,
}: {
  dest: string;
  encoding?: null;
  force?: boolean;
  url: string;
  mode?: Option<string>;
}): Promise<FetchResult> {
  console.debug(`Download \`${url}\` to \`${dest}\``);

  const dir = await Deno.makeTempDir();
  const download = path.join(dir, "download");

  const responseResult = await Result.performAsync(() => zxFetch(url));

  if (Result.isOk(responseResult)) {
    // @ts-ignore Argument of type 'Writable
    const body = Readable.fromWeb(responseResult.value.body!);
    const stream = createWriteStream(download);
    await finished(body.pipe(stream));

    const raw = await Deno.readFile(download);
    const contents = encoding === null ? raw : new TextDecoder("utf-8").decode(raw);

    const result = await file({
      contents,
      force,
      mode,
      path: dest,
      state: "file",
    });

    if (Result.isOk(result)) {
      return Result.ok(undefined);
    }
    return Result.err({
      type: "DOWNLOAD_FAILED",
      url,
      dest,
      cause: result.error,
    });
  }

  return Result.err({
    type: "FETCH_FAILED",
    url,
    dest,
    cause: responseResult.error,
  });
}
