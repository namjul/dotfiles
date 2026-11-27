/**
 * Web Search Extension
 *
 * Registers a `web_search` tool backed by the Kagi Search API
 * (https://help.kagi.com/kagi/api/search.html), billed at $12 per 1,000
 * queries.
 *
 * Requires `KAGI_API_TOKEN` in the environment. Kagi v1 authenticates with
 * `Authorization: Bearer`.
 *
 * Response validation and salvage adapted from wincent's Kagi extension:
 * https://github.com/wincent/wincent/blob/e104d2efaf1bbf061d91cd2549d0a9efc390aa68/aspects/dotfiles/files/.pi/agent/extensions/web-search.ts
 */

import {
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  type ExtensionAPI,
  type ExtensionContext,
  formatSize,
  truncateHead,
} from '@earendil-works/pi-coding-agent';
import {type Static, Type} from 'typebox';
import {Check, Errors} from 'typebox/value';

const SEARCH_URL = 'https://kagi.com/api/v1/search';
const DEFAULT_TIMEOUT_MS = 20_000;

/**
 * Kagi sends an explicit `null` for fields it has no value for, most often
 * `snippet`, rather than omitting the key.
 */
const NullableString = Type.Union([Type.String(), Type.Null()]);

const SearchResult = Type.Object({
  url: Type.Optional(NullableString),
  title: Type.Optional(NullableString),
  snippet: Type.Optional(NullableString),
  time: Type.Optional(NullableString),
  props: Type.Optional(Type.Unknown()),
});
type SearchResult = Static<typeof SearchResult>;

const SearchResponse = Type.Object({
  meta: Type.Object({
    trace: Type.String(),
    node: Type.String(),
    ms: Type.Number(),
  }),
  data: Type.Union([
    Type.Record(Type.String(), Type.Array(SearchResult)),
    Type.Null(),
  ]),
  errors: Type.Optional(
    Type.Array(
      Type.Object({
        code: Type.String(),
        message: Type.String(),
        url: Type.Optional(Type.String()),
      })
    )
  ),
});

const Parameters = Type.Object({
  query: Type.String({description: 'Search query'}),
});

/** Sections rendered as one-line links, in the order we prefer to show them. */
const SECTION_ORDER = ['search', 'video', 'interesting_finds', 'related_search'];

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null;

const describeIssues = (raw: unknown): string =>
  Errors(SearchResponse, raw)
    .slice(0, 3)
    .map((error) => `${error.instancePath || '/'}: ${error.message}`)
    .join('; ');

const apiErrors = (raw: unknown): string[] => {
  const errors = isRecord(raw) ? raw['errors'] : undefined;
  if (!Array.isArray(errors)) return [];
  return errors.map((error) => {
    if (!isRecord(error)) return JSON.stringify(error);
    const message = typeof error['message'] === 'string' ? error['message'] : undefined;
    const code = typeof error['code'] === 'string' ? error['code'] : undefined;
    if (message && code) return `${message} (${code})`;
    return message ?? code ?? JSON.stringify(error);
  });
};

/**
 * Keep whatever individual results still validate when the response as a whole
 * does not, so one unrecognized field cannot discard a paid query.
 */
const salvage = (raw: unknown): Record<string, SearchResult[]> => {
  const data = isRecord(raw) ? raw['data'] : undefined;
  if (!isRecord(data)) return {};
  const sections: Record<string, SearchResult[]> = {};
  for (const [name, items] of Object.entries(data)) {
    if (!Array.isArray(items)) continue;
    const valid = items.filter((item): item is SearchResult => Check(SearchResult, item));
    if (valid.length > 0) sections[name] = valid;
  }
  return sections;
};

const sectionLabel = (name: string): string => {
  const words = name.replace(/_/g, ' ');
  return words.charAt(0).toUpperCase() + words.slice(1);
};

const formatResult = (result: SearchResult): string => {
  const lines = [`## ${result.title ?? '(no title)'}`];
  if (result.url) lines.push(result.url);
  if (result.snippet) lines.push(result.snippet);
  if (result.time) lines.push(`Time: ${result.time}`);
  return lines.join('\n');
};

const formatSections = (sections: Record<string, SearchResult[]>): string => {
  const names = Object.keys(sections).sort(
    (a, b) =>
      (SECTION_ORDER.indexOf(a) === -1 ? SECTION_ORDER.length : SECTION_ORDER.indexOf(a)) -
      (SECTION_ORDER.indexOf(b) === -1 ? SECTION_ORDER.length : SECTION_ORDER.indexOf(b))
  );

  const parts: string[] = [];
  for (const name of names) {
    const items = sections[name];
    if (!items || items.length === 0) continue;

    if (name === 'search') {
      for (const item of items) {
        if (item.url) parts.push(formatResult(item));
      }
      continue;
    }

    if (name === 'related_search') {
      // Relative to kagi.com, so the URL is not worth following.
      const queries = items
        .map((item) => item.title)
        .filter((title): title is string => Boolean(title));
      if (queries.length > 0) parts.push(`## Related searches\n${queries.join(', ')}`);
      continue;
    }

    const lines = items
      .filter((item) => item.url || item.title)
      .map((item) =>
        item.url ? `- ${item.title ?? '(no title)'}: ${item.url}` : `- ${item.title}`
      );
    if (lines.length > 0) parts.push(`## ${sectionLabel(name)}\n${lines.join('\n')}`);
  }
  return parts.join('\n\n');
};

const withTimeout = (signal: AbortSignal | undefined, milliseconds: number): AbortSignal => {
  const timeout = AbortSignal.timeout(milliseconds);
  return signal ? AbortSignal.any([signal, timeout]) : timeout;
};

interface SearchDetails {
  provider: 'kagi';
  query: string;
  resultCount: number;
  sections: string[];
  issues: string | undefined;
  truncated: boolean;
}

const search = async (
  query: string,
  token: string,
  context: ExtensionContext,
  signal?: AbortSignal
): Promise<{content: Array<{type: 'text'; text: string}>; details: SearchDetails}> => {
  const response = await fetch(SEARCH_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({query}),
    signal: withTimeout(signal, DEFAULT_TIMEOUT_MS),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    let parsed: unknown;
    try {
      parsed = JSON.parse(body);
    } catch {
      parsed = undefined;
    }
    const errors = apiErrors(parsed);
    throw new Error(
      `Kagi search failed (${response.status}): ` +
        (errors.length > 0 ? errors.join('; ') : body || response.statusText)
    );
  }

  const raw: unknown = await response.json();

  const errors = apiErrors(raw);
  if (errors.length > 0) throw new Error(`Kagi search failed: ${errors.join('; ')}`);

  const valid = Check(SearchResponse, raw);
  const issues = valid ? undefined : describeIssues(raw);
  const sections = valid ? ((raw as Static<typeof SearchResponse>).data ?? {}) : salvage(raw);
  const total = Object.values(sections).reduce((sum, items) => sum + items.length, 0);

  // A bad shape alone is only a warning; give up only when nothing survived.
  if (issues !== undefined && total === 0) {
    throw new Error(`Kagi returned an unexpected response shape: ${issues}`);
  }

  const formatted = formatSections(sections) || 'No results found.';
  const text = issues === undefined
    ? formatted
    : `${formatted}\n\n(Note: part of the Kagi response could not be parsed ` +
      `(${issues}); some results may be missing.)`;

  const truncated = truncateHead(text);
  const output = truncated.truncated
    ? `${truncated.content}\n\n[Output truncated at ${formatSize(DEFAULT_MAX_BYTES)} ` +
      `or ${DEFAULT_MAX_LINES} lines: showing ${truncated.outputLines} of ` +
      `${truncated.totalLines} lines.]`
    : truncated.content;

  if (context.hasUI) {
    if (valid) {
      const meta = (raw as Static<typeof SearchResponse>).meta;
      context.ui.notify(`Kagi: ${meta.ms} ms`, 'info');
    } else {
      context.ui.notify(`Kagi: unexpected response shape (${issues})`, 'warning');
    }
  }

  return {
    content: [{type: 'text' as const, text: output}],
    details: {
      provider: 'kagi',
      query,
      resultCount: sections['search']?.length ?? 0,
      sections: Object.keys(sections),
      issues,
      truncated: truncated.truncated,
    } satisfies SearchDetails,
  };
};

export default function webSearchExtension(pi: ExtensionAPI): void {
  pi.registerTool({
    name: 'web_search',
    label: 'Web Search',
    description: 'Search the web. Returns results with titles, URLs, and snippets.',
    promptSnippet: 'Search the web for current information',
    promptGuidelines: [
      'Prefer what is already on disk — the installed package\'s docs and examples, the repo, an llms.txt — before searching. Search when the answer depends on what changed after training or on something the repo cannot answer.',
      'A snippet may answer a factual question. Open the page before quoting or recommending it.',
      'Query with words that would appear on the target page, not a description of the question.',
      'Report findings with their URLs rather than pasting raw output.',
    ],
    parameters: Parameters,

    async execute(_toolCallId, params, signal, _onUpdate, context) {
      const token = process.env['KAGI_API_TOKEN'];
      if (!token) {
        throw new Error('web_search requires `KAGI_API_TOKEN` in the environment.');
      }

      return await search(params.query, token, context, signal);
    },
  });
}
