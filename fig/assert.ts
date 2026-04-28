import { type Result } from "@gordonb/result/result";

export function fail(message: string | Error): never {
  const error = typeof message === "string" ? new Error(message) : message;
  Error.captureStackTrace?.(error, fail);
  throw error;
}

interface Assert {
  (condition: any, message?: string): asserts condition;
  result<T extends Result<unknown, unknown>>(result: T): void;
}

function assertImpl(
  condition: any,
  message: string = "Condition not met",
): asserts condition {
  if (!condition) {
    debugger;
    fail(message);
  }
}

export const assert: Assert = Object.assign(assertImpl, {
  result<T extends Result<unknown, unknown>>(result: T): void {
    if (!result.ok) {
      assertImpl(result.ok, JSON.stringify(result.error));
    }
  },
});

export function assertNever(value: never): never {
  return fail(`Expected ${value} to be unreachable`);
}
