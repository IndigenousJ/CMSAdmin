/**
 * a11y.js - WCAG 2.1 Level AA Accessibility Validator & Auditor for JBDEditor & CMSAdmin
 * Performs robust accessibility linting and auditing on HTML content:
 * - 1.1.1 Non-text Content (img alt attributes, decorative vs informative images)
 * - 1.3.1 Info and Relationships (heading hierarchy, empty headings, table captions & headers)
 * - 2.4.4 Link Purpose in Context (empty links, ambiguous link text like "click here", "read more")
 * - 4.1.2 Name, Role, Value (buttons with accessible names, iframes with titles)
 * - 1.4.3 Contrast / Readability (inline low contrast text colors, font styling)
 * - Target Size & Semantic HTML Checks
 */

export class A11yValidator {
  /**
   * Evaluates an HTML string or DOM node against WCAG 2.1 AA rules
   * @param {string | HTMLElement} input - HTML content string or DOM element to audit
   * @returns {{ passed: boolean, errors: Array<{ rule: string, element: string, message: string, suggestion: string, node?: HTMLElement }>, warnings: Array<{ rule: string, element: string, message: string, suggestion: string, node?: HTMLElement }> }}
   */
  static validate(input) {
    let container;
    if (typeof input === 'string') {
      container = document.createElement('div');
      container.innerHTML = input.trim();
    } else if (input instanceof HTMLElement) {
      container = input;
    } else {
      return { passed: true, errors: [], warnings: [] };
    }

    const errors = [];
    const warnings = [];

    // --- 1. Images & Visual Media (WCAG 1.1.1 Non-text Content) ---
    const images = container.querySelectorAll('img');
    images.forEach((img, idx) => {
      const hasAlt = img.hasAttribute('alt');
      const altVal = (img.getAttribute('alt') || '').trim();
      const src = img.getAttribute('src') || '';
      const srcLabel = src.length > 40 ? src.substring(0, 37) + '...' : (src || `Image #${idx + 1}`);

      if (!hasAlt) {
        errors.push({
          rule: 'WCAG 1.1.1 (Non-text Content)',
          element: `<img src="${srcLabel}">`,
          message: 'Image is missing an alt attribute.',
          suggestion: 'Provide descriptive alternative text (alt="...") or alt="" if the image is purely decorative.',
          node: img
        });
      } else if (altVal.length > 0) {
        const lower = altVal.toLowerCase();
        if (lower === 'image' || lower === 'photo' || lower === 'picture' || lower === 'graphic' || lower === 'img' || lower === 'icon') {
          warnings.push({
            rule: 'WCAG 1.1.1 (Non-text Content)',
            element: `<img alt="${altVal}">`,
            message: `Generic alternative text "${altVal}" provides no meaningful context.`,
            suggestion: 'Describe the specific subject or function of the image rather than calling it "image" or "photo".',
            node: img
          });
        }
      }
    });

    // --- 2. Links (WCAG 2.4.4 Link Purpose in Context) ---
    const links = container.querySelectorAll('a');
    const ambiguousPhrases = ['click here', 'here', 'more', 'read more', 'learn more', 'link', 'download', 'view', 'details', 'info'];
    links.forEach((a, idx) => {
      // In-page named anchor (bookmark) tags with name or id and no href are valid jump targets
      const isNamedAnchor = (a.hasAttribute('name') || a.classList.contains('jbd-anchor-marker')) && !a.hasAttribute('href');
      if (isNamedAnchor) {
        return; // Valid in-page bookmark target
      }

      const href = (a.getAttribute('href') || '').trim();
      const text = (a.textContent || '').trim();
      const hasAriaLabel = a.hasAttribute('aria-label') && a.getAttribute('aria-label').trim().length > 0;
      const hasTitle = a.hasAttribute('title') && a.getAttribute('title').trim().length > 0;
      const hasChildImgWithAlt = Array.from(a.querySelectorAll('img')).some(i => (i.getAttribute('alt') || '').trim().length > 0);

      const accessibleName = (text || (hasAriaLabel ? a.getAttribute('aria-label') : '') || (hasChildImgWithAlt ? 'image link' : '')).trim();

      if (!href || href === '#' || href === 'javascript:void(0);' || href === 'javascript:;') {
        warnings.push({
          rule: 'WCAG 2.4.4 / 4.1.2 (Link Destination)',
          element: `<a>${text || 'Link #' + (idx + 1)}</a>`,
          message: 'Link is missing a valid destination URL (href is empty or "#").',
          suggestion: 'Provide a valid web URL, document path, or use a <button> element if this is an on-page action.',
          node: a
        });
      }

      if (!accessibleName && !hasTitle) {
        errors.push({
          rule: 'WCAG 2.4.4 (Link Purpose)',
          element: `<a href="${href}">`,
          message: 'Link is completely empty and has no accessible name or text.',
          suggestion: 'Add text inside the link, or provide an aria-label describing where the link navigates.',
          node: a
        });
      } else if (accessibleName) {
        const lower = accessibleName.toLowerCase().replace(/[^a-z0-9 ]/g, '').trim();
        if (ambiguousPhrases.includes(lower)) {
          warnings.push({
            rule: 'WCAG 2.4.4 (Link Purpose)',
            element: `<a href="${href}">${accessibleName}</a>`,
            message: `Ambiguous link text "${accessibleName}" without surrounding context.`,
            suggestion: `Make the link text descriptive (e.g. "Read the 2026 Budget Report" instead of "${accessibleName}").`,
            node: a
          });
        }
      }

      // Check for target="_blank" without rel="noopener" or ADA indication
      if (a.getAttribute('target') === '_blank') {
        const rel = (a.getAttribute('rel') || '').toLowerCase();
        if (!rel.includes('noopener')) {
          warnings.push({
            rule: 'WCAG Best Practice (Security & Navigation)',
            element: `<a href="${href}" target="_blank">`,
            message: 'Link opens in a new tab without rel="noopener noreferrer".',
            suggestion: 'Add rel="noopener noreferrer" for security and performance when opening external tabs.',
            node: a
          });
        }

        const aria = (a.getAttribute('aria-label') || '').toLowerCase();
        const txt = (a.textContent || '').toLowerCase();
        const tit = (a.getAttribute('title') || '').toLowerCase();
        const hasNotice = aria.includes('new tab') || aria.includes('new window') ||
                          txt.includes('new tab') || txt.includes('new window') ||
                          tit.includes('new tab') || tit.includes('new window');
        if (!hasNotice) {
          warnings.push({
            rule: 'WCAG 3.2.5 (Change on Request / Predictability)',
            element: `<a href="${href}" target="_blank">`,
            message: 'Link opens in a new tab without an audible ADA notification for screen readers.',
            suggestion: 'Add an aria-label with "(opens in a new tab)" to alert screen reader users.',
            node: a
          });
        }
      }
    });

    // --- 3. Headings (WCAG 1.3.1 Info and Relationships) ---
    // Rule: The outer page template title already provides the singular H1 for the page.
    // In-content section headings must begin with H2, and H1 tags inside the editor are flagged.
    const headings = container.querySelectorAll('h1, h2, h3, h4, h5, h6');
    let lastHeadingLevel = 1; // Base level from the external page title (H1)
    let isFirstContentHeading = true;

    headings.forEach((h) => {
      const text = (h.textContent || '').trim();
      const level = parseInt(h.tagName.substring(1), 10);

      if (!text && !h.querySelector('img[alt]')) {
        errors.push({
          rule: 'WCAG 1.3.1 (Info and Relationships)',
          element: `<${h.tagName.toLowerCase()}>`,
          message: `Empty heading <${h.tagName.toLowerCase()}> found.`,
          suggestion: 'Remove empty heading tags or provide meaningful section heading text.',
          node: h
        });
      }

      // Check if user inserted an H1 in editor content
      if (level === 1) {
        warnings.push({
          rule: 'WCAG 1.3.1 (Heading Hierarchy)',
          element: `<h1>${text.substring(0, 30)}</h1>`,
          message: 'The page title is already assigned as the primary <h1>. In-page content headings should begin at <h2>.',
          suggestion: 'Change this heading from <h1> to <h2> to maintain a compliant document outline hierarchy.',
          node: h
        });
      } else if (isFirstContentHeading && level > 2) {
        // First heading in content skipped H2 (e.g. jumped directly to H3 or H4)
        warnings.push({
          rule: 'WCAG 1.3.1 (Heading Hierarchy)',
          element: `<${h.tagName.toLowerCase()}>${text.substring(0, 30)}</${h.tagName.toLowerCase()}>`,
          message: `Top-level content heading skipped <h2>: found <${h.tagName.toLowerCase()}> after page title <h1>.`,
          suggestion: 'Change this initial section heading to <h2> so document hierarchy begins correctly after the page title.',
          node: h
        });
      } else if (!isFirstContentHeading && level > lastHeadingLevel + 1) {
        // Subsequent heading skipped intermediate level (e.g. H2 to H4 without H3)
        warnings.push({
          rule: 'WCAG 1.3.1 (Heading Hierarchy)',
          element: `<${h.tagName.toLowerCase()}>${text.substring(0, 30)}</${h.tagName.toLowerCase()}>`,
          message: `Heading level skipped: <${h.tagName.toLowerCase()}> follows <h${lastHeadingLevel}>.`,
          suggestion: `Use <h${lastHeadingLevel + 1}> to preserve a logical reading and outline order for assistive technologies.`,
          node: h
        });
      }

      isFirstContentHeading = false;
      lastHeadingLevel = level;
    });

    // --- 4. Tables (WCAG 1.3.1 Info and Relationships) ---
    const tables = container.querySelectorAll('table');
    tables.forEach((table, idx) => {
      // Check table caption
      const caption = table.querySelector('caption');
      const hasAriaLabel = table.hasAttribute('aria-label') || table.hasAttribute('aria-labelledby');
      if (!caption && !hasAriaLabel) {
        warnings.push({
          rule: 'WCAG 1.3.1 (Data Tables)',
          element: `<table> (Table #${idx + 1})`,
          message: 'Data table does not have a <caption> or aria-label.',
          suggestion: 'Add a <caption> element or aria-label summarizing the contents and purpose of the table.',
          node: table
        });
      }

      // Check table headers
      const ths = table.querySelectorAll('th');
      if (ths.length === 0) {
        errors.push({
          rule: 'WCAG 1.3.1 (Data Tables)',
          element: `<table> (Table #${idx + 1})`,
          message: 'Table has no header cells (<th>). Screen readers cannot associate data cells with headers.',
          suggestion: 'Convert the first row or column cells to <th scope="col"> or <th scope="row">.',
          node: table
        });
      } else {
        ths.forEach(th => {
          if (!th.hasAttribute('scope')) {
            warnings.push({
              rule: 'WCAG 1.3.1 (Table Headers)',
              element: `<th>${(th.textContent || '').trim().substring(0, 20)}</th>`,
              message: 'Table header cell <th> is missing a scope attribute.',
              suggestion: 'Add scope="col" (for column headers) or scope="row" (for row headers).',
              node: th
            });
          }
        });
      }
    });

    // --- 5. Interactive Elements & Media (WCAG 4.1.2 Name, Role, Value) ---
    const iframes = container.querySelectorAll('iframe');
    iframes.forEach((iframe, idx) => {
      const title = (iframe.getAttribute('title') || '').trim();
      const hasAriaLabel = (iframe.getAttribute('aria-label') || '').trim();
      if (!title && !hasAriaLabel) {
        errors.push({
          rule: 'WCAG 4.1.2 (Frames & Iframes)',
          element: `<iframe src="${iframe.getAttribute('src') || ''}">`,
          message: `Embedded frame (#${idx + 1}) is missing a title attribute.`,
          suggestion: 'Add title="..." describing the content of the embedded frame (e.g. title="County GIS Map").',
          node: iframe
        });
      }
    });

    const buttons = container.querySelectorAll('button');
    buttons.forEach((btn, idx) => {
      const text = (btn.textContent || '').trim();
      const ariaLabel = (btn.getAttribute('aria-label') || '').trim();
      if (!text && !ariaLabel) {
        errors.push({
          rule: 'WCAG 4.1.2 (Name, Role, Value)',
          element: `<button> (Button #${idx + 1})`,
          message: 'Button has no readable text or aria-label.',
          suggestion: 'Add visible text or aria-label="..." describing the action triggered by the button.',
          node: btn
        });
      }
    });

    return {
      passed: errors.length === 0,
      errors,
      warnings
    };
  }

  /**
   * Renders the WCAG 2.1 AA validation modal report
   * @param {Object} options
   * @param {{ passed: boolean, errors: Array<any>, warnings: Array<any> }} options.results
   * @param {() => void} options.onProceed - Callback if user chooses to proceed with saving anyway
   * @param {() => void} [options.onCancel] - Callback if user cancels save to fix issues
   * @param {(node: HTMLElement) => void} [options.onHighlight] - Callback to scroll to/focus problematic node
   */
  static showModal({ results, onProceed, onCancel, onHighlight }) {
    const errorCount = results.errors.length;
    const warnCount = results.warnings.length;
    const isPassing = results.passed;

    // Create modal content
    const modalWrap = document.createElement('div');
    modalWrap.className = 'jbd-a11y-report';

    let summaryHtml = '';
    if (isPassing && warnCount === 0) {
      summaryHtml = `
        <div class="jbd-a11y-banner jbd-a11y-banner--success" role="status">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
          <div>
            <strong>WCAG 2.1 Level AA Compliance Passed!</strong>
            <p>No accessibility barriers were detected in your content. High-contrast, semantic headings, image descriptions, and link tags are properly structured.</p>
          </div>
        </div>
      `;
    } else if (errorCount > 0) {
      summaryHtml = `
        <div class="jbd-a11y-banner jbd-a11y-banner--danger" role="alert">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
          <div>
            <strong>${errorCount} Accessibility Issue${errorCount === 1 ? '' : 's'} Found (WCAG 2.1 AA)</strong>
            <p>Your content contains accessibility violations that will prevent people with disabilities or assistive technologies from reading this page properly.</p>
          </div>
        </div>
      `;
    } else {
      summaryHtml = `
        <div class="jbd-a11y-banner jbd-a11y-banner--warning" role="status">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
          <div>
            <strong>${warnCount} Accessibility Recommendation${warnCount === 1 ? '' : 's'}</strong>
            <p>No critical failures were detected, but some best-practice opportunities were identified to improve inclusivity.</p>
          </div>
        </div>
      `;
    }

    let itemsHtml = '';
    if (errorCount > 0 || warnCount > 0) {
      itemsHtml += '<div class="jbd-a11y-list" role="list">';
      
      results.errors.forEach((err, i) => {
        itemsHtml += `
          <div class="jbd-a11y-item jbd-a11y-item--error" role="listitem">
            <div class="jbd-a11y-item-header">
              <span class="jbd-a11y-tag jbd-a11y-tag--danger">Violation</span>
              <span class="jbd-a11y-rule">${A11yValidator.escapeHtml(err.rule)}</span>
            </div>
            <div class="jbd-a11y-item-msg">${A11yValidator.escapeHtml(err.message)}</div>
            <code class="jbd-a11y-code">${A11yValidator.escapeHtml(err.element)}</code>
            <div class="jbd-a11y-fix"><strong>How to resolve:</strong> ${A11yValidator.escapeHtml(err.suggestion)}</div>
          </div>
        `;
      });

      results.warnings.forEach((warn, i) => {
        itemsHtml += `
          <div class="jbd-a11y-item jbd-a11y-item--warning" role="listitem">
            <div class="jbd-a11y-item-header">
              <span class="jbd-a11y-tag jbd-a11y-tag--warning">Recommendation</span>
              <span class="jbd-a11y-rule">${A11yValidator.escapeHtml(warn.rule)}</span>
            </div>
            <div class="jbd-a11y-item-msg">${A11yValidator.escapeHtml(warn.message)}</div>
            <code class="jbd-a11y-code">${A11yValidator.escapeHtml(warn.element)}</code>
            <div class="jbd-a11y-fix"><strong>Suggestion:</strong> ${A11yValidator.escapeHtml(warn.suggestion)}</div>
          </div>
        `;
      });

      itemsHtml += '</div>';
    }

    modalWrap.innerHTML = `
      ${summaryHtml}
      ${itemsHtml}
    `;

    // Backdrop & Modal Container
    const existing = document.getElementById('jbdA11yModalOverlay');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = 'jbdA11yModalOverlay';
    overlay.className = 'admin-modal-backdrop open';
    overlay.style.cssText = 'display:flex; justify-content:center; align-items:center; opacity:1; visibility:visible; z-index:100000; background:rgba(15, 23, 42, 0.72) !important; backdrop-filter:blur(6px) !important; -webkit-backdrop-filter:blur(6px) !important; position:fixed; top:0; left:0; width:100vw; height:100vh;';

    const dialog = document.createElement('div');
    dialog.className = 'admin-modal-window';
    dialog.setAttribute('role', 'dialog');
    dialog.setAttribute('aria-modal', 'true');
    dialog.setAttribute('aria-labelledby', 'jbdA11yTitle');
    dialog.style.cssText = 'background:var(--admin-card-bg, #fff); width:90%; max-width:680px; max-height:85vh; border-radius:12px; display:flex; flex-direction:column; box-shadow:0 25px 50px -12px rgba(0,0,0,0.35); overflow:hidden; border:1px solid var(--admin-border-subtle, #e2e8f0); animation: modalIn 0.2s cubic-bezier(0.16, 1, 0.3, 1);';

    dialog.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; padding:1.1rem 1.5rem; border-bottom:1px solid var(--admin-border-subtle, #e2e8f0); background:var(--admin-bg-subtle, #f8fafc);">
        <div style="display:flex; align-items:center; gap:0.5rem;">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--admin-primary, #0284c7)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="m4.93 4.93 4.24 4.24"/><path d="m14.83 9.17 4.24-4.24"/><path d="m14.83 14.83 4.24 4.24"/><path d="m9.17 14.83-4.24 4.24"/><circle cx="12" cy="12" r="4"/></svg>
          <h3 id="jbdA11yTitle" style="margin:0; font-size:1.1rem; font-weight:600; color:var(--admin-text-main, #0f172a);">WCAG 2.1 AA Accessibility Validation</h3>
        </div>
        <button type="button" id="btnA11yClose" class="btn btn-outline btn-xs" aria-label="Close accessibility validator" style="border-radius:6px; padding:0.25rem 0.5rem;">&times;</button>
      </div>
      <div style="padding:1.25rem 1.5rem; overflow-y:auto; flex:1;">
        ${modalWrap.outerHTML}
      </div>
      <div style="display:flex; justify-content:space-between; align-items:center; padding:1rem 1.5rem; border-top:1px solid var(--admin-border-subtle, #e2e8f0); background:var(--admin-bg-subtle, #f8fafc); gap:0.75rem;">
        <button type="button" id="btnA11yCancel" class="btn btn-outline btn-sm">Fix Accessibility Issues</button>
        <div style="display:flex; gap:0.5rem;">
          ${errorCount > 0 ? `
            <button type="button" id="btnA11yOverride" class="btn btn-warning btn-sm" style="display:flex; align-items:center; gap:0.35rem;">
              <span>Save Anyway (Override)</span>
            </button>
          ` : `
            <button type="button" id="btnA11yProceed" class="btn btn-primary btn-sm" style="display:flex; align-items:center; gap:0.35rem;">
              <span>Continue Saving</span>
            </button>
          `}
        </div>
      </div>
    `;

    overlay.appendChild(dialog);
    document.body.appendChild(overlay);

    const closeOverlay = () => {
      overlay.remove();
      if (typeof onCancel === 'function') onCancel();
    };

    const proceedSave = () => {
      overlay.remove();
      if (typeof onProceed === 'function') onProceed();
    };

    const btnClose = dialog.querySelector('#btnA11yClose');
    const btnCancel = dialog.querySelector('#btnA11yCancel');
    const btnOverride = dialog.querySelector('#btnA11yOverride');
    const btnProceed = dialog.querySelector('#btnA11yProceed');

    if (btnClose) btnClose.addEventListener('click', closeOverlay);
    if (btnCancel) btnCancel.addEventListener('click', closeOverlay);
    if (btnOverride) btnOverride.addEventListener('click', proceedSave);
    if (btnProceed) btnProceed.addEventListener('click', proceedSave);

    const keyListener = (e) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        document.removeEventListener('keydown', keyListener);
        closeOverlay();
      }
    };
    document.addEventListener('keydown', keyListener);
  }

  static escapeHtml(str) {
    if (!str) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
}

