export async function stat(
  path: string,
): Promise<Deno.FileInfo | null | Error> {
  try {
    return await Deno.stat(path);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return null;
    }
    return error instanceof Error ? error : new Error(String(error));
  }
}
