---
name: playwright-pdf
description: >-
  Use this skill whenever you need to export an HTML file or report to a
  pixel-perfect, properly paginated PDF. This is the correct approach when CSS
  page-break hints are unreliable, when the PDF looks cut off or badly
  formatted, or when WeasyPrint or headless Chrome produce poor results.
  Triggers include: export to PDF, generate a PDF report, PDF looks bad or cut
  off, format for 8.5x11, convert HTML to PDF, make a printable PDF, or any
  time a report or document needs to be saved as a PDF with guaranteed page
  boundaries.
---

# Playwright PDF Export

## Why This Approach

CSS `page-break` hints inside flowing HTML are unreliable — browsers decide where to break and can get it wrong, especially with flex containers and dynamically sized charts. WeasyPrint and headless Chrome (via subprocess) both have the same problem.

**The definitive fix**: redesign the HTML so each page is an explicit fixed-size container (`8.5in × 11in`). Playwright then maps each container to exactly one PDF page with no ambiguity.

---

## Step 1 — Install Playwright

```bash
pip install playwright --break-system-packages
playwright install chromium
```

---

## Step 2 — HTML Structure: Explicit Page Containers

Each page must be a **fixed-size div** — not one long scrolling document with break hints.

```html
<style>
  @page { size: 8.5in 11in; margin: 0; }

  body { margin: 0; padding: 0; background: white; }

  .pdf-page {
    width: 8.5in;
    height: 11in;
    overflow: hidden;           /* content cannot spill onto next page */
    page-break-after: always;
    display: flex;
    flex-direction: column;
  }

  .page-content {
    padding: 18px 50px 24px;
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .chart-fill {
    flex: 1;
    min-height: 0;              /* grows to fill remaining space on page */
  }
</style>

<body>
  <!-- PAGE 1 -->
  <div class="pdf-page">
    <div class="page-content">
      <!-- cover / section 01 content -->
      <div class="chart-fill">
        <!-- chart or content that should fill remaining space -->
      </div>
    </div>
  </div>

  <!-- PAGE 2 -->
  <div class="pdf-page">
    <div class="page-content">
      <!-- section 02 content -->
    </div>
  </div>

  <!-- Add more .pdf-page divs as needed -->
</body>
```

**Key rules:**
- One `.pdf-page` div = one PDF page. No exceptions.
- `overflow: hidden` on `.pdf-page` means content that doesn't fit is clipped — so size your content to fit.
- `flex: 1` on `.chart-fill` lets charts or content expand to fill leftover vertical space.
- `@page { margin: 0; }` — all spacing lives inside the page containers, not in browser margins.
- Remove any old `break-before`, `break-after`, or `break-inside` CSS rules — they are not needed and can interfere.

---

## Step 3 — Playwright Export Call

```python
from playwright.sync_api import sync_playwright

def export_pdf(html_path: str, pdf_path: str):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(f"file://{html_path}")
        page.pdf(
            path=pdf_path,
            prefer_css_page_size=True,   # honours CSS @page { size: 8.5in 11in }
            margin={                      # no extra browser margins
                "top": "0",
                "right": "0",
                "bottom": "0",
                "left": "0"
            },
            display_header_footer=False  # removes browser-generated URL/page# chrome
        )
        browser.close()

# Usage
import os
html_path = os.path.abspath("my_report.html")
export_pdf(html_path, "my_report.pdf")
```

**Why these settings matter:**
- `prefer_css_page_size=True` — Playwright uses the size declared in `@page`, not a default letter/A4.
- `margin=0` on all sides — any padding/whitespace should be defined inside your HTML `.pdf-page` containers.
- `display_header_footer=False` — suppresses the URL and page numbers Chrome prints by default. The `--print-to-pdf-no-header` CLI flag is **deprecated in Chrome 145+** and does not work; this Playwright setting is the only reliable way to suppress them.

---

## Step 4 — Sizing Content to Fit the Page

At `8.5in × 11in` with `18px 50px 24px` padding, usable content area ≈ **7.4in wide × 10.5in tall**.

If using matplotlib charts embedded as base64:
- Keep `figsize` height modest (3–5 inches for most charts).
- Use `bar_height` parameters to control chart height when you have few bars.
- Tall charts with many items may need their own full page.

If content overflows (gets clipped by `overflow: hidden`):
1. Reduce font sizes or padding.
2. Reduce chart heights.
3. Move content to its own `.pdf-page`.

---

## Common Pitfalls

| Problem | Cause | Fix |
|---|---|---|
| PDF unchanged after script reruns | Preview app caches old file | Quit Preview fully (Cmd+Q) and reopen, or right-click → Open With → Preview |
| Browser headers/footers appear (URL, page #) | Chrome default behavior | Use `display_header_footer=False` in Playwright — CLI flags don't work in Chrome 145+ |
| Content cut off mid-section | CSS page-break hints are unreliable | Use explicit `.pdf-page` containers with `overflow: hidden` |
| Charts too large / overflowing | Chart height not tuned to page | Reduce `figsize` height or `bar_height` parameters |
| WeasyPrint / headless Chrome bad output | Both have poor CSS break support | Switch to Playwright — it uses the DevTools Protocol directly |

---

## Full Minimal Example

```python
import os
from playwright.sync_api import sync_playwright

HTML = """<!DOCTYPE html>
<html>
<head>
<style>
  @page { size: 8.5in 11in; margin: 0; }
  body { margin: 0; font-family: Arial, sans-serif; }
  .pdf-page {
    width: 8.5in; height: 11in; overflow: hidden;
    page-break-after: always; display: flex; flex-direction: column;
    background: white;
  }
  .page-content { padding: 18px 50px 24px; flex: 1; display: flex; flex-direction: column; }
  h1 { font-size: 32px; margin: 0 0 16px; }
  .chart-fill { flex: 1; background: #f0f4f8; border-radius: 8px; }
</style>
</head>
<body>

<div class="pdf-page">
  <div class="page-content">
    <h1>Page One</h1>
    <p>This content is guaranteed to stay on page 1.</p>
    <div class="chart-fill"></div>
  </div>
</div>

<div class="pdf-page">
  <div class="page-content">
    <h1>Page Two</h1>
    <p>This content is guaranteed to stay on page 2.</p>
  </div>
</div>

</body>
</html>"""

# Write HTML
with open("/tmp/test_report.html", "w") as f:
    f.write(HTML)

# Export PDF
with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto(f"file:///tmp/test_report.html")
    page.pdf(
        path="/tmp/test_report.pdf",
        prefer_css_page_size=True,
        margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
        display_header_footer=False
    )
    browser.close()

print("Done:", os.path.getsize("/tmp/test_report.pdf"), "bytes")
```
