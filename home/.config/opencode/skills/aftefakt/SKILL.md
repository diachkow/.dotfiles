---
name: artefakt
description: Publish an HTML page or Markdown document to artefakt, SumUp's internal artifact server, and return a shareable preview link. Use this whenever the user wants to share, publish, host, upload, or "send a link to" a report, summary, plan, RFC draft, investigation notes, dashboard, diagram page, or any generated HTML/Markdown document with colleagues, even if they don't mention artefakt by name. Also use it when the user asks for a link they can paste into Slack, Jira, a PR, or an email for something you wrote.
---

# artefakt

artefakt stores HTML and Markdown documents and serves them at a stable URL inside the SumUp private network. HTML is served as-is. Markdown is rendered to a styled HTML page every time someone opens it.

Host: `https://artefakt.fleet.dev.eu-west-1.sumup.net`
Source: https://github.com/sumup/artefakt

The host only resolves on the SumUp network. If `curl` says `Could not resolve host`, the user is off VPN. Tell them so instead of retrying.

Anyone on the SumUp network can open an artifact link, and artifacts can't be edited or deleted. Don't upload secrets, credentials, customer data, or personal data. To change a document, upload it again and share the new link.

## Upload API

`POST /artifacts` with a `multipart/form-data` body:

- `file`: exactly one file, required. 10 MiB max.
- `title`: optional, up to 256 bytes. Non-ASCII characters take several bytes each. For Markdown, it becomes the browser tab title. HTML is served unchanged, so the page's own `<title>` sets the tab title, not this field.

A successful upload returns `201 Created`:

```json
{"id":"SB7AQFGGT3HTTW3FIXOMPSEN3N","title":"Weekly report","content_hash":"sha256:6ca1..."}
```

Use `id` to build the link. `content_hash` is the SHA-256 of the bytes you sent, and you can usually ignore it.

Pass `title` with `--form-string`, not `-F`. With `-F`, curl treats a value starting with `@` or `<` as a file to read, and `;` as a separator.

`--fail-with-body` makes curl exit non-zero on HTTP errors and still print the server's error message.

## Post an HTML artifact

```bash
curl --fail-with-body -sS https://artefakt.fleet.dev.eu-west-1.sumup.net/artifacts \
  -F 'file=@report.html' \
  --form-string 'title=Checkout latency investigation'
```

Set a `<title>` in the page's `<head>` so the browser tab has a name.

The server stores only this one file. A relative `<link href="style.css">` or `<img src="chart.png">` won't load. Make the page self-contained:

- Put CSS in a `<style>` tag and JavaScript in a `<script>` tag.
- Embed small images as `data:` URIs, or link to absolute `https://` URLs.
- CDN scripts and stylesheets work if the viewer's browser can reach them.

Scripts run in the viewer's browser, so the page can be interactive.

Any file that isn't detected as Markdown is stored and served as HTML. Don't upload `.txt`, `.json`, or `.csv` directly. Wrap them in an HTML page or a Markdown code block first.

## Post a Markdown artifact

```bash
curl --fail-with-body -sS https://artefakt.fleet.dev.eu-west-1.sumup.net/artifacts \
  -F 'file=@report.md' \
  --form-string 'title=Q3 incident review'
```

The server treats an upload as Markdown when the filename ends in `.md` or `.markdown`, or when the file part has type `text/markdown`. For a file with another extension, set the type explicitly:

```bash
curl --fail-with-body -sS https://artefakt.fleet.dev.eu-west-1.sumup.net/artifacts \
  -F 'file=@notes.txt;type=text/markdown'
```

Things to know about the renderer:

- It supports GitHub-flavored Markdown: tables, task lists, strikethrough, autolinks, and fenced code blocks.
- Raw HTML inside Markdown is dropped. Upload an HTML artifact if you need custom markup.
- The title doesn't add a heading. Start the document with its own `# Heading`.
- Images need absolute URLs, for the same reason as in HTML.
- The file must be valid UTF-8.

The preview uses SumUp Circuit UI styling with light and dark themes. You don't need to add any styling.

## Upload generated content without a file

You can pipe content you generated straight into curl. Pass `filename=` so the server can detect the type:

```bash
printf '%s\n' "$markdown" | curl --fail-with-body -sS \
  https://artefakt.fleet.dev.eu-west-1.sumup.net/artifacts \
  -F 'file=@-;filename=summary.md' \
  --form-string 'title=Sprint summary'
```

Writing to a temporary file first works too, and is easier to debug.

## Compose the preview link

The link format is:

```
https://artefakt.fleet.dev.eu-west-1.sumup.net/a/<id>
```

Upload and print the link in one step:

```bash
if response=$(curl --fail-with-body -sS https://artefakt.fleet.dev.eu-west-1.sumup.net/artifacts \
  -F 'file=@report.md' \
  --form-string 'title=Q3 incident review'); then
  echo "https://artefakt.fleet.dev.eu-west-1.sumup.net/a/$(jq -r .id <<<"$response")"
else
  echo "upload failed: $response" >&2
fi
```

The `if` stops a failed upload from turning into a broken link like `.../a/null`. If `jq` isn't installed, read `id` from the JSON response yourself.

The same link works for HTML and Markdown. Open it once with `curl -sS -o /dev/null -w '%{http_code}\n' <link>` and expect `200` before handing it over.

Give the user the full link on its own line so it's easy to copy. Mention the title if you set one.

## Errors

| Status | Meaning | What to do |
|---|---|---|
| 400 `multipart form must contain exactly one "file"` | Missing `file` field, or more than one file | Send one `-F 'file=@...'` |
| 400 `Markdown must be UTF-8` | Markdown file has another encoding | Convert with `iconv -f <source-encoding> -t UTF-8` |
| 400 `"title" should be no longer than 256 characters` | Title over 256 bytes | Shorten it |
| 413 | File over 10 MiB | Shrink it. Large inline images are the usual cause |
| 404 on `/a/<id>` | Wrong or truncated id | Check the id from the upload response |
| 502 | Storage problem on the server | Retry once, then tell the user |
