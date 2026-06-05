Deno.serve(async (req) => {
  const url = new URL(req.url).searchParams.get('url')
  if (!url) return new Response('Missing url', { status: 400 })
  const res = await fetch(url)
  const body = await res.text()
  return new Response(body, {
    headers: {
      'content-type': res.headers.get('content-type') ?? 'text/plain',
      'access-control-allow-origin': '*',
    },
  })
})
