// Plain-text search engines — edit here; safe to version-control.
// In the address bar: type `s`, Tab (or Space), then `gh` / `gh query`.
const SEARCH_ENGINES = {
  gh: "https://github.com/search?q=",
  yt: "https://www.youtube.com/results?search_query=",
  mdn: "https://developer.mozilla.org/en-US/search?q=",
  r: "https://www.reddit.com/search/?q=",
  emt: "https://gitlab.tools.wienfluss.net/eea/emt-app/-/work_items/"
};

const DEFAULT_ENGINE = "https://duckduckgo.com/?q=";

const homeUrl = (engineBase) => new URL(engineBase).origin + "/";

const hostnameOf = (engineBase) => new URL(engineBase).hostname;

const resolveTarget = (text) => {
  const trimmed = text.trim();
  const firstSpaceIndex = trimmed.indexOf(" ");

  if (firstSpaceIndex !== -1) {
    const prefix = trimmed.slice(0, firstSpaceIndex).toLowerCase();
    const query = encodeURIComponent(trimmed.slice(firstSpaceIndex + 1));
    if (SEARCH_ENGINES[prefix]) {
      return SEARCH_ENGINES[prefix] + query;
    }
  }

  const key = trimmed.toLowerCase();
  if (SEARCH_ENGINES[key]) {
    return homeUrl(SEARCH_ENGINES[key]);
  }
  return DEFAULT_ENGINE + encodeURIComponent(trimmed);
};

const describe = (text) => {
  const trimmed = text.trim();
  const firstSpaceIndex = trimmed.indexOf(" ");

  if (firstSpaceIndex !== -1) {
    const prefix = trimmed.slice(0, firstSpaceIndex).toLowerCase();
    const query = trimmed.slice(firstSpaceIndex + 1);
    if (SEARCH_ENGINES[prefix]) {
      return `Search ${hostnameOf(SEARCH_ENGINES[prefix])} for ${query}`;
    }
  }

  const key = trimmed.toLowerCase();
  if (SEARCH_ENGINES[key]) {
    return `Open ${hostnameOf(SEARCH_ENGINES[key])}`;
  }
  if (trimmed === "") {
    return `Site search — gh, yt, mdn, r (or any query)`;
  }
  return `Search DuckDuckGo for ${trimmed}`;
};

chrome.omnibox.onInputStarted.addListener(() => {
  chrome.omnibox.setDefaultSuggestion({
    description: describe(""),
  });
});

chrome.omnibox.onInputChanged.addListener((text, suggest) => {
  chrome.omnibox.setDefaultSuggestion({
    description: describe(text),
  });

  const trimmed = text.trim().toLowerCase();
  const firstSpaceIndex = trimmed.indexOf(" ");
  const prefix = firstSpaceIndex === -1
    ? trimmed
    : trimmed.slice(0, firstSpaceIndex);

  const suggestions = Object.keys(SEARCH_ENGINES)
    .filter((key) => key.startsWith(prefix) && key !== prefix)
    .map((key) => ({
      content: key,
      description: `Open ${hostnameOf(SEARCH_ENGINES[key])} (${key})`,
    }));

  suggest(suggestions);
});

chrome.omnibox.onInputEntered.addListener((text, disposition) => {
  const targetUrl = resolveTarget(text);

  if (disposition === "newForegroundTab") {
    chrome.tabs.create({ url: targetUrl });
    return;
  }
  if (disposition === "newBackgroundTab") {
    chrome.tabs.create({ url: targetUrl, active: false });
    return;
  }
  chrome.tabs.update({ url: targetUrl });
});
