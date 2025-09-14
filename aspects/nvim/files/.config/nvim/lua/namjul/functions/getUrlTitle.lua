-- Inpsirted by https://benjamincongdon.me/blog/2020/06/27/Vim-Tip-Paste-Markdown-Link-with-Automatic-Title-Fetching/

local function getUrlTitle(input)
  -- match url pattern
  if input:match('^https?://') then
    -- Get link's page title.
    local handle = io.popen('wget -q -O - "' .. input .. '" | get-title')
    if handle then
      local title = handle:read('*a')
      handle:close()

      -- Strip trailing newline
      return title:gsub('\n', '')
    end
  end

  return nil
end

return getUrlTitle
