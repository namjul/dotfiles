import { assertNever, attributes } from "fig";

type Condition = "arch" | "darwin" | "debian" | "linux";

// Top-level conditions use AND semantics; nested arrays use OR semantics.
// e.g. when(['arch', 'debian'], 'linux') means "(arch OR debian) AND linux"
export function when(
  ...conditions: Array<Array<Condition> | Condition>
): boolean {
  return conditions.every((condition) =>
    Array.isArray(condition)
      ? condition.some(checkCondition)
      : checkCondition(condition)
  );
}

export function is(
  ...conditions: Array<Array<Condition> | Condition>
): boolean {
  return when(...conditions);
}

function checkCondition(condition: Condition): boolean {
  switch (condition) {
    case "arch":
      return attributes.distribution === "arch";
    case "darwin":
      return attributes.platform === "darwin";
    case "debian":
      return attributes.distribution === "debian";
    case "linux":
      return attributes.platform === "linux";
    default:
      return assertNever(condition);
  }
}
