// Plain-text search engines — edit here; safe to version-control.
const SEARCH_ENGINES = {
  gh: "https://github.com/search?q=",
  yt: "https://www.youtube.com/results?search_query=",
  mdn: "https://developer.mozilla.org/en-US/search?q=",
  r: "https://www.reddit.com/search/?q=",
};

const DEFAULT_ENGINE = "https://duckduckgo.com/?q=";

const homeUrl = (engineBase) => new URL(engineBase).origin + "/";

chrome.omnibox.onInputEntered.addListener((text) => {
  const trimmed = text.trim();
  const firstSpaceIndex = trimmed.indexOf(" ");
  let targetUrl;

  if (firstSpaceIndex !== -1) {
    const prefix = trimmed.slice(0, firstSpaceIndex).toLowerCase();
    const query = encodeURIComponent(trimmed.slice(firstSpaceIndex + 1));
    if (SEARCH_ENGINES[prefix]) {
      targetUrl = SEARCH_ENGINES[prefix] + query;
    }
  }

  if (!targetUrl) {
    const key = trimmed.toLowerCase();
    if (SEARCH_ENGINES[key]) {
      targetUrl = homeUrl(SEARCH_ENGINES[key]);
    } else {
      targetUrl = DEFAULT_ENGINE + encodeURIComponent(trimmed);
    }
  }

  chrome.tabs.update({ url: targetUrl });
});
