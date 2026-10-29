---
name: customer-one-pager
description: Create customer-facing one-pager summaries from Gong.io call transcripts. This document is intended to be shared directly with the prospect/customer after discovery and demo calls. TRIGGER THIS SKILL whenever the user mentions "one-pager", "customer summary", "sales one-pager", "customer one-pager", "prospect summary", "brochure", "customer-facing summary", or similar phrases. Common triggers include "create a sales one-pager", "build a customer summary", "create a brochure with your skill", "make a one-pager for [company]", "generate a customer summary", or any variation of these. Outputs professionally formatted documents in Word (.docx), PDF, or Google Docs format.
---

# Customer One-Pager Creator

Generate customer-facing summary documents from Gong.io call transcripts. These documents are written from the customer's perspective and intended to be shared directly with the prospect after discovery/demo calls.

## Workflow

**CRITICAL - DOCUMENT POSITIONING**: This document is written FROM THE CUSTOMER'S PERSPECTIVE. The executive summary and all content should read as if the customer is articulating their own situation, needs, and the value they stand to gain. Example: "[CUSTOMER COMPANY] stands to benefit from utilizing Lev by..."

**CRITICAL - NO LEV BRANDING**: This is a customer-centric document. Do NOT include the Lev logo. Only the customer's logo should appear (if provided).

### Step 1: Gather Inputs

Ask the user for:
1. **Call transcript** - User will paste the Gong.io transcript text
2. **Customer company name** - Required for the document header and throughout
3. **Customer company logo** (optional) - Ask if they'd like to upload a logo for the header

**Logo Processing**:
- If a customer logo is provided, convert it to grayscale/black and white before adding to the document
- Use ImageMagick to convert: `convert input.png -colorspace Gray output.png`

### Step 2: Analyze the Transcript

**CRITICAL**: Focus on the CUSTOMER'S words, not the Lev salesperson's words. Extract their perspective, pain points, goals, and statements.

Extract and analyze:
- **Situation**: Current state, context, what they're doing now, their environment
- **Key Challenges**: Problems, pain points, inefficiencies, frustrations (combine Pain + Impact from SPICED)
- **Goals/Objectives**: What they want to achieve, desired outcomes
- **Decision Timeline**: Any urgency, deadlines, or catalysts mentioned
- **Success Criteria**: How they would measure success

Look for:
- Direct quotes from the customer (use these when strong/relevant)
- Specific metrics, numbers, timeframes mentioned
- Emotional language indicating pain severity
- Business impact statements
- ROI expectations or value drivers mentioned

### Step 3: Generate the Document

Use the `docx` skill to create a professionally formatted Word document with this exact structure:

**PAGE 1 - HEADER**:
- Top-left or centered: Customer company logo (if provided, converted to black and white, 180x70px max)
- NO Lev logo anywhere in the document
- Title: "[CUSTOMER COMPANY NAME] | Solution Summary"
- Subtitle: Date: [Current date]

---

**1. EXECUTIVE SUMMARY** (Written from customer perspective):
- 2-3 paragraphs written AS IF the customer is speaking
- Frame as: "[CUSTOMER COMPANY] stands to benefit from utilizing Lev by..."
- Synthesize their situation, key challenges, and the value proposition
- Highlight the most compelling business outcomes they can expect
- Keep it concise but impactful

**2. KEY CHALLENGES**:
- Table format with two columns: Challenge | Business Impact
- 3-5 rows covering their main pain points
- Include customer quotes (italicized) where applicable
- Focus on challenges Lev can address

**3. PROPOSED SOLUTION**:
- Brief description of how Lev addresses each challenge
- Written in terms of outcomes and benefits to the customer
- 2-4 short paragraphs or a concise table
- NO feature lists—focus on value delivered

**4. EXPECTED OUTCOMES / BENEFITS**:
- Table format with columns: Outcome | Expected Benefit
- 3-5 rows of quantified or qualified benefits
- Include any ROI, time savings, or efficiency gains mentioned
- Frame everything as customer benefits

**5. RECOMMENDED NEXT STEPS**:
- 3-5 action items with owners and suggested timeline
- Include trial/pilot if discussed
- Clear, actionable items

---

**FOOTER** (all pages):
- Left: "[CUSTOMER COMPANY] | Confidential"
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
- Customer logo must be black and white/grayscale
- Black text on white background only

**Spacing**:
- US Letter page size (8.5" x 11")
- 1" margins on all sides
- 1.15 line spacing for body text
- Adequate white space between sections
- Clean, modern, professional layout

**Tables**:
- Light gray borders (not heavy black)
- Header row in light gray shading
- Adequate cell padding for readability
- Full-width tables

**Quotes**:
- Italicized
- Indented 0.5" from left margin
- Attribute to speaker role when relevant (e.g., "— VP of Operations")

**Length**:
- Target 1 page when possible
- Up to 2 pages acceptable for comprehensive summaries
- Prioritize clarity and impact over brevity

### Step 5: Review and Iterate

After generating the document:

1. Present the document to the user for review
2. Ask these specific questions:
   - "Does this accurately capture the customer's key challenges and goals?"
   - "Is the executive summary appropriately framed from their perspective?"
   - "Are there any important details I should emphasize more?"
   - "Would you like me to add or adjust any quotes?"
   - "Is the tone appropriate for sharing directly with this customer?"

3. When making revisions:
   - **NEVER change the document structure** (section order, headers, layout)
   - ONLY modify the content within sections
   - Maintain the same formatting and style
   - Keep the customer-centric perspective

### Step 6: Export Options

Provide the document in the requested format:
- **Word (.docx)**: Default output, already generated
- **PDF**: Convert the .docx to PDF using `soffice --headless --convert-to pdf`
- **Google Docs**: Inform user they can upload the .docx directly to Google Drive, which will auto-convert

## Writing Style

- **Do NOT use emdashes (—) in sentences.** Use commas, periods, or restructure the sentence instead.
- Write in natural, professional prose. Avoid robotic or overly structured LLM-style language.
- Use short, clear sentences. Break up complex ideas into multiple sentences rather than using punctuation tricks.

## Important Notes

- **ALWAYS write from the customer's perspective.** This is the defining characteristic of this document.
- Prioritize customer quotes and their own words.
- Focus on business value and outcomes, not Lev product features.
- Use specific metrics and timeframes when mentioned in the transcript.
- Maintain a formal, professional, consultative tone.
- This document should feel like it was created FOR the customer, not about them.
- Keep the structure consistent across all one-pagers.
- NO Lev branding. This is the customer's document.
