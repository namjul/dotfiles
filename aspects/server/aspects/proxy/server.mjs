import { createServer } from 'node:http'

const handle = async (req, res) => {
  const url = new URL(req.url, 'http://localhost').searchParams.get('url')
  if (!url) {
    res.writeHead(400, { 'content-type': 'text/plain' })
    res.end('Missing url')
    return
  }
  // TODO(hardening): reject loopback, RFC1918, CGNAT/tailnet, link-local, and .local/.internal hosts.
  // TODO(hardening): abort the fetch after a timeout instead of holding the connection open.
  const upstream = await fetch(url)
  const body = await upstream.text()
  // TODO(hardening): pass through the upstream status instead of always 200.
  res.writeHead(200, {
    'content-type': upstream.headers.get('content-type') ?? 'text/plain',
    'access-control-allow-origin': '*',
  })
  res.end(body)
}

createServer((req, res) => {
  handle(req, res).catch((error) => {
    if (!res.headersSent) res.writeHead(500, { 'content-type': 'text/plain' })
    res.end(`Proxy error: ${error.message}`)
  })
}).listen(8090, '127.0.0.1')
