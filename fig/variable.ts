import { getAspect } from "./context.ts";
import { attributes } from "./attributes.ts";
import path from "./path.ts";
import type { JSONValue, Path } from "./types.ts";
import { assert } from "./assert.ts";

interface Variable {
  (name: string, fallback?: JSONValue): JSONValue;
  all(): Record<string, unknown>;
  array(name: string, fallback?: Array<JSONValue>): Array<JSONValue>;
  path(name: string, fallback?: string): Path;
  paths(name: string, fallback?: Array<string>): Array<Path>;
  string(name: string, fallback?: string): string;
}

function variableImpl(name: string, fallback?: JSONValue): JSONValue {
  const aspectVars = getAspect().variables
  return Object.prototype.hasOwnProperty.call(aspectVars, name) ? aspectVars[name]! : fallback || null;
}

function all(): Record<string, unknown> {
  const aspectVars = getAspect().variables
  return {
    ...attributes,
    ...aspectVars,
  };
}

function string(name: string, fallback?: string): string {
  const value = variableImpl(name, fallback);

  assert(
    typeof value === 'string',
    `Expected variable ${name} to have type string but it was ${typeof value}`,
  );

  return value;
}

function array(name: string, fallback?: Array<JSONValue>): Array<JSONValue> {
  const value = variableImpl(name, fallback);
  assert(Array.isArray(value), `Expected variable ${name} to be an array`);
  return value;
}

function variablePath(name: string, fallback?: string): Path {
  return path(string(name, fallback));
}

function paths(name: string, fallback?: Array<string>): Array<Path> {
  const value = array(name, fallback);

  return value.map((v) => {
    assert(
      typeof v === 'string',
      `Expected variable ${name} to be an array of strings but it contained a ${typeof v}`,
    );
    return path(v);
  });
}

export const variable: Variable = Object.assign(variableImpl, {
  all,
  array,
  path: variablePath,
  paths,
  string,
});
