/**
 * DOM, Selection, Range and Content utilities for JBDEditor
 */

/**
 * Creates an element with attributes and optional children
 * @param {string} tag 
 * @param {Record<string, any>} [attrs] 
 * @param {Array<HTMLElement | string>} [children] 
 * @returns {HTMLElement}
 */
export function createElement(tag, attrs = {}, children = []) {
  const el = document.createElement(tag);

  for (const [key, value] of Object.entries(attrs)) {
    if (key === 'className') {
      el.className = value;
    } else if (key === 'style' && typeof value === 'object') {
      Object.assign(el.style, value);
    } else if (key.startsWith('on') && typeof value === 'function') {
      el.addEventListener(key.slice(2).toLowerCase(), value);
    } else if (key.startsWith('data-')) {
      el.setAttribute(key, value);
    } else if (typeof value === 'boolean') {
      if (value) el.setAttribute(key, '');
    } else if (value !== null && value !== undefined) {
      el.setAttribute(key, value);
    }
  }

  for (const child of children) {
    if (typeof child === 'string') {
      el.appendChild(document.createTextNode(child));
    } else if (child instanceof Node) {
      el.appendChild(child);
    }
  }

  return el;
}

/**
 * Checks if current selection is inside the specified container
 * @param {HTMLElement} container 
 * @returns {boolean}
 */
export function isSelectionInside(container) {
  const selection = window.getSelection();
  if (!selection || selection.rangeCount === 0) return false;
  const anchorNode = selection.anchorNode;
  return anchorNode ? container.contains(anchorNode) : false;
}

/**
 * Saves current selection range if inside container
 * @param {HTMLElement} container 
 * @returns {Range | null}
 */
export function saveSelection(container) {
  const selection = window.getSelection();
  if (!selection || selection.rangeCount === 0) return null;
  const range = selection.getRangeAt(0);
  if (container.contains(range.commonAncestorContainer)) {
    return range.cloneRange();
  }
  return null;
}

/**
 * Restores a previously saved Range
 * @param {Range} range 
 */
export function restoreSelection(range) {
  if (!range) return;
  const selection = window.getSelection();
  if (!selection) return;
  selection.removeAllRanges();
  selection.addRange(range);
}

/**
 * Inserts HTML or Node at the current cursor / range position
 * @param {HTMLElement} container
 * @param {Node | string} content
 * @param {Range} [savedRange]
 */
export function insertAtCursor(container, content, savedRange = null) {
  container.focus();
  const range = savedRange || saveSelection(container);

  if (range && container.contains(range.commonAncestorContainer)) {
    restoreSelection(range);
    if (typeof content === 'string') {
      document.execCommand('insertHTML', false, content);
    } else {
      range.deleteContents();
      range.insertNode(content);
      range.collapse(false);
    }
  } else {
    // Append to end of container if no active selection
    if (typeof content === 'string') {
      const temp = document.createElement('div');
      temp.innerHTML = content;
      while (temp.firstChild) {
        container.appendChild(temp.firstChild);
      }
    } else {
      container.appendChild(content);
    }
  }
}

/**
 * Gets the closest parent element matching tagName inside container
 * @param {HTMLElement} container 
 * @param {string | string[]} tagNames 
 * @returns {HTMLElement | null}
 */
export function getClosestBlock(container, tagNames) {
  const selection = window.getSelection();
  if (!selection || selection.rangeCount === 0) return null;
  let node = selection.anchorNode;
  if (!node) return null;
  if (node.nodeType === Node.TEXT_NODE) node = node.parentNode;

  const tags = Array.isArray(tagNames) ? tagNames.map(t => t.toLowerCase()) : [tagNames.toLowerCase()];

  while (node && node !== container) {
    if (tags.includes(node.nodeName.toLowerCase())) {
      return node;
    }
    node = node.parentNode;
  }
  return null;
}

/**
 * Gets currently selected text
 * @returns {string}
 */
export function getSelectedText() {
  const selection = window.getSelection();
  return selection ? selection.toString() : '';
}

/**
 * Lightweight HTML sanitizer for safe paste and display
 * Removes dangerous tags and inline on* event attributes.
 * @param {string} html 
 * @returns {string}
 */
export function sanitizeHTML(html) {
  if (!html) return '';
  const parser = new DOMParser();
  const doc = parser.parseFromString(html, 'text/html');

  const dangerousTags = ['script', 'iframe', 'object', 'embed', 'style', 'link', 'meta', 'applet'];
  dangerousTags.forEach(tag => {
    const elements = doc.querySelectorAll(tag);
    elements.forEach(el => el.remove());
  });

  const allElements = doc.querySelectorAll('*');
  allElements.forEach(el => {
    const attrs = Array.from(el.attributes);
    for (const attr of attrs) {
      const name = attr.name.toLowerCase();
      const val = attr.value.trim().toLowerCase();
      if (name.startsWith('on')) {
        el.removeAttribute(attr.name);
      }
      if ((name === 'href' || name === 'src') && val.startsWith('javascript:')) {
        el.removeAttribute(attr.name);
      }
    }
  });

  return doc.body.innerHTML;
}

/**
 * Clean up tool for documents and pasted HTML content.
 * Cleans and removes element styles and classes while preserving semantic structure.
 * 
 * @param {string} html - HTML string to clean
 * @param {Object} [options] - Cleanup options
 * @param {boolean} [options.removeStyles=true] - Remove all inline style attributes
 * @param {boolean} [options.removeClasses=true] - Remove all class attributes (except preserved)
 * @param {boolean} [options.convertSemanticStyles=true] - Convert bold/italic/underline styles to semantic tags before stripping
 * @param {boolean} [options.unwrapRedundantSpans=true] - Unwrap <span> tags with no attributes
 * @param {boolean} [options.unwrapFontTags=true] - Unwrap legacy <font> tags
 * @param {boolean} [options.cleanOfficeArtifacts=true] - Strip MSO tags, XML, and Office comments
 * @param {string[]} [options.preserveClasses=[]] - Whitelist of classes to preserve
 * @param {string} [options.tableClass='jbd-table jbd-table-bordered'] - Accessible class to apply to tables
 * @returns {string} Sanitized and cleaned HTML with styles and classes removed
 */
export function cleanDocumentHTML(html, options = {}) {
  if (!html || typeof html !== 'string') return '';

  const {
    removeStyles = true,
    removeClasses = true,
    convertSemanticStyles = true,
    unwrapRedundantSpans = true,
    unwrapFontTags = true,
    cleanOfficeArtifacts = true,
    preserveClasses = ['jbd-anchor-marker'],
    tableClass = 'jbd-table jbd-table-bordered'
  } = options;

  // 1. Remove Office conditional comments (<!--[if ...]>...<![endif]-->) & HTML comments
  let cleanInput = html
    .replace(/<!--\[if[\s\S]*?\]>[\s\S]*?<!\[endif\]-->/gi, '')
    .replace(/<!--[\s\S]*?-->/g, '');

  const parser = new DOMParser();
  const doc = parser.parseFromString(cleanInput, 'text/html');
  const body = doc.body;

  // Helper to unwrap an element (replace with its children)
  function unwrapElement(el) {
    const parent = el.parentNode;
    if (!parent) return;
    while (el.firstChild) {
      parent.insertBefore(el.firstChild, el);
    }
    parent.removeChild(el);
  }

  // Helper to wrap element children in a semantic tag
  function wrapInner(el, wrapperTag) {
    if (!el.childNodes.length) return;
    const wrapper = doc.createElement(wrapperTag);
    while (el.firstChild) {
      wrapper.appendChild(el.firstChild);
    }
    el.appendChild(wrapper);
  }

  // 2. Remove office namespaces and unwanted tags
  if (cleanOfficeArtifacts) {
    const junkSelectors = [
      'o\\:p', 'xml', 'style', 'link', 'meta', 'title', 'script',
      'w\\:worddocument', 'm\\:math', 'v\\:shape', 'v\\:path'
    ];
    junkSelectors.forEach(sel => {
      try {
        body.querySelectorAll(sel).forEach(el => el.remove());
      } catch {
        // Fallback if selector is not supported by parser
      }
    });

    const allEls = Array.from(body.querySelectorAll('*'));
    allEls.forEach(el => {
      const tagLower = el.tagName.toLowerCase();
      if (
        tagLower === 'o:p' ||
        tagLower.startsWith('o:') ||
        tagLower.startsWith('w:') ||
        tagLower.startsWith('v:') ||
        tagLower.startsWith('m:')
      ) {
        if (!el.textContent.trim()) {
          el.remove();
        } else {
          unwrapElement(el);
        }
      }
    });
  }

  // 3. Unwrap legacy <font> tags
  if (unwrapFontTags) {
    const fonts = Array.from(body.querySelectorAll('font'));
    fonts.forEach(font => unwrapElement(font));
  }

  // 4. Unwrap Google Docs false-bold wrapper (<b style="font-weight:normal">)
  const boldEls = Array.from(body.querySelectorAll('b, strong'));
  boldEls.forEach(el => {
    const style = (el.getAttribute('style') || '').toLowerCase();
    const fw = (el.style.fontWeight || '').toLowerCase();
    if (fw === 'normal' || fw === '400' || /font-weight\s*:\s*(normal|400)/i.test(style)) {
      unwrapElement(el);
    }
  });

  // 5. Convert semantic inline styles to semantic HTML tags before stripping
  if (convertSemanticStyles) {
    const styledEls = Array.from(body.querySelectorAll('[style]'));
    styledEls.forEach(el => {
      const style = (el.getAttribute('style') || '').toLowerCase();
      const fontWeight = (el.style.fontWeight || '').toLowerCase();
      const fontStyle = (el.style.fontStyle || '').toLowerCase();
      const textDecoration = (el.style.textDecoration || '').toLowerCase();
      const verticalAlign = (el.style.verticalAlign || '').toLowerCase();

      const isBold = /bold|700|800|900/.test(fontWeight) || /font-weight\s*:\s*(bold|[6-9]00)/.test(style);
      const isItalic = fontStyle === 'italic' || /font-style\s*:\s*italic/.test(style);
      const isUnderline = textDecoration.includes('underline') || /text-decoration\s*:\s*[^;]*underline/.test(style);
      const isStrike = textDecoration.includes('line-through') || /text-decoration\s*:\s*[^;]*line-through/.test(style);
      const isSub = verticalAlign === 'sub' || /vertical-align\s*:\s*sub/.test(style);
      const isSuper = verticalAlign === 'super' || /vertical-align\s*:\s*super/.test(style);

      const tag = el.tagName.toLowerCase();

      if (isBold && tag !== 'b' && tag !== 'strong') {
        wrapInner(el, 'strong');
      }
      if (isItalic && tag !== 'i' && tag !== 'em') {
        wrapInner(el, 'em');
      }
      if (isUnderline && tag !== 'u') {
        wrapInner(el, 'u');
      }
      if (isStrike && tag !== 's' && tag !== 'strike') {
        wrapInner(el, 's');
      }
      if (isSub && tag !== 'sub') {
        wrapInner(el, 'sub');
      }
      if (isSuper && tag !== 'sup') {
        wrapInner(el, 'sup');
      }
    });
  }

  // 6. Clean element styles, classes, and junk attributes
  const allElements = Array.from(body.querySelectorAll('*'));
  allElements.forEach(el => {
    // Remove element style
    if (removeStyles) {
      el.removeAttribute('style');
    }

    // Remove or filter classes (always preserve jbd-anchor-marker bookmark class)
    if (removeClasses) {
      const allowed = Array.isArray(preserveClasses) ? preserveClasses : [];
      const kept = Array.from(el.classList).filter(c => c === 'jbd-anchor-marker' || allowed.includes(c));
      if (kept.length > 0) {
        el.className = kept.join(' ');
      } else {
        el.removeAttribute('class');
      }
    }

    // Clean junk attributes
    const attrs = Array.from(el.attributes);
    for (const attr of attrs) {
      const name = attr.name.toLowerCase();
      if (
        name.startsWith('mso-') ||
        name.startsWith('v:') ||
        name.startsWith('o:') ||
        name.startsWith('w:') ||
        (name.startsWith('data-') && !name.startsWith('data-jbd-')) ||
        name === 'lang' ||
        name === 'face' ||
        name === 'size' ||
        name === 'color' ||
        name === 'clear' ||
        name === 'border' ||
        name === 'bgcolor' ||
        name === 'cellspacing' ||
        name === 'cellpadding'
      ) {
        el.removeAttribute(attr.name);
      }
      if (name === 'id' && (attr.value.startsWith('docs-internal-guid') || attr.value.startsWith('_mcePaste'))) {
        el.removeAttribute(attr.name);
      }
    }

    // Tables: assign accessible table class
    if (el.tagName.toLowerCase() === 'table' && tableClass) {
      el.className = tableClass;
    }
  });

  // 7. Unwrap redundant empty <span> elements (spans that now have no attributes)
  if (unwrapRedundantSpans) {
    let changed = true;
    while (changed) {
      changed = false;
      const spans = Array.from(body.querySelectorAll('span'));
      for (const span of spans) {
        if (span.attributes.length === 0) {
          unwrapElement(span);
          changed = true;
        }
      }
    }
  }

  // 8. Remove completely empty inline formatting elements
  const emptyCheckTags = ['span', 'b', 'strong', 'i', 'em', 'u', 's', 'strike', 'sub', 'sup'];
  emptyCheckTags.forEach(tag => {
    body.querySelectorAll(tag).forEach(el => {
      if (!el.textContent.trim() && !el.querySelector('img, br, svg')) {
        el.remove();
      }
    });
  });

  return body.innerHTML;
}

export const cleanHTML = cleanDocumentHTML;

/**
 * Clean and beautify HTML with proper indentation and line breaks.
 * Uses window.html_beautify if available (js-beautify), otherwise uses native DOM formatter.
 * @param {string} html 
 * @param {string} [indent='  '] 
 * @returns {string} Formatted clean HTML
 */
export function formatHTML(html, indent = '  ') {
  if (!html) return '';

  // 1. If external js-beautify library is loaded, use it
  if (typeof window !== 'undefined' && typeof window.html_beautify === 'function') {
    try {
      return window.html_beautify(html, {
        indent_size: 2,
        indent_char: ' ',
        max_preserve_newlines: 1,
        preserve_newlines: true,
        indent_inner_html: true,
        wrap_line_length: 0
      });
    } catch {
      // Fall through to native formatter
    }
  }

  // 2. Native pure Vanilla JS DOM Beautifier (Zero dependencies)
  try {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    const body = doc.body;

    const blockTags = new Set([
      'address', 'article', 'aside', 'blockquote', 'details', 'dialog', 'dd',
      'div', 'dl', 'dt', 'fieldset', 'figcaption', 'figure', 'footer', 'form',
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'header', 'hgroup', 'hr', 'li',
      'main', 'nav', 'ol', 'p', 'pre', 'section', 'table', 'tbody', 'td',
      'tfoot', 'th', 'thead', 'tr', 'ul'
    ]);

    const voidTags = new Set([
      'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
      'link', 'meta', 'param', 'source', 'track', 'wbr'
    ]);

    function serializeNode(node, depth) {
      if (node.nodeType === Node.COMMENT_NODE) {
        return indent.repeat(depth) + `<!--${node.nodeValue}-->`;
      }

      if (node.nodeType === Node.TEXT_NODE) {
        return node.textContent;
      }

      if (node.nodeType !== Node.ELEMENT_NODE) {
        return '';
      }

      const tag = node.tagName.toLowerCase();
      const isBlock = blockTags.has(tag);
      const isVoid = voidTags.has(tag);
      const ind = indent.repeat(depth);

      let openTag = `<${tag}`;
      for (const attr of Array.from(node.attributes)) {
        openTag += ` ${attr.name}="${attr.value.replace(/"/g, '&quot;')}"`;
      }
      openTag += '>';

      if (isVoid) {
        return (isBlock ? ind : '') + openTag;
      }

      const hasBlockChild = Array.from(node.children).some(child => blockTags.has(child.tagName.toLowerCase()));

      let innerContent = '';
      if (hasBlockChild) {
        const childSnippets = [];
        for (const child of node.childNodes) {
          if (child.nodeType === Node.TEXT_NODE && !child.textContent.trim()) {
            continue;
          }
          childSnippets.push(serializeNode(child, depth + 1));
        }
        innerContent = '\n' + childSnippets.join('\n') + '\n' + ind;
        return ind + openTag + innerContent + `</${tag}>`;
      } else {
        for (const child of node.childNodes) {
          if (child.nodeType === Node.TEXT_NODE) {
            innerContent += child.textContent;
          } else if (child.nodeType === Node.ELEMENT_NODE) {
            innerContent += child.outerHTML;
          }
        }
        return (isBlock ? ind : '') + openTag + innerContent + `</${tag}>`;
      }
    }

    const result = [];
    for (const child of body.childNodes) {
      if (child.nodeType === Node.TEXT_NODE && !child.textContent.trim()) continue;
      result.push(serializeNode(child, 0));
    }

    return result.join('\n\n').trim();
  } catch {
    return html;
  }
}

