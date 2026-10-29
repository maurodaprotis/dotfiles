# Complete DOCX Example for Lev Legal Documents

Full docx-js example with all Lev formatting specifications.

## Dependencies

```bash
npm install -g docx
```

## Complete Script

```javascript
const {
  Document, Packer, Paragraph, TextRun, Header, Footer,
  PageNumber, AlignmentType, LevelFormat, ImageRun,
  HeadingLevel, BorderStyle, Table, TableRow, TableCell,
  WidthType, ShadingType, Tab, TabStopType, TabStopPosition
} = require('docx');
const fs = require('fs');
const path = require('path');

// Lev brand colors (for reference - DOCX uses hex without #)
const COLORS = {
  accentGreen: '22c55e',
  textDark: '1f2937',
  textGray: '6b7280',
  textLight: '9ca3af',
};

// Unit conversions (1440 DXA = 1 inch)
const DXA_PER_INCH = 1440;
const DXA_PER_PT = 20;

function createLevLegalDocument(options = {}) {
  const {
    title = 'Terms and Conditions',
    content = [],
    levIconPath = null,
  } = options;

  // Load Lev icon if provided
  let levIconData = null;
  if (levIconPath && fs.existsSync(levIconPath)) {
    // Note: For SVG, convert to PNG first. docx-js supports png/jpg/gif/bmp
    // For this example, assume we have a PNG version
    try {
      levIconData = fs.readFileSync(levIconPath);
    } catch (e) {
      console.warn('Could not load Lev icon:', e.message);
    }
  }

  const doc = new Document({
    styles: {
      default: {
        document: {
          run: {
            font: 'IBM Plex Sans',
            size: 28, // 14pt (size is in half-points)
            color: COLORS.textDark,
          },
        },
      },
      paragraphStyles: [
        // Legal paragraph - justified with first-line indent
        {
          id: 'LegalParagraph',
          name: 'Legal Paragraph',
          basedOn: 'Normal',
          next: 'LegalParagraph',
          run: {
            font: 'IBM Plex Sans',
            size: 28,
            color: COLORS.textDark,
          },
          paragraph: {
            indent: { firstLine: 480 }, // 24px ≈ 480 DXA
            spacing: {
              line: 276, // ~1.35 line height (240 = single)
              after: 280, // ~14pt space after
            },
            alignment: AlignmentType.JUSTIFIED,
          },
        },
        // Section heading (1., 2., 3.)
        {
          id: 'Heading1',
          name: 'Heading 1',
          basedOn: 'Normal',
          next: 'LegalParagraph',
          quickFormat: true,
          run: {
            font: 'IBM Plex Sans',
            size: 32, // 16pt
            bold: true,
            color: COLORS.textDark,
          },
          paragraph: {
            spacing: { before: 480, after: 320 },
            outlineLevel: 0,
          },
        },
        // Subsection heading (1.1, 1.2)
        {
          id: 'Heading2',
          name: 'Heading 2',
          basedOn: 'Normal',
          next: 'LegalParagraph',
          quickFormat: true,
          run: {
            font: 'IBM Plex Sans',
            size: 28, // 14pt
            bold: true,
            color: COLORS.textDark,
          },
          paragraph: {
            spacing: { before: 320, after: 240 },
            outlineLevel: 1,
          },
        },
        // Running header style
        {
          id: 'RunningHeader',
          name: 'Running Header',
          basedOn: 'Normal',
          run: {
            font: 'IBM Plex Sans',
            size: 22, // 11pt
            color: COLORS.textLight,
          },
        },
      ],
    },
    numbering: {
      config: [
        // Main section numbering (1., 2., 3.)
        {
          reference: 'legal-sections',
          levels: [
            {
              level: 0,
              format: LevelFormat.DECIMAL,
              text: '%1.',
              alignment: AlignmentType.LEFT,
              style: {
                run: {
                  bold: true,
                  color: COLORS.textGray,
                },
                paragraph: {
                  indent: { left: 720, hanging: 720 },
                },
              },
            },
            {
              level: 1,
              format: LevelFormat.DECIMAL,
              text: '%1.%2',
              alignment: AlignmentType.LEFT,
              style: {
                run: {
                  bold: true,
                  color: COLORS.textGray,
                },
                paragraph: {
                  indent: { left: 1080, hanging: 540 },
                },
              },
            },
          ],
        },
        // Alpha list (a), (b), (c)
        {
          reference: 'alpha-list',
          levels: [
            {
              level: 0,
              format: LevelFormat.LOWER_LETTER,
              text: '(%1)',
              alignment: AlignmentType.LEFT,
              style: {
                paragraph: {
                  indent: { left: 1080, hanging: 360 },
                },
              },
            },
          ],
        },
        // Roman list (i), (ii), (iii)
        {
          reference: 'roman-list',
          levels: [
            {
              level: 0,
              format: LevelFormat.LOWER_ROMAN,
              text: '(%1)',
              alignment: AlignmentType.LEFT,
              style: {
                paragraph: {
                  indent: { left: 1440, hanging: 360 },
                },
              },
            },
          ],
        },
      ],
    },
    sections: [
      {
        properties: {
          page: {
            size: {
              width: 12240, // 8.5 inches
              height: 15840, // 11 inches
            },
            margin: {
              top: 1440, // 1 inch
              bottom: 1440, // 1 inch
              left: 1800, // 1.25 inches (binding)
              right: 1440, // 1 inch
            },
          },
        },
        headers: {
          default: new Header({
            children: [
              new Paragraph({
                style: 'RunningHeader',
                tabStops: [
                  {
                    type: TabStopType.RIGHT,
                    position: 8640, // Right-aligned at content width
                  },
                ],
                children: [
                  new TextRun('Lev, Inc.'),
                  new TextRun({
                    children: [new Tab(), title],
                  }),
                ],
              }),
            ],
          }),
        },
        footers: {
          default: new Footer({
            children: [
              new Paragraph({
                style: 'RunningHeader',
                tabStops: [
                  {
                    type: TabStopType.RIGHT,
                    position: 8640,
                  },
                ],
                children: [
                  // Lev icon would go here if PNG available
                  // new ImageRun({ type: 'png', data: levIconData, transformation: { width: 24, height: 24 } }),
                  new TextRun({
                    children: [
                      new Tab(),
                      'Page ',
                      PageNumber.CURRENT,
                    ],
                  }),
                ],
              }),
            ],
          }),
        },
        children: content,
      },
    ],
  });

  return doc;
}

// Helper functions for building content

function sectionHeading(number, titleText) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    children: [
      new TextRun({
        text: `${number}. `,
        bold: true,
        color: COLORS.textGray,
      }),
      new TextRun({
        text: titleText.toUpperCase(),
        bold: true,
      }),
    ],
  });
}

function subsectionHeading(number, titleText) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    children: [
      new TextRun({
        text: `${number} `,
        bold: true,
        color: COLORS.textGray,
      }),
      new TextRun({
        text: titleText,
        bold: true,
      }),
    ],
  });
}

function legalParagraph(text) {
  return new Paragraph({
    style: 'LegalParagraph',
    children: [new TextRun(text)],
  });
}

function definitionParagraph(term, definition) {
  return new Paragraph({
    style: 'LegalParagraph',
    children: [
      new TextRun({
        text: `"${term}" `,
        bold: true,
      }),
      new TextRun(definition),
    ],
  });
}

function alphaListItem(text) {
  return new Paragraph({
    numbering: { reference: 'alpha-list', level: 0 },
    style: 'LegalParagraph',
    children: [new TextRun(text)],
  });
}

function romanListItem(text) {
  return new Paragraph({
    numbering: { reference: 'roman-list', level: 0 },
    style: 'LegalParagraph',
    children: [new TextRun(text)],
  });
}

// Example usage
async function generateSampleDocument() {
  const content = [
    sectionHeading('1', 'Definitions'),

    definitionParagraph(
      'Agreement',
      'means these Terms and Conditions, together with any Order Forms, ' +
        'schedules, exhibits, and addenda incorporated herein by reference.'
    ),

    definitionParagraph(
      'Services',
      'means the commercial real estate technology platform and related ' +
        'services provided by Lev to Customer pursuant to this Agreement.'
    ),

    subsectionHeading('1.1', 'Additional Definitions.'),

    legalParagraph(
      'The following additional terms shall have the meanings set forth below:'
    ),

    alphaListItem(
      '"Customer Data" means all data submitted by Customer to the Services.'
    ),
    alphaListItem(
      '"Documentation" means user guides and technical materials provided by Lev.'
    ),
    alphaListItem(
      '"Effective Date" means the date this Agreement is executed by both parties.'
    ),

    sectionHeading('2', 'License and Access'),

    subsectionHeading('2.1', 'Provision of the Service.'),

    legalParagraph(
      'Subject to the terms and conditions of this Agreement, Lev hereby grants ' +
        'to Customer a non-exclusive, non-transferable right to access and use the ' +
        'Services during the Subscription Term solely for Customer\'s internal ' +
        'business purposes in accordance with this Agreement and the Documentation.'
    ),

    subsectionHeading('2.2', 'Restrictions.'),

    legalParagraph('Customer shall not, and shall not permit any third party to:'),

    alphaListItem(
      'copy, modify, or create derivative works based on the Services;'
    ),
    alphaListItem(
      'reverse engineer, disassemble, or decompile the Services;'
    ),
    alphaListItem(
      'sublicense, sell, resell, transfer, assign, or distribute the Services;'
    ),
    alphaListItem(
      'access the Services in order to build a competitive product or service.'
    ),
  ];

  const doc = createLevLegalDocument({
    title: 'Terms and Conditions',
    content,
  });

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync('sample-legal-doc.docx', buffer);
  console.log('Document created: sample-legal-doc.docx');
}

// Export for use as module
module.exports = {
  createLevLegalDocument,
  sectionHeading,
  subsectionHeading,
  legalParagraph,
  definitionParagraph,
  alphaListItem,
  romanListItem,
  COLORS,
};

// Run if executed directly
if (require.main === module) {
  generateSampleDocument().catch(console.error);
}
```

## Usage

```javascript
const {
  createLevLegalDocument,
  sectionHeading,
  subsectionHeading,
  legalParagraph,
  definitionParagraph,
  alphaListItem,
} = require('./lev-legal-docx');

const content = [
  sectionHeading('1', 'Definitions'),
  definitionParagraph('Term', 'definition text here'),
  // ... more content
];

const doc = createLevLegalDocument({
  title: 'My Legal Document',
  content,
});

// Save
const buffer = await Packer.toBuffer(doc);
fs.writeFileSync('output.docx', buffer);
```
