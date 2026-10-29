---
name: business-use-case
description: Create Lev-branded Business Use Case reports from Gong.io call transcripts using the SPICED sales framework (Situation, Pain, Impact, Critical Event, Decision). TRIGGER THIS SKILL whenever the user mentions "business use case", "BUC", "use case", or asks to analyze sales call transcripts. Common phrases include "create a business use case", "build me a BUC", "analyze this Gong call", "create a SPICED business case", "generate a use case report", or any variation of these. Outputs professionally formatted documents in Word (.docx), PDF, or Google Docs format.
---

# Business Use Case Creator

Generate Lev-branded Business Use Case reports from Gong.io call transcripts using the SPICED framework.

## Workflow

**CRITICAL - DOCUMENT FORMAT TEMPLATE**: Always use the exact format and structure demonstrated in the **Cornerstone Lending Group Business Use Case Final** as the standard template for ALL future business use cases. This document serves as the reference example. Match this format exactly, including:
- Table-based format (NOT long paragraphs or prose)
- Numbered sections (1. Executive Summary, 2. Company Overview, 3. Stakeholders, 4. SPICED Analysis, 5. Opportunity Sizing, 6. Next Steps)
- SPICED elements in separate tables with underlined subheadings (Situation, Pain, Impact, Critical Event, Decision)
- Opportunity Sizing table with three columns: Phase, Monthly Cost, Annual Cost
- Trial row showing "Free Pilot" and "$0"
- Pricing calculations: $1,000/month for first user + $250/month per additional user
- Clean, scannable layout matching the Cornerstone example exactly
- Black and white design throughout (no colors)

**Before creating any business use case, mentally reference the Cornerstone example to ensure structural consistency.**

### Step 1: Gather Inputs

Ask the user for:
1. **Call transcript** - User will paste the Gong.io transcript text
2. **Prospect company name** - Required for the document header
3. **Prospect company logo** (optional) - Ask if they'd like to upload a logo for the top-left header

The Lev logo is stored in `assets/lev-logo.png` and should always be used.

**Logo Processing**:
- If a prospect logo is provided, convert it to grayscale/black and white before adding to the document
- Both logos should appear in black and white only - no color
- Use ImageMagick to convert: `convert input.png -colorspace Gray output.png`

### Step 2: Analyze the Transcript

**CRITICAL**: Focus on the PROSPECT'S words, not the Lev salesperson's words. The prospect's perspective, pain points, and statements are what matter.

Extract and analyze:
- **Situation**: Current state, context, what they're doing now
- **Pain**: Problems, challenges, frustrations, inefficiencies
- **Impact**: Business consequences, costs, risks, missed opportunities
- **Critical Event**: Deadline, trigger, catalyst driving urgency
- **Decision**: Decision criteria, process, stakeholders, timeline

Look for:
- Direct quotes from the prospect (use these when strong/relevant)
- Specific metrics, numbers, timeframes mentioned
- Emotional language indicating pain severity
- Multiple stakeholders or decision-makers mentioned
- Competitive alternatives or current solutions discussed

### Step 3: Generate the Document

Use the `docx` skill to create a professionally formatted Word document with this exact structure:

**PAGE 1 - HEADER**:
- Top-left: Prospect company logo (if provided, converted to black and white, 150x60px max)
- Top-right: Lev logo (black and white, from assets/lev-logo.png, 150x60px max)
- Title: "Business Use Case | [PROSPECT COMPANY NAME] & Lev"
- Subtitle: Prepared by: Reid (or the account holder's name from context)
- Subtitle: Date: [Current date]

**EXECUTIVE SUMMARY**:
- 2-3 paragraph overview of the opportunity
- Synthesize the key findings across all SPICED elements
- Highlight the most compelling business case

**SITUATION**:
- Current state and context
- What they're doing today
- 2-4 paragraphs with prospect quotes where available

**PAIN**:
- Problems and challenges identified
- Use italicized, indented quotes for strong prospect statements
- 2-4 paragraphs focusing on their words

**IMPACT**:
- Business consequences and costs
- Quantify where possible
- 2-4 paragraphs with metrics when mentioned

**CRITICAL EVENT**:
- Urgency drivers and deadlines
- Why now matters
- 1-3 paragraphs

**DECISION**:
- Decision criteria and process
- Stakeholders involved
- Timeline for decision
- 2-3 paragraphs

**RECOMMENDATIONS / NEXT STEPS**:
- Suggested actions based on the analysis
- How Lev can address the identified needs
- 3-5 action items

**FOOTER** (all pages except first):
- Left: "Lev | Confidential"
- Right: Page numbers

### Step 4: Formatting Requirements

Use the following design specifications:

**Typography**:
- Font: Arial throughout
- Body text: 11pt (22 half-points in docx-js)
- Section headers: 14pt bold (28 half-points)
- Title: 18pt bold (36 half-points)
- Subtitles: 10pt (20 half-points)

**Colors**:
- Black and white throughout - NO color anywhere in the document
- All logos (Lev and prospect) must be black and white/grayscale
- Black text on white background only

**Spacing**:
- US Letter page size (8.5" x 11")
- 1" margins on all sides
- 1.5 line spacing for body text
- Double space between sections
- Clean, modern layout with ample white space

**Quotes**:
- Italicized
- Indented 0.5" from left margin
- Attribute to speaker when relevant

**Length**:
- Target 1 page, but 2-3 pages acceptable for comprehensive reports
- Do NOT sacrifice quality for brevity

### Step 5: Review and Iterate

After generating the document:

1. Present the document to the user for review
2. Ask these specific questions:
   - "Does the analysis accurately capture the prospect's key pain points?"
   - "Are there any important details from the call I should emphasize more?"
   - "Would you like me to add or remove any quotes?"
   - "Is the level of detail appropriate, or should any section be more concise?"
   - "Should I adjust the tone (more urgent, more analytical, etc.)?"

3. When making revisions:
   - **NEVER change the document structure** (section order, headers, layout)
   - ONLY modify the content within sections
   - Maintain the same formatting and style

### Step 6: Export Options

Provide the document in the requested format:
- **Word (.docx)**: Default output, already generated
- **PDF**: Convert the .docx to PDF using `soffice --headless --convert-to pdf`
- **Google Docs**: Inform user they can upload the .docx directly to Google Drive, which will auto-convert

## Important Notes

- Always prioritize prospect quotes and perspective over salesperson statements
- Use specific metrics, numbers, and timeframes when mentioned in the transcript
- Maintain professional, consultative tone throughout
- Keep the structure consistent across all reports
- Focus on business value and outcomes, not product features
