/**
 * Global context for the current aspect
 */

let currentAspectDir: string | null = null;

/**
 * Initialize the Fig context with the current aspect directory.
 * Must be called once at the start of each aspect.
 */
export function init(aspectDir: string | undefined): void {
  if (aspectDir === undefined) {
    throw new Error(
      "Fig context not initialized. Call init(import.meta.dirname) at the start of your aspect."
    );
  }
  currentAspectDir = aspectDir;
}

/**
 * Get the current aspect directory.
 * Throws if init() has not been called.
 */
export function getAspectDir(): string {
  if (!currentAspectDir) {
    throw new Error(
      "Fig context not initialized. Call init(import.meta.dirname) at the start of your aspect."
    );
  }
  return currentAspectDir;
}

/**
 * Check if context has been initialized
 */
export function isInitialized(): boolean {
  return currentAspectDir !== null;
}
