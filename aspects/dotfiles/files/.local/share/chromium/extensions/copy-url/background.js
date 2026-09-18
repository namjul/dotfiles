/** Change this: 'url' | 'markdown' | 'title-url' | 'link' */
const COPY_FORMAT = 'markdown';

const TITLE_URL_SEPARATOR = ': ';

const displayText = (title, url) => (title?.trim() ? title : url);

const escapeMarkdown = (value) =>
  value.replace(/\[/g, '\\[')
    .replace(/\]/g, '\\]')
    .replace(/\(/g, '\\(')
    .replace(/\)/g, '\\)');

const escapeHtml = (value) =>
  value.replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

const formatTab = (formatId, title, url) => {
  const text = displayText(title, url);
  switch (formatId) {
    case 'url':
      return { plain: url };
    case 'markdown':
      return { plain: `[${escapeMarkdown(text)}](${escapeMarkdown(url)})` };
    case 'title-url':
      return { plain: `${text}${TITLE_URL_SEPARATOR}${url}` };
    case 'link':
      return {
        plain: url,
        html: `<a href="${escapeHtml(url)}">${escapeHtml(text)}</a>`,
      };
    default:
      return undefined;
  }
};

/** Runs in the page — service workers have no navigator.clipboard. */
const copyInPage = (plain, html) => {
  if (html) {
    return navigator.clipboard.write([
      new ClipboardItem({
        'text/plain': new Blob([plain], { type: 'text/plain' }),
        'text/html': new Blob([html], { type: 'text/html' }),
      }),
    ]);
  }
  return navigator.clipboard.writeText(plain);
};

chrome.commands.onCommand.addListener((command) => {
  if (command !== 'copy-url') {
    return;
  }
  chrome.tabs.query({ active: true, currentWindow: true }, async (tabs) => {
    const tab = tabs[0];
    const url = tab?.url;
    const tabId = tab?.id;
    if (!url || tabId === undefined) {
      return;
    }
    const formatted = formatTab(COPY_FORMAT, tab.title, url);
    if (!formatted) {
      return;
    }
    try {
      await chrome.scripting.executeScript({
        target: { tabId },
        func: copyInPage,
        args: [formatted.plain, formatted.html ?? null],
      });
    } catch (error) {
      console.error('copy-url:', error);
    }
  });
});
