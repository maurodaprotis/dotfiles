---
name: mutual-success-plan
description: "Generate professional Mutual Success Plan (MSP) documents for Lev customer pilots. Use when creating pilot agreements, success plans, or customer onboarding documents. Triggers: 'MSP', 'mutual success plan', 'pilot agreement', 'pilot plan', 'success plan for [customer]', 'create MSP for [customer]'. Outputs a properly formatted Word document matching Lev's legal exhibit format."
---

# Mutual Success Plan Generator

Generate professional MSP documents by editing the template in `assets/msp-template.docx`.

## Process

1. Read `references/msp-structure.md` for section structure and content guidelines
2. Gather required information from user (or use provided details)
3. Unpack the template: `python /mnt/skills/public/docx/scripts/unpack.py assets/msp-template.docx unpacked/`
4. Edit `unpacked/word/document.xml` to replace placeholder content
5. Update `unpacked/word/header1.xml` with correct order number (ORD-YYYY-XXXX)
6. Repack: `python /mnt/skills/public/docx/scripts/pack.py unpacked/ output.docx --original assets/msp-template.docx`

## Required Information

**Customer Details:**
- Company name
- Project Owner name(s) and title(s)
- Executive Sponsor name and title
- Technical Lead (if applicable)
- Pilot user names/offices

**Lev Team:**
- Account Lead name
- Account Manager name

**Pilot Structure:**
- Start date
- Pilot duration (typically 90 days)
- Pricing: Platform fee, per-user fee, total contract value
- Minimum commitment term

**Use Cases & Success Criteria:**
- 3-5 primary use cases for the pilot
- Measurable success criteria
- Key milestones and dates

## Document Format

The template uses:
- **Font**: Times New Roman 10.5pt body text
- **Numbered sections**: Arabic numerals (1, 2, 3...) for main sections
- **Sub-sections**: Lowercase letters (a), (b), (c)...
- **Bullet lists**: Filled circles for items within sections
- **Tables**: Full-width with single-line borders
- **Header**: "LEV, INC." (left) + Order number (right)
- **Footer**: "LEV" (left) + "CONFIDENTIAL" (center) + "PAGE X OF Y" (right)

## XML Editing Tips

**Replace text content:**
```xml
<!-- Find and replace text inside <w:t> tags -->
<w:t>Ackman-Ziff</w:t>  →  <w:t>New Customer Name</w:t>
```

**Smart quotes:** Use XML entities for apostrophes and quotes:
- `&#x2019;` for apostrophes (Lev's)
- `&#x201C;` and `&#x201D;` for double quotes

**Table rows:** Copy existing `<w:tr>` blocks to add rows, update content within `<w:t>` tags.

**Header order number:** Edit `unpacked/word/header1.xml`, find `ORD-2026-XXXX` and update.

## Validation

After packing, open the document in Word or LibreOffice to verify:
- All placeholder text replaced
- Tables render correctly
- Page breaks in appropriate locations
- Header/footer display correctly
