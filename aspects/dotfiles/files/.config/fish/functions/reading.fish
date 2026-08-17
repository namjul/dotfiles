function reading --description 'Fetch a URL and save a 1:1 reading note in memex via pi'
  if test (count $argv) -lt 1
    echo "Usage: reading <url> [pi args...]" >&2
    return 1
  end

  set -l url $argv[1]
  set -l pi_args $argv[2..-1]
  set -l memex "$DROPBOX_DIR/memex"

  if not test -d $memex
    echo "Memex not found: $memex" >&2
    return 1
  end

  cd $memex; or return 1

  command pi -p -a --no-session $pi_args \
    "/skill:browser-tools save this URL as a memex reading note. Match person.*.*.md format. Resolve author from existing memex notes first — they may live as person.<slug>, <slug>, or wikilinks elsewhere; use that slug, not a new person.*.md.

Body: article 1:1 from the link. Prefix fields: title, author, date, source (add status: unread only for reading.* fallback). Path: person.<author-slug>.<article-slug>.md when author is known; else reading.<article-slug>.md. Search memex for related notes, wikilink matches inline, end with ## Lookup (source URL, existing author note or stub, related backlinks).

$url"
end
