/** Serialize dialogs sharing Pi's single editor slot, across module caches. */
const queuesKey = Symbol.for('wincent-agent-plugins.dialog-queues');
const state = globalThis as typeof globalThis & {
  [queuesKey]?: WeakMap<object, Promise<void>>;
};
const queues = state[queuesKey] ??= new WeakMap<object, Promise<void>>();

/**
 * Cancellation resolves the caller immediately, but an active dialog retains
 * its slot until it settles. The callback must forward signal to the UI so
 * cancellation dismisses it before the next dialog starts.
 */
export function queueDialog<T>(
  ui: object,
  prompt: () => Promise<T>,
  signal?: AbortSignal,
): Promise<T | undefined> {
  if (signal?.aborted) {
    return Promise.resolve(undefined);
  }
  const result = (queues.get(ui) ?? Promise.resolve()).then(async () => {
    if (signal?.aborted) {
      return undefined;
    }
    const value = await prompt();
    return signal?.aborted ? undefined : value;
  });
  const tail = result.then(() => {}, () => {});
  queues.set(ui, tail);
  void tail.then(() => {
    if (queues.get(ui) === tail) {
      queues.delete(ui);
    }
  });
  if (!signal) {
    return result;
  }
  return new Promise((resolve, reject) => {
    const onAbort = () => resolve(undefined);
    signal.addEventListener('abort', onAbort, {once: true});
    result.then(
      (value) => {
        signal.removeEventListener('abort', onAbort);
        resolve(signal.aborted ? undefined : value);
      },
      (error) => {
        signal.removeEventListener('abort', onAbort);
        reject(error);
      },
    );
  });
}
