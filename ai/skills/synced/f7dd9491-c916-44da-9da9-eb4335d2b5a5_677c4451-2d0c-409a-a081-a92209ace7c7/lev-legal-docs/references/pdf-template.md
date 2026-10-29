# PDF Template for Lev Legal Documents

Python/reportlab template for generating legal PDFs matching Lev specifications.

## Dependencies

```bash
pip install reportlab svglib --break-system-packages
```

## Complete Template

```python
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_JUSTIFY, TA_LEFT, TA_RIGHT
from reportlab.lib.colors import HexColor
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak,
    Table, TableStyle, ListFlowable, ListItem
)
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF
import os

# Brand colors
ACCENT_GREEN = HexColor('#22c55e')
TEXT_DARK = HexColor('#1f2937')
TEXT_GRAY = HexColor('#6b7280')
TEXT_LIGHT = HexColor('#9ca3af')

# Page dimensions
PAGE_WIDTH, PAGE_HEIGHT = letter  # 8.5" x 11"
MARGIN_TOP = 1 * inch
MARGIN_BOTTOM = 1 * inch
MARGIN_LEFT = 1.25 * inch  # Binding offset
MARGIN_RIGHT = 1 * inch

# Try to register IBM Plex Sans, fallback to Helvetica
FONT_FAMILY = 'Helvetica'
try:
    pdfmetrics.registerFont(TTFont('IBMPlexSans', 'IBMPlexSans-Regular.ttf'))
    pdfmetrics.registerFont(TTFont('IBMPlexSans-Bold', 'IBMPlexSans-Bold.ttf'))
    FONT_FAMILY = 'IBMPlexSans'
except:
    pass


def create_styles():
    """Create paragraph styles matching Lev specifications."""
    styles = {}
    
    # Body paragraph - justified with first-line indent
    styles['LegalParagraph'] = ParagraphStyle(
        'LegalParagraph',
        fontName=FONT_FAMILY,
        fontSize=14,
        leading=14 * 1.35,  # 1.35 line height
        alignment=TA_JUSTIFY,
        firstLineIndent=24,
        textColor=TEXT_DARK,
        spaceAfter=14,
    )
    
    # Section heading (1., 2., 3.)
    styles['SectionHeading'] = ParagraphStyle(
        'SectionHeading',
        fontName=f'{FONT_FAMILY}-Bold' if FONT_FAMILY == 'IBMPlexSans' else 'Helvetica-Bold',
        fontSize=16,
        leading=20,
        alignment=TA_LEFT,
        textColor=TEXT_DARK,
        spaceBefore=24,
        spaceAfter=16,
        leftIndent=-48,  # Outdent for hanging number
    )
    
    # Subsection heading (1.1, 1.2)
    styles['SubsectionHeading'] = ParagraphStyle(
        'SubsectionHeading',
        fontName=f'{FONT_FAMILY}-Bold' if FONT_FAMILY == 'IBMPlexSans' else 'Helvetica-Bold',
        fontSize=14,
        leading=18,
        alignment=TA_LEFT,
        textColor=TEXT_DARK,
        spaceBefore=16,
        spaceAfter=12,
        leftIndent=-36,
    )
    
    # Definition term (bold inline)
    styles['DefinitionTerm'] = ParagraphStyle(
        'DefinitionTerm',
        fontName=f'{FONT_FAMILY}-Bold' if FONT_FAMILY == 'IBMPlexSans' else 'Helvetica-Bold',
        fontSize=14,
        leading=14 * 1.35,
        textColor=TEXT_DARK,
    )
    
    # Running header
    styles['RunningHeader'] = ParagraphStyle(
        'RunningHeader',
        fontName=FONT_FAMILY,
        fontSize=11,
        textColor=TEXT_LIGHT,
    )
    
    # Page number
    styles['PageNumber'] = ParagraphStyle(
        'PageNumber',
        fontName=FONT_FAMILY,
        fontSize=11,
        textColor=TEXT_LIGHT,
        alignment=TA_RIGHT,
    )
    
    return styles


class LevLegalDocTemplate(SimpleDocTemplate):
    """Custom document template with Lev branding."""
    
    def __init__(self, filename, header_left="Lev, Inc.", header_right="Document Title",
                 lev_icon_path=None, **kwargs):
        self.header_left = header_left
        self.header_right = header_right
        self.lev_icon_path = lev_icon_path
        
        super().__init__(
            filename,
            pagesize=letter,
            topMargin=MARGIN_TOP,
            bottomMargin=MARGIN_BOTTOM,
            leftMargin=MARGIN_LEFT,
            rightMargin=MARGIN_RIGHT,
            **kwargs
        )
    
    def afterDrawPage(self, canvas, doc):
        """Draw page elements after content."""
        canvas.saveState()
        
        # Green accent bar at top
        canvas.setFillColor(ACCENT_GREEN)
        canvas.rect(0, PAGE_HEIGHT - 4, PAGE_WIDTH, 4, fill=True, stroke=False)
        
        # Running header
        canvas.setFont(FONT_FAMILY, 11)
        canvas.setFillColor(TEXT_LIGHT)
        
        # Left header
        canvas.drawString(MARGIN_LEFT, PAGE_HEIGHT - 48, self.header_left)
        
        # Right header
        header_width = canvas.stringWidth(self.header_right, FONT_FAMILY, 11)
        canvas.drawString(PAGE_WIDTH - MARGIN_RIGHT - header_width, PAGE_HEIGHT - 48, self.header_right)
        
        # Footer
        # Page number on right
        page_num = f"Page {doc.page}"
        page_num_width = canvas.stringWidth(page_num, FONT_FAMILY, 11)
        canvas.drawString(PAGE_WIDTH - MARGIN_RIGHT - page_num_width, 48, page_num)
        
        # Lev icon on left (if provided)
        if self.lev_icon_path and os.path.exists(self.lev_icon_path):
            try:
                drawing = svg2rlg(self.lev_icon_path)
                if drawing:
                    # Scale to 24x24
                    scale = 24 / max(drawing.width, drawing.height)
                    drawing.width *= scale
                    drawing.height *= scale
                    drawing.scale(scale, scale)
                    renderPDF.draw(drawing, canvas, MARGIN_LEFT, 40)
            except Exception:
                pass
        
        canvas.restoreState()


def create_legal_document(filename, content, header_right="Terms and Conditions",
                         lev_icon_path=None):
    """
    Create a legal document with Lev formatting.
    
    Args:
        filename: Output PDF path
        content: List of flowables (Paragraph, Spacer, etc.)
        header_right: Document title for running header
        lev_icon_path: Path to lev-icon.svg
    """
    doc = LevLegalDocTemplate(
        filename,
        header_left="Lev, Inc.",
        header_right=header_right,
        lev_icon_path=lev_icon_path,
    )
    
    doc.build(content)
    return filename


# Helper functions for building content

def section_heading(number, title, styles):
    """Create a section heading with outdented number."""
    return Paragraph(
        f'<b><font color="{TEXT_GRAY.hexval()}">{number}.</font></b>&nbsp;&nbsp;&nbsp;'
        f'<b>{title}</b>',
        styles['SectionHeading']
    )


def subsection_heading(number, title, styles):
    """Create a subsection heading."""
    return Paragraph(
        f'<b><font color="{TEXT_GRAY.hexval()}">{number}</font></b>&nbsp;&nbsp;'
        f'<b>{title}</b>',
        styles['SubsectionHeading']
    )


def legal_paragraph(text, styles):
    """Create a justified paragraph with first-line indent."""
    return Paragraph(text, styles['LegalParagraph'])


def definition_paragraph(term, definition, styles):
    """Create a paragraph with bold definition term."""
    return Paragraph(
        f'<b>"{term}"</b> {definition}',
        styles['LegalParagraph']
    )


def alpha_list(items, styles):
    """Create an (a), (b), (c) list."""
    return ListFlowable(
        [ListItem(Paragraph(item, styles['LegalParagraph']), leftIndent=36)
         for item in items],
        bulletType='a',
        bulletFormat='(%s)',
        start=1,
    )


def roman_list(items, styles):
    """Create an (i), (ii), (iii) list."""
    return ListFlowable(
        [ListItem(Paragraph(item, styles['LegalParagraph']), leftIndent=36)
         for item in items],
        bulletType='i',
        bulletFormat='(%s)',
        start=1,
    )


# Example usage
if __name__ == '__main__':
    styles = create_styles()
    
    content = [
        section_heading('1', 'DEFINITIONS', styles),
        
        definition_paragraph(
            'Agreement',
            'means these Terms and Conditions, together with any Order Forms, '
            'schedules, exhibits, and addenda incorporated herein by reference.',
            styles
        ),
        
        definition_paragraph(
            'Services',
            'means the commercial real estate technology platform and related '
            'services provided by Lev to Customer pursuant to this Agreement.',
            styles
        ),
        
        subsection_heading('1.1', 'Additional Definitions.', styles),
        
        legal_paragraph(
            'The following additional terms shall have the meanings set forth below:',
            styles
        ),
        
        alpha_list([
            '"Customer Data" means all data submitted by Customer to the Services.',
            '"Documentation" means user guides and technical materials provided by Lev.',
            '"Effective Date" means the date this Agreement is executed by both parties.',
        ], styles),
        
        section_heading('2', 'LICENSE AND ACCESS', styles),
        
        subsection_heading('2.1', 'Provision of the Service.', styles),
        
        legal_paragraph(
            'Subject to the terms and conditions of this Agreement, Lev hereby grants '
            'to Customer a non-exclusive, non-transferable right to access and use the '
            'Services during the Subscription Term solely for Customer\'s internal '
            'business purposes in accordance with this Agreement and the Documentation.',
            styles
        ),
    ]
    
    create_legal_document(
        'sample-legal-doc.pdf',
        content,
        header_right='Terms and Conditions',
        lev_icon_path='lev-icon.svg'
    )
```
