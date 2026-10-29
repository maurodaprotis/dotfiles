# HTML/CSS Template for Lev Legal Documents

Complete template for rendering legal documents in a paged web view.

## CSS Styles

```css
/* Import IBM Plex Sans */
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&display=swap');

:root {
  --page-width: 816px;
  --page-height: 1056px;
  --page-gap: 28px;
  --margin-top: 96px;
  --margin-bottom: 96px;
  --margin-left: 120px;  /* Binding margin */
  --margin-right: 96px;
  --accent-green: #22c55e;
  --text-dark: #1f2937;
  --text-gray: #6b7280;
  --text-light: #9ca3af;
  --font-family: 'IBM Plex Sans', Arial, sans-serif;
}

/* Page container */
.legal-document-paged {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--page-gap);
  padding: var(--page-gap);
  background: #f3f4f6;
}

/* Individual page */
.legal-page-card {
  width: var(--page-width);
  min-height: var(--page-height);
  background: white;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  position: relative;
}

/* Green accent bar at top */
.legal-page-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: var(--accent-green);
}

/* Page inner content area */
.page-inner {
  padding: var(--margin-top) var(--margin-right) var(--margin-bottom) var(--margin-left);
  font-family: var(--font-family);
  font-size: 14px;
  line-height: 1.35;
  color: var(--text-dark);
}

/* Running header */
.running-header {
  position: absolute;
  top: 48px;
  left: var(--margin-left);
  right: var(--margin-right);
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: var(--text-light);
  font-family: var(--font-family);
}

/* Footer */
.page-footer {
  position: absolute;
  bottom: 48px;
  left: var(--margin-left);
  right: var(--margin-right);
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 11px;
  color: var(--text-light);
  font-family: var(--font-family);
}

.page-footer .lev-icon {
  width: 24px;
  height: 24px;
}

/* Typography */
.legal-paragraph {
  margin: 0;
  text-indent: 24px;
  text-align: justify;
  hyphens: auto;
}

.legal-paragraph + .legal-paragraph {
  margin-top: 14px;
}

/* Section headings */
.legal-section-heading {
  display: flex;
  align-items: baseline;
  margin-bottom: 20px;
  margin-left: -48px; /* Outdent for hanging number */
}

.legal-section-number {
  width: 48px;
  flex-shrink: 0;
  font-weight: 700;
  color: var(--text-gray);
}

.legal-section-title {
  font-weight: 700;
  font-size: 16px;
}

/* Subsection headings */
.legal-subsection-heading {
  display: flex;
  align-items: baseline;
  margin-top: 20px;
  margin-bottom: 12px;
  margin-left: -36px;
}

.legal-subsection-number {
  width: 36px;
  flex-shrink: 0;
  font-weight: 600;
  color: var(--text-gray);
  font-size: 14px;
}

.legal-subsection-title {
  font-weight: 600;
  font-size: 14px;
}

/* Lists */
.legal-list {
  margin: 12px 0;
  padding-left: 0;
  list-style: none;
}

.legal-list-item {
  display: flex;
  margin-bottom: 8px;
}

.legal-list-marker {
  width: 32px;
  flex-shrink: 0;
  color: var(--text-gray);
}

/* Alpha list (a), (b), (c) */
.legal-list.alpha .legal-list-marker::before {
  content: '(' counter(alpha-item, lower-alpha) ')';
}

.legal-list.alpha {
  counter-reset: alpha-item;
}

.legal-list.alpha .legal-list-item {
  counter-increment: alpha-item;
}

/* Roman list (i), (ii), (iii) */
.legal-list.roman .legal-list-marker::before {
  content: '(' counter(roman-item, lower-roman) ')';
}

.legal-list.roman {
  counter-reset: roman-item;
}

.legal-list.roman .legal-list-item {
  counter-increment: roman-item;
}

/* Definition terms */
.definition-term {
  font-weight: 600;
}

/* Table of Contents */
.toc-entry {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
  border-bottom: 1px dotted #e5e7eb;
}

.toc-entry:hover {
  background: #f9fafb;
}

.toc-page-number {
  color: var(--text-gray);
}

/* Print styles */
@media print {
  @page {
    size: letter portrait;
    margin: 0;
  }

  .legal-document-paged {
    padding: 0;
    gap: 0;
    background: white;
  }

  .legal-page-card {
    box-shadow: none;
    page-break-after: always;
  }

  .legal-page-card:last-child {
    page-break-after: auto;
  }
}
```

## HTML Structure

```html
<div class="legal-document-paged">
  <!-- Page 1 -->
  <div class="legal-page-card">
    <div class="running-header">
      <span>Lev, Inc.</span>
      <span>Terms and Conditions</span>
    </div>
    
    <div class="page-inner">
      <!-- Section with outdented number -->
      <div class="legal-section-heading">
        <span class="legal-section-number">1.</span>
        <span class="legal-section-title">DEFINITIONS</span>
      </div>
      
      <p class="legal-paragraph">
        <span class="definition-term">"Agreement"</span> means these Terms and Conditions,
        together with any Order Forms, schedules, exhibits, and addenda incorporated herein
        by reference.
      </p>
      
      <p class="legal-paragraph">
        <span class="definition-term">"Services"</span> means the commercial real estate
        technology platform and related services provided by Lev to Customer pursuant to
        this Agreement.
      </p>
      
      <!-- Subsection -->
      <div class="legal-subsection-heading">
        <span class="legal-subsection-number">1.1</span>
        <span class="legal-subsection-title">Additional Definitions.</span>
      </div>
      
      <p class="legal-paragraph">
        The following additional terms shall have the meanings set forth below:
      </p>
      
      <!-- Alpha list -->
      <ul class="legal-list alpha">
        <li class="legal-list-item">
          <span class="legal-list-marker"></span>
          <span>"Customer Data" means all data submitted by Customer...</span>
        </li>
        <li class="legal-list-item">
          <span class="legal-list-marker"></span>
          <span>"Documentation" means user guides and technical materials...</span>
        </li>
      </ul>
    </div>
    
    <div class="page-footer">
      <img src="lev-icon.svg" class="lev-icon" alt="Lev">
      <span>Page 1 of 12</span>
    </div>
  </div>
  
  <!-- Additional pages follow same structure -->
</div>
```

## React Component Example

```jsx
function LegalPage({ pageNumber, totalPages, headerLeft, headerRight, children }) {
  return (
    <div className="legal-page-card">
      <div className="running-header">
        <span>{headerLeft}</span>
        <span>{headerRight}</span>
      </div>
      <div className="page-inner">
        {children}
      </div>
      <div className="page-footer">
        <LevIcon className="lev-icon" />
        <span>Page {pageNumber} of {totalPages}</span>
      </div>
    </div>
  );
}

function LegalSection({ number, title, children }) {
  return (
    <section>
      <div className="legal-section-heading">
        <span className="legal-section-number">{number}.</span>
        <span className="legal-section-title">{title}</span>
      </div>
      {children}
    </section>
  );
}

function LegalSubsection({ number, title, children }) {
  return (
    <div>
      <div className="legal-subsection-heading">
        <span className="legal-subsection-number">{number}</span>
        <span className="legal-subsection-title">{title}</span>
      </div>
      {children}
    </div>
  );
}

function LegalParagraph({ children }) {
  return <p className="legal-paragraph">{children}</p>;
}

function LegalList({ type = 'alpha', items }) {
  return (
    <ul className={`legal-list ${type}`}>
      {items.map((item, i) => (
        <li key={i} className="legal-list-item">
          <span className="legal-list-marker"></span>
          <span>{item}</span>
        </li>
      ))}
    </ul>
  );
}
```
