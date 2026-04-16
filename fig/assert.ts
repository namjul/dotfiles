export function fail(message: string | Error): never {
  const error = typeof message === "string" ? new Error(message) : message;
  Error.captureStackTrace?.(error, fail);
  throw error;
}

export function assert(
  condition: any,
  message: string = "Condition not met",
): asserts condition {
  if (!condition) {
    debugger;
    fail(message);
  }
}

export function assertNever(value: never): never {
  return fail(`Expected ${value} to be unreachable`);
}
