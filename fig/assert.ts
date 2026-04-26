import { type Result } from "@gordonb/result/result";

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

assert.result = <T extends Result<unknown, unknown>>(result: T) => {
  if (!result.ok) {
    return assert(result.ok, JSON.stringify(result.error))
  }
}

export function assertNever(value: never): never {
  return fail(`Expected ${value} to be unreachable`);
}
