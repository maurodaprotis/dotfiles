---
name: lev-legal-docs
description: "Format legal documents according to Lev's Trust Center specifications with professional typography, hierarchical numbering, and branded page elements. Use when creating contracts, terms and conditions, legal agreements, MSAs, NDAs, or any formal legal document that should match Lev's brand standards. Triggers: 'legal document', 'contract', 'terms and conditions', 'agreement', 'Lev format', 'Trust Center style', 'professional legal doc'."
---

# Lev Legal Document Formatting

Create professional legal documents matching Lev's Trust Center specifications.

## Page Format

| Property | Value | Notes |
|----------|-------|-------|
| Page size | US Letter (8.5" × 11") | 816 × 1056px at 96 DPI |
| Left margin | 1.25" (120px) | Binding offset |
| Right/Top/Bottom margins | 1" (96px) | Standard |
| Font | IBM Plex Sans, 14px | Fallback: Arial |
| Line height | 1.35 | Tight contract-style leading |
| Text alignment | Justified with auto-hyphenation | |
| First-line indent | 24px | Traditional paragraph indent |

## Section Numbering

Use decimal hierarchical numbering with outdented (hanging) section numbers:

- **Major sections**: `1.`, `2.`, `3.`
- **Subsections**: `1.1`, `1.2`, `2.1`
- **Alpha lists**: `(a)`, `(b)`, `(c)`
- **Roman lists**: `(i)`, `(ii)`, `(iii)`

## Page Elements

Each page includes:
- **Top**: 4px green accent bar (#22c55e brand color)
- **Running header**: Left: "Lev, Inc." | Right: Document title
- **Footer**: Left: Lev icon | Right: "Page X of Y"

## Creating Documents

### For HTML/React artifacts

Use the template in `references/html-template.md` for paged web view with automatic pagination.

### For DOCX files

Use docx-js with these settings:

```javascript
const { Document, Packer, Paragraph, TextRun, Header, Footer, PageNumber,
        AlignmentType, LevelFormat, ImageRun } = require('docx');

const doc = new Document({
  styles: {
    default: {
      document: {
        run: { font: "IBM Plex Sans", size: 28 } // 14pt
      }
    },
    paragraphStyles: [
      {
        id: "LegalParagraph",
        name: "Legal Paragraph",
        run: { font: "IBM Plex Sans", size: 28 },
        paragraph: {
          indent: { firstLine: 480 }, // 24px at 20 DXA/px
          spacing: { line: 276 }, // ~1.35 line height
          alignment: AlignmentType.JUSTIFIED
        }
      },
      {
        id: "Heading1",
        name: "Heading 1",
        basedOn: "Normal",
        next: "LegalParagraph",
        quickFormat: true,
        run: { size: 36, bold: true, font: "IBM Plex Sans" },
        paragraph: {
          spacing: { before: 360, after: 240 },
          outlineLevel: 0
        }
      },
      {
        id: "Heading2",
        name: "Heading 2",
        basedOn: "Normal",
        next: "LegalParagraph",
        quickFormat: true,
        run: { size: 32, bold: true, font: "IBM Plex Sans" },
        paragraph: {
          spacing: { before: 300, after: 180 },
          outlineLevel: 1
        }
      }
    ]
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 }, // US Letter
        margin: {
          top: 1440,    // 1 inch
          bottom: 1440, // 1 inch
          left: 1800,   // 1.25 inches (binding)
          right: 1440   // 1 inch
        }
      }
    },
    headers: {
      default: new Header({
        children: [/* Running header content */]
      })
    },
    footers: {
      default: new Footer({
        children: [/* Page number and Lev icon */]
      })
    },
    children: [/* Document content */]
  }]
});
```

### For PDF files

Use reportlab with equivalent settings. See `references/pdf-template.md`.

## Numbering Configuration

```javascript
numbering: {
  config: [
    {
      reference: "legal-sections",
      levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 720 } } } },
        { level: 1, format: LevelFormat.DECIMAL, text: "%1.%2", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 1080, hanging: 540 } } } }
      ]
    },
    {
      reference: "alpha-list",
      levels: [
        { level: 0, format: LevelFormat.LOWER_LETTER, text: "(%1)", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 1080, hanging: 360 } } } }
      ]
    },
    {
      reference: "roman-list",
      levels: [
        { level: 0, format: LevelFormat.LOWER_ROMAN, text: "(%1)", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 1440, hanging: 360 } } } }
      ]
    }
  ]
}
```

## Brand Colors

| Element | Color | Hex |
|---------|-------|-----|
| Accent bar | Green | #22c55e |
| Section numbers | Gray | #6b7280 |
| Body text | Dark gray | #1f2937 |
| Headers/footers | Gray | #9ca3af |

## Assets

- `assets/lev-icon.svg` — Lev brand icon for footer

## Reference Files

- `references/html-template.md` — Complete HTML/CSS for paged web view
- `references/pdf-template.md` — Python/reportlab template
- `references/docx-full-example.md` — Complete docx-js example with all features
