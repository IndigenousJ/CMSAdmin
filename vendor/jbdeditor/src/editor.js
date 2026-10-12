/**
 * JBDEditor - Attachable Vanilla JavaScript Rich Text Editor
 * Zero dependencies, pure native browser ES module.
 */
import {
  Toolbar,
  InlineToolbar,
  JBD_FULL_TOOLBAR,
  JBD_BASIC_TOOLBAR,
  JBD_MINIMAL_TOOLBAR,
  JBD_SUBPAGE_TOOLBAR,
  JBD_ARTICLE_TOOLBAR,
  JBD_DEFAULT_INLINE_TOOLBAR
} from './toolbar.js';
import { Dialog } from './dialog.js';
import { TableManager } from './table.js';
import { StorageManager } from './storage.js';
import { HistoryManager } from './history.js';
import { A11yValidator } from './a11y.js';
import {
  createElement,
  saveSelection,
  restoreSelection,
  insertAtCursor,
  isSelectionInside,
  sanitizeHTML,
  cleanDocumentHTML,
  cleanHTML,
  getClosestBlock,
  getSelectedText,
  formatHTML
} from './utils.js';

export class CustomEditor {
  static TOOLBAR_PRESETS = {
    full: JBD_FULL_TOOLBAR,
    basic: JBD_BASIC_TOOLBAR,
    minimal: JBD_MINIMAL_TOOLBAR,
    article: JBD_ARTICLE_TOOLBAR
  };

  static Toolbar = Toolbar;
  static InlineToolbar = InlineToolbar;
  static JBD_FULL_TOOLBAR = JBD_FULL_TOOLBAR;
  static JBD_BASIC_TOOLBAR = JBD_BASIC_TOOLBAR;
  static JBD_MINIMAL_TOOLBAR = JBD_MINIMAL_TOOLBAR;
  static JBD_ARTICLE_TOOLBAR = JBD_ARTICLE_TOOLBAR;
  static JBD_DEFAULT_INLINE_TOOLBAR = JBD_DEFAULT_INLINE_TOOLBAR;

  // Backward-compatibility aliases
  static JAL_FULL_TOOLBAR = JBD_FULL_TOOLBAR;
  static JAL_BASIC_TOOLBAR = JBD_BASIC_TOOLBAR;
  static JAL_MINIMAL_TOOLBAR = JBD_MINIMAL_TOOLBAR;
  static JAL_ARTICLE_TOOLBAR = JBD_ARTICLE_TOOLBAR;
  static JAL_DEFAULT_INLINE_TOOLBAR = JBD_DEFAULT_INLINE_TOOLBAR;

  static cleanDocumentHTML = cleanDocumentHTML;
  static cleanHTML = cleanDocumentHTML;
  static A11yValidator = A11yValidator;
  static validateA11y = (html) => A11yValidator.validate(html);

  static _instances = new Map();
  static autoInit = true;

  /**
   * Static factory to attach editor to any textarea or selector
   * @param {string | HTMLTextAreaElement | HTMLInputElement} target 
   * @param {Object} [options] 
   * @returns {CustomEditor}
   */
  static attach(target, options = {}) {
    const el = typeof target === 'string' ? document.querySelector(target) : target;
    if (!el) {
      throw new Error(`JBDEditor: Target element "${target}" not found.`);
    }
    if (CustomEditor._instances.has(el)) {
      const existing = CustomEditor._instances.get(el);
      if (Object.keys(options).length === 0) {
        return existing;
      }
      existing.destroy();
    }
    return new CustomEditor(el, options);
  }

  /**
   * Retrieve an active editor instance attached to an element or selector
   * @param {string | HTMLElement} target 
   * @returns {CustomEditor | null}
   */
  static get(target) {
    const el = typeof target === 'string' ? document.querySelector(target) : target;
    return (el && CustomEditor._instances.get(el)) || null;
  }

  /**
   * Detaches and destroys an active editor instance on an element or selector
   * @param {string | HTMLElement} target 
   * @returns {boolean}
   */
  static detach(target) {
    const instance = CustomEditor.get(target);
    if (instance) {
      instance.destroy();
      return true;
    }
    return false;
  }

  /**
   * Destroys all active editor instances
   */
  static destroyAll() {
    for (const instance of Array.from(CustomEditor._instances.values())) {
      instance.destroy();
    }
    CustomEditor._instances.clear();
  }

  /**
   * Auto-initializes all textareas matching the selector
   * @param {string} [selector='[data-jbd-editor], textarea.jbd-editor'] 
   * @param {Object} [defaultOptions={}] 
   * @returns {CustomEditor[]}
   */
  static initAll(selector = '[data-jbd-editor], [data-jal-editor], textarea.jbd-editor, textarea.jal-editor', defaultOptions = {}) {
    if (typeof document === 'undefined') return [];
    let elements = [];
    if (selector instanceof HTMLElement) {
      elements = [selector];
    } else if (selector instanceof NodeList || Array.isArray(selector)) {
      elements = Array.from(selector);
    } else if (typeof selector === 'string') {
      elements = Array.from(document.querySelectorAll(selector));
    }
    const instances = [];
    elements.forEach(el => {
      if (!CustomEditor._instances.has(el) && !el.hasAttribute('data-jbd-initialized') && !el.hasAttribute('data-jal-initialized')) {
        instances.push(CustomEditor.attach(el, defaultOptions));
      }
    });
    return instances;
  }

  /**
   * Alias for initAll
   * @param {string} [selector] 
   * @param {Object} [options] 
   * @returns {CustomEditor[]}
   */
  static init(selector, options) {
    return CustomEditor.initAll(selector, options);
  }

  /**
   * Dynamically loads the editor CSS stylesheet if not already present
   * @param {string} [href='css/editor.css'] 
   */
  static loadCSS(href = 'css/editor.css') {
    if (typeof document === 'undefined') return;
    if (document.querySelector(`link[href="${href}"]`)) return;
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = href;
    document.head.appendChild(link);
  }

  /**
   * @param {HTMLTextAreaElement | HTMLInputElement} targetElement 
   * @param {Object} options 
   */
  constructor(targetElement, options = {}) {
    this.target = targetElement;

    // Read declarative data attributes from the target textarea for zero-JS configuration
    const dataToolbar = targetElement.getAttribute('data-jbd-toolbar') || targetElement.getAttribute('data-jal-toolbar') || targetElement.getAttribute('data-toolbar');
    const dataInlineToolbar = targetElement.getAttribute('data-jbd-inline-toolbar') || targetElement.getAttribute('data-jal-inline-toolbar') || targetElement.getAttribute('data-inline-toolbar');
    const dataHeight = targetElement.getAttribute('data-jbd-height') || targetElement.getAttribute('data-jal-height') || targetElement.getAttribute('data-height');
    const dataPlaceholder = targetElement.getAttribute('data-jbd-placeholder') || targetElement.getAttribute('data-jal-placeholder') || targetElement.getAttribute('placeholder');
    const dataAutoSave = targetElement.getAttribute('data-jbd-autosave') || targetElement.getAttribute('data-jal-autosave') || targetElement.getAttribute('data-autosave');
    const dataStatusAttr = targetElement.getAttribute('data-jbd-status') || targetElement.getAttribute('data-jal-status');
    const dataShowStatus = dataStatusAttr !== null ? dataStatusAttr !== 'false' : undefined;
    const dataCleanPasteAttr = targetElement.getAttribute('data-jbd-clean-paste') || targetElement.getAttribute('data-clean-paste');
    const dataCleanPaste = dataCleanPasteAttr !== null ? dataCleanPasteAttr !== 'false' : undefined;

    let toolbarConfig = options.toolbar !== undefined ? options.toolbar : dataToolbar;
    const presets = CustomEditor.TOOLBAR_PRESETS || {
      basic: JBD_BASIC_TOOLBAR,
      minimal: JBD_MINIMAL_TOOLBAR,
      subpage: JBD_SUBPAGE_TOOLBAR,
      article: JBD_ARTICLE_TOOLBAR,
      full: JBD_FULL_TOOLBAR
    };

    if (typeof toolbarConfig === 'string') {
      toolbarConfig = presets[toolbarConfig] || JBD_FULL_TOOLBAR;
    } else if (toolbarConfig === false) {
      toolbarConfig = false;
    } else if (!toolbarConfig) {
      toolbarConfig = presets.full || JBD_FULL_TOOLBAR;
    }

    let inlineToolbarConfig = options.inlineToolbar !== undefined ? options.inlineToolbar : (dataInlineToolbar !== null ? dataInlineToolbar : false);
    if (inlineToolbarConfig === 'true' || inlineToolbarConfig === true) {
      inlineToolbarConfig = JBD_DEFAULT_INLINE_TOOLBAR;
    } else if (typeof inlineToolbarConfig === 'string' && inlineToolbarConfig !== 'false') {
      try {
        const parsed = JSON.parse(inlineToolbarConfig);
        inlineToolbarConfig = Array.isArray(parsed) ? parsed : JBD_DEFAULT_INLINE_TOOLBAR;
      } catch {
        inlineToolbarConfig = JBD_DEFAULT_INLINE_TOOLBAR;
      }
    } else if (!Array.isArray(inlineToolbarConfig)) {
      inlineToolbarConfig = false;
    }

    this.options = {
      placeholder: options.placeholder || dataPlaceholder || 'Type your content here...',
      height: options.height || dataHeight || '340px',
      toolbar: toolbarConfig,
      inlineToolbar: inlineToolbarConfig,
      autoSaveKey: options.autoSaveKey || dataAutoSave || null,
      sanitizePaste: options.sanitizePaste !== false,
      cleanPaste: options.cleanPaste !== undefined ? options.cleanPaste !== false : (dataCleanPaste !== undefined ? dataCleanPaste : true),
      cleanPasteOptions: options.cleanPasteOptions || {},
      showStatusBar: options.showStatusBar !== undefined ? options.showStatusBar : (dataShowStatus !== undefined ? dataShowStatus : true),
      ...options
    };
    this.options.toolbar = toolbarConfig;
    this.options.inlineToolbar = inlineToolbarConfig;

    this._listeners = {};
    CustomEditor._instances.set(this.target, this);
    this.target.setAttribute('data-jbd-initialized', 'true');

    this.isSourceMode = false;
    this.isMaximized = false;
    this.savedSelectionRange = null;

    // Managers
    this.history = new HistoryManager(60);
    this.autoSaver = null;

    // Build DOM
    this.initDOM();
    this.initEvents();
    this.initContent();

    // AutoSave
    if (this.options.autoSaveKey) {
      this.initAutoSave();
    }

    // Initial state record
    this.history.record(this.getHTML(), true);
    this.updateStats();

    this.emit('ready', this);
    if (typeof this.options.onReady === 'function') {
      this.options.onReady(this);
    }
  }

  initDOM() {
    this.target.style.display = 'none';

    this.wrapper = createElement('div', {
      className: 'jbd-editor-wrapper',
      style: { minHeight: this.options.height }
    });

    // Toolbar
    if (this.options.toolbar) {
      this.toolbar = new Toolbar(this, this.options.toolbar);
      this.wrapper.appendChild(this.toolbar.element);
    } else {
      this.toolbar = null;
    }

    // Inline Toolbar (Floating / Bubble Toolbar)
    if (this.options.inlineToolbar) {
      this.inlineToolbar = new InlineToolbar(this, this.options.inlineToolbar);
    } else {
      this.inlineToolbar = null;
    }

    // Determine accessible name from target textarea or associated label
    let ariaLabel = this.options.ariaLabel || null;
    let ariaLabelledBy = this.options.ariaLabelledBy || null;

    if (!ariaLabel && !ariaLabelledBy) {
      if (this.target.getAttribute('aria-labelledby')) {
        ariaLabelledBy = this.target.getAttribute('aria-labelledby');
      } else if (this.target.id) {
        const labelEl = document.querySelector(`label[for="${this.target.id}"]`);
        if (labelEl) {
          if (!labelEl.id) {
            labelEl.id = `jbd-label-${Date.now()}`;
          }
          ariaLabelledBy = labelEl.id;
        }
      } else {
        const parentLabel = this.target.closest('label');
        if (parentLabel) {
          if (!parentLabel.id) {
            parentLabel.id = `jbd-label-${Date.now()}`;
          }
          ariaLabelledBy = parentLabel.id;
        }
      }

      if (!ariaLabelledBy && this.target.getAttribute('aria-label')) {
        ariaLabel = this.target.getAttribute('aria-label');
      }
    }

    const isRequired = this.target.required || this.target.getAttribute('aria-required') === 'true';
    const describedBy = this.target.getAttribute('aria-describedby');

    // Content Editable Area
    const contentAttrs = {
      className: 'jbd-editor-content',
      contenteditable: 'true',
      role: 'textbox',
      'aria-multiline': 'true',
      'data-placeholder': this.options.placeholder,
      style: { minHeight: this.options.height }
    };

    if (ariaLabelledBy) {
      contentAttrs['aria-labelledby'] = ariaLabelledBy;
    } else {
      contentAttrs['aria-label'] = ariaLabel || 'Rich text editor content';
    }

    if (isRequired) {
      contentAttrs['aria-required'] = 'true';
    }

    if (describedBy) {
      contentAttrs['aria-describedby'] = describedBy;
    }

    this.contentArea = createElement('div', contentAttrs);
    this.wrapper.appendChild(this.contentArea);

    // Source Code Area
    const sourceAttrs = {
      className: 'jbd-editor-source',
      style: { minHeight: this.options.height, display: 'none' },
      'aria-label': ariaLabel ? `${ariaLabel} (HTML source)` : 'HTML source code view'
    };
    if (isRequired) {
      sourceAttrs['aria-required'] = 'true';
    }
    this.sourceArea = createElement('textarea', sourceAttrs);
    this.wrapper.appendChild(this.sourceArea);

    // Status Bar
    if (this.options.showStatusBar) {
      this.statusBar = createElement('div', { className: 'jbd-editor-statusbar' });
      this.statusStats = createElement('div', {
        className: 'jbd-editor-stats',
        role: 'status',
        'aria-live': 'polite'
      });
      this.statusDraft = createElement('div', {
        className: 'jbd-editor-draft-indicator',
        role: 'status',
        'aria-live': 'polite'
      });

      this.statusBar.appendChild(this.statusStats);
      this.statusBar.appendChild(this.statusDraft);
      this.wrapper.appendChild(this.statusBar);
    }

    if (this.target.parentNode) {
      this.target.parentNode.insertBefore(this.wrapper, this.target.nextSibling);
    }
  }

  initContent() {
    let initialHTML = this.target.value || '';

    if (this.options.autoSaveKey) {
      const draft = StorageManager.loadDraft(this.options.autoSaveKey);
      if (draft && draft.content && draft.content !== initialHTML) {
        initialHTML = draft.content;
        this.showDraftRestoredNotice(draft.timestamp);
      }
    }

    this.setHTML(initialHTML);
    this.syncToTarget();
  }

  initEvents() {
    this._handleInput = () => {
      this.syncToTarget();
      this.history.record(this.getHTML());
      if (this.autoSaver) this.autoSaver.trigger();
      this.updateStats();
      if (this.toolbar) this.toolbar.updateActiveStates();
      if (this.inlineToolbar) this.inlineToolbar.position();
    };

    this._handleSelectionChange = () => {
      if (isSelectionInside(this.contentArea)) {
        this.savedSelectionRange = saveSelection(this.contentArea);
        if (this.toolbar) this.toolbar.updateActiveStates();
        if (this.inlineToolbar) this.inlineToolbar.position();
      } else {
        if (this.inlineToolbar) this.inlineToolbar.hide();
      }
    };

    this._handleKeyDown = (e) => this.onKeyDown(e);
    this._handlePaste = (e) => this.onPaste(e);
    this._handleClick = (e) => {
      const addFaqBtn = e.target.closest('[data-jbd-faq-add]');
      if (addFaqBtn && this.contentArea.contains(addFaqBtn)) {
        e.preventDefault();
        e.stopPropagation();
        const faqBlock = addFaqBtn.closest('.jbd-faq-block');
        this.addFaqItem(faqBlock);
        return;
      }

      const addTimelineBtn = e.target.closest('[data-jbd-timeline-add]');
      if (addTimelineBtn && this.contentArea.contains(addTimelineBtn)) {
        e.preventDefault();
        e.stopPropagation();
        const timelineContainer = addTimelineBtn.closest('.jbd-timeline-container') || addTimelineBtn.closest('.jbd-template');
        this.addTimelineStep(timelineContainer);
        return;
      }
    };

    this.contentArea.addEventListener('input', this._handleInput);
    this.contentArea.addEventListener('keydown', this._handleKeyDown);
    this.contentArea.addEventListener('paste', this._handlePaste);
    this.contentArea.addEventListener('click', this._handleClick);

    document.addEventListener('selectionchange', this._handleSelectionChange);

    this.contentArea.addEventListener('focus', () => {
      this.wrapper.classList.add('jbd-editor-focused');
      this.emit('focus', this);
      if (typeof this.options.onFocus === 'function') this.options.onFocus(this);
    });
    this.contentArea.addEventListener('blur', () => {
      this.wrapper.classList.remove('jbd-editor-focused');
      this.emit('blur', this);
      if (typeof this.options.onBlur === 'function') this.options.onBlur(this);
    });

    this.sourceArea.addEventListener('input', () => {
      this.contentArea.innerHTML = this.sourceArea.value;
      this.syncToTarget();
      this.updateStats();
    });

    this.sourceArea.addEventListener('keydown', (e) => {
      if (e.key === 'Tab') {
        e.preventDefault();
        const start = this.sourceArea.selectionStart;
        const end = this.sourceArea.selectionEnd;
        const val = this.sourceArea.value;
        this.sourceArea.value = val.substring(0, start) + '  ' + val.substring(end);
        this.sourceArea.selectionStart = this.sourceArea.selectionEnd = start + 2;
        this.contentArea.innerHTML = this.sourceArea.value;
        this.syncToTarget();
        this.updateStats();
      }
    });

    if (this.target.form) {
      this._handleFormSubmit = () => {
        this.syncToTarget();
      };
      this.target.form.addEventListener('submit', this._handleFormSubmit);

      this._handleFormReset = () => {
        setTimeout(() => {
          this.setHTML(this.target.defaultValue || '');
          this.history.clear();
          this.updateStats();
        }, 0);
      };
      this.target.form.addEventListener('reset', this._handleFormReset);
    }
  }

  initAutoSave() {
    this.autoSaver = StorageManager.createAutoSaver(
      this.options.autoSaveKey,
      () => this.getHTML(),
      1000,
      (status) => this.updateDraftStatus(status)
    );
  }

  syncToTarget() {
    const html = this.getHTML();
    this.target.value = html;
    this.target.dispatchEvent(new Event('input', { bubbles: true }));
    this.target.dispatchEvent(new Event('change', { bubbles: true }));
    this.emit('change', html, this.getText());
    if (typeof this.options.onChange === 'function') {
      this.options.onChange(html, this.getText());
    }
  }

  onKeyDown(e) {
    // Alt + F10: Standard accessible shortcut to focus toolbar or inline toolbar
    if (e.altKey && (e.key === 'F10' || e.keyCode === 121)) {
      e.preventDefault();
      if (this.inlineToolbar && this.inlineToolbar.isVisible) {
        this.inlineToolbar.focus();
      } else if (this.toolbar) {
        this.toolbar.focus();
      }
      return;
    }

    const isCtrl = e.ctrlKey || e.metaKey;

    if (isCtrl) {
      const key = e.key.toLowerCase();
      if (key === 'b') {
        e.preventDefault();
        this.execCommand('bold');
      } else if (key === 'i') {
        e.preventDefault();
        this.execCommand('italic');
      } else if (key === 'u') {
        e.preventDefault();
        this.execCommand('underline');
      } else if (key === 'z') {
        e.preventDefault();
        if (e.shiftKey) {
          this.redo();
        } else {
          this.undo();
        }
      } else if (key === 'y') {
        e.preventDefault();
        this.redo();
      } else if (key === 'f') {
        e.preventDefault();
        this.openFindReplaceModal();
      }
    } else if (e.shiftKey && e.key === 'Enter') {
        const sel = window.getSelection();
        if (sel && sel.rangeCount > 0) {
          let node = sel.getRangeAt(0).startContainer;
          if (node.nodeType === Node.TEXT_NODE) node = node.parentNode;
          const insideBlock = node && (node.closest('.jbd-template') || node.closest('.jbd-grid') || node.closest('.jbd-callout') || node.closest('.jbd-panel') || node.closest('.jbd-hero') || node.closest('table') || node.closest('blockquote') || node.closest('aside') || node.closest('section'));
          if (insideBlock) {
            e.preventDefault();
            this.exitBlock();
          }
        }
      } else if (e.key === 'Escape') {
      if (this.inlineToolbar && this.inlineToolbar.isVisible) {
        this.inlineToolbar.hide();
      } else if (this.isMaximized) {
        this.toggleMaximize();
      }
    }
  }

  onPaste(e) {
    if (!this.options.sanitizePaste) return;
    e.preventDefault();

    const clipboardData = e.clipboardData || window.clipboardData;
    let pasteHTML = clipboardData.getData('text/html');
    const pasteText = clipboardData.getData('text/plain');

    if (pasteHTML) {
      pasteHTML = sanitizeHTML(pasteHTML);
      if (this.options.cleanPaste !== false) {
        pasteHTML = cleanDocumentHTML(pasteHTML, this.options.cleanPasteOptions || {});
      }
      document.execCommand('insertHTML', false, pasteHTML);
    } else if (pasteText) {
      document.execCommand('insertText', false, pasteText);
    }

    this._handleInput();
  }

  execCommand(command, value = null) {
    if (this.isSourceMode) return;
    this.contentArea.focus();

    if (this.savedSelectionRange) {
      restoreSelection(this.savedSelectionRange);
    }

    document.execCommand(command, false, value);
    this._handleInput();
  }

  /**
   * Inserts arbitrary HTML at current cursor / selection point
   * @param {string} html 
   */
  insertHTML(html) {
    if (this.isSourceMode) {
      insertAtCursor(this.sourceArea, html);
      this._handleInput();
      return;
    }
    this.contentArea.focus();
    if (this.savedSelectionRange) {
      restoreSelection(this.savedSelectionRange);
    }
    document.execCommand('insertHTML', false, html);
    this._handleInput();
  }

  /**
   * Cleans and removes element styles and classes from the entire editor document.
   * Preserves semantic elements (headings, bold, italic, lists, links, tables)
   * while eliminating foreign inline styles, classes, and document artifacts.
   * @param {Object} [options]
   * @returns {string} The cleaned HTML
   */
  /**
   * Opens dialog to insert or edit an accessible Named Anchor Bookmark
   */
  openAnchorModal() {
    if (this.isSourceMode) return;
    const currentA = getClosestBlock(this.contentArea, 'a');
    const isAnchorMarker = currentA && (currentA.hasAttribute('name') || currentA.classList.contains('jbd-anchor-marker'));
    const currentName = currentA ? (currentA.getAttribute('name') || currentA.getAttribute('id') || '') : '';
    const currentText = getSelectedText() || (currentA ? currentA.textContent : '');

    Dialog.openAnchorDialog({
      currentName,
      currentText,
      onConfirm: ({ name, text }) => {
        this.contentArea.focus();
        if (this.savedSelectionRange) {
          restoreSelection(this.savedSelectionRange);
        }

        const markerLabel = text || `#${name}`;

        if (isAnchorMarker && currentA) {
          currentA.setAttribute('id', name);
          currentA.setAttribute('name', name);
          currentA.className = 'jbd-anchor-marker';
          currentA.textContent = markerLabel;
          currentA.title = `Anchor: #${name}`;
        } else {
          const anchorHTML = `<a id="${name}" name="${name}" class="jbd-anchor-marker" title="Anchor: #${name}">${markerLabel}</a>`;
          insertAtCursor(this.contentArea, anchorHTML, this.savedSelectionRange);
        }

        this._handleInput();
      }
    });
  }

  /**
   * Breaks out of the current nested container (callout, grid, table, card)
   * and inserts a normal paragraph directly beneath it.
   */
  exitBlock() {
    if (this.isSourceMode) return;
    this.contentArea.focus();

    const sel = window.getSelection();
    let targetBlock = null;

    if (sel && sel.rangeCount > 0) {
      let node = sel.getRangeAt(0).startContainer;
      if (node.nodeType === Node.TEXT_NODE) node = node.parentNode;
      while (node && node !== this.contentArea) {
        if (node.classList && (node.classList.contains('jbd-template') || node.classList.contains('jbd-grid') || node.classList.contains('jbd-callout') || node.classList.contains('jbd-panel') || node.classList.contains('jbd-hero') || node.classList.contains('jbd-faq-block') || node.classList.contains('jbd-timeline-container') || node.classList.contains('jbd-quote-card') || node.classList.contains('jbd-article') || node.classList.contains('cms-table') || node.tagName.toLowerCase() === 'table' || node.tagName.toLowerCase() === 'blockquote' || node.tagName.toLowerCase() === 'aside' || node.tagName.toLowerCase() === 'section')) {
          targetBlock = node;
          break;
        }
        node = node.parentNode;
      }
    }

    const p = document.createElement('p');
    p.innerHTML = '<br>';

    if (targetBlock && targetBlock.parentNode) {
      targetBlock.parentNode.insertBefore(p, targetBlock.nextSibling);
    } else {
      this.contentArea.appendChild(p);
    }

    const newRange = document.createRange();
    newRange.setStart(p, 0);
    newRange.collapse(true);
    sel.removeAllRanges();
    sel.addRange(newRange);
    this.savedSelectionRange = newRange.cloneRange();

    this._handleInput();
  }

  validateA11y(html) {
    return A11yValidator.validate(html || this.getHTML());
  }

  checkA11y() {
    return this.validateA11y();
  }

  cleanDocument(options = {}) {
    if (this.isSourceMode) return this.getHTML();
    const currentHTML = this.getHTML();
    const opts = Object.assign({}, this.options.cleanPasteOptions, options);
    const cleanedHTML = cleanDocumentHTML(currentHTML, opts);
    if (currentHTML !== cleanedHTML) {
      this.setHTML(cleanedHTML);
      this._handleInput();
      this.history.record(this.getHTML());
    }
    return cleanedHTML;
  }

  /**
   * Cleans and removes element styles and classes from the active selection.
   * If selection is collapsed, cleans the entire document.
   * @param {Object} [options]
   */
  cleanSelection(options = {}) {
    if (this.isSourceMode) return;
    const selection = window.getSelection();
    if (!selection || selection.rangeCount === 0 || selection.isCollapsed) {
      this.cleanDocument(options);
      return;
    }

    const range = selection.getRangeAt(0);
    if (!this.contentArea.contains(range.commonAncestorContainer)) return;

    const fragment = range.cloneContents();
    const temp = document.createElement('div');
    temp.appendChild(fragment);

    const opts = Object.assign({}, this.options.cleanPasteOptions, options);
    const cleanedHTML = cleanDocumentHTML(temp.innerHTML, opts);
    this.contentArea.focus();
    document.execCommand('insertHTML', false, cleanedHTML);
    this._handleInput();
  }

  /**
   * Universal cleanup tool: cleans selection if active, otherwise cleans whole document.
   * @param {Object} [options]
   */
  cleanUp(options = {}) {
    const selection = window.getSelection();
    if (selection && !selection.isCollapsed && isSelectionInside(this.contentArea)) {
      this.cleanSelection(options);
    } else {
      this.cleanDocument(options);
    }
  }

  clearFormatting() {
    if (this.isSourceMode) return;
    this.cleanSelection();
    this.execCommand('removeFormat');
    document.execCommand('formatBlock', false, '<p>');
    this._handleInput();
  }

  openLinkModal() {
    if (this.isSourceMode) return;
    const currentAnchor = getClosestBlock(this.contentArea, 'a');
    const currentUrl = currentAnchor ? (currentAnchor.getAttribute('href') || '') : '';
    const currentText = getSelectedText() || (currentAnchor ? currentAnchor.textContent : '');
    const isBlank = currentAnchor ? currentAnchor.getAttribute('target') === '_blank' : false;
    const currentAria = currentAnchor ? (currentAnchor.getAttribute('aria-label') || '') : '';

    Dialog.openLinkDialog({
      currentUrl,
      currentText,
      targetBlank: isBlank,
      ariaLabel: currentAria,
      onConfirm: ({ url, text, blank, ada }) => {
        this.contentArea.focus();
        if (this.savedSelectionRange) {
          restoreSelection(this.savedSelectionRange);
        }

        // Determine file type tag (e.g. PDF, DOCX, XLSX, etc.)
        const extMatch = url.match(/\.(pdf|docx?|xlsx?|pptx?|csv|zip|txt)($|[?#])/i);
        const extTag = extMatch ? ` (${extMatch[1].toUpperCase()})` : '';

        const displayText = text || (currentAnchor ? currentAnchor.textContent : url);
        // Clean any existing redundant suffixes
        const cleanLabelText = (displayText || url).replace(/\s*\((?:opens in a new (?:tab|window)|PDF|DOCX?|XLSX?)\)/gi, '').trim();

        let ariaLabel = '';
        if (blank && ada) {
          ariaLabel = `${cleanLabelText || url}${extTag} (opens in a new tab)`;
        } else if (ada) {
          ariaLabel = `${cleanLabelText || url}${extTag}`;
        }

        if (currentAnchor) {
          currentAnchor.setAttribute('href', url);
          if (text) currentAnchor.textContent = text;
          if (blank) {
            currentAnchor.setAttribute('target', '_blank');
            currentAnchor.setAttribute('rel', 'noopener noreferrer');
            if (ariaLabel) {
              currentAnchor.setAttribute('aria-label', ariaLabel);
              currentAnchor.setAttribute('title', ariaLabel);
            } else {
              currentAnchor.removeAttribute('aria-label');
              currentAnchor.removeAttribute('title');
            }
          } else {
            currentAnchor.removeAttribute('target');
            currentAnchor.removeAttribute('rel');
            const oldAria = currentAnchor.getAttribute('aria-label') || '';
            if (oldAria.includes('opens in a new')) {
              currentAnchor.removeAttribute('aria-label');
            }
            const oldTitle = currentAnchor.getAttribute('title') || '';
            if (oldTitle.includes('opens in a new')) {
              currentAnchor.removeAttribute('title');
            }
          }
        } else {
          const targetAttrs = blank ? 'target="_blank" rel="noopener noreferrer"' : '';
          const ariaAttrs = (blank && ariaLabel) ? ` aria-label="${escapeHTML(ariaLabel)}" title="${escapeHTML(ariaLabel)}"` : '';
          const space = (targetAttrs || ariaAttrs) ? ' ' : '';
          const anchorHTML = `<a href="${url}"${space}${targetAttrs}${ariaAttrs}>${displayText}</a>`;
          insertAtCursor(this.contentArea, anchorHTML, this.savedSelectionRange);
        }

        this._handleInput();
      }
    });
  }

openImageModal() {
    if (this.isSourceMode) return;
    Dialog.openImageDialog({
      onConfirm: ({ src, alt, caption, align, width }) => {
        let alignClass = '';
        if (align === 'left') alignClass = 'jbd-image-left';
        if (align === 'center') alignClass = 'jbd-image-center';
        if (align === 'right') alignClass = 'jbd-image-right';

        let html = '';
        if (caption) {
          html = `<figure class="jbd-image ${alignClass}" style="max-width: ${width};">
            <img src="${src}" alt="${alt || caption}" style="width: 100%; height: auto;" />
            <figcaption>${caption}</figcaption>
          </figure>`;
        } else {
          html = `<div class="jbd-image ${alignClass}" style="max-width: ${width};">
            <img src="${src}" alt="${alt}" style="width: 100%; height: auto;" />
          </div>`;
        }

        insertAtCursor(this.contentArea, html, this.savedSelectionRange);
        this._handleInput();
      }
    });
  }

  openTableModal() {
    if (this.isSourceMode) return;
    Dialog.openTableDialog({
      onConfirm: (options) => {
        const table = TableManager.createTable(options);
        insertAtCursor(this.contentArea, table, this.savedSelectionRange);
        this._handleInput();
      }
    });
  }

  openSpecialCharModal() {
    if (this.isSourceMode) return;
    Dialog.openSpecialCharsDialog({
      onSelect: (ch) => {
        insertAtCursor(this.contentArea, ch, this.savedSelectionRange);
        this._handleInput();
      }
    });
  }

  openTemplateModal() {
    if (this.isSourceMode) return;
    const templates = this.options.templates || Dialog.DEFAULT_BLOCK_TEMPLATES;
    Dialog.openTemplateDialog({
      templates,
      onSelect: (html) => {
        this.insertTemplate(html);
      }
    });
  }

  /**
   * Inserts an HTML block template at current cursor position with clean block isolation
   * @param {string} html 
   */
  insertTemplate(html) {
    if (this.isSourceMode) return;
    this.contentArea.focus();
    if (this.savedSelectionRange) {
      restoreSelection(this.savedSelectionRange);
    }

    const temp = document.createElement('div');
    temp.innerHTML = html.trim();

    const fragment = document.createDocumentFragment();
    while (temp.firstChild) {
      fragment.appendChild(temp.firstChild);
    }

    const selection = window.getSelection();
    if (selection && selection.rangeCount > 0) {
      let range = selection.getRangeAt(0);
      if (this.contentArea.contains(range.commonAncestorContainer)) {
        let currentBlock = range.startContainer;
        if (currentBlock.nodeType === Node.TEXT_NODE) {
          currentBlock = currentBlock.parentNode;
        }
        while (currentBlock && currentBlock.parentNode !== this.contentArea && currentBlock !== this.contentArea) {
          currentBlock = currentBlock.parentNode;
        }

        if (currentBlock && currentBlock !== this.contentArea) {
          const text = currentBlock.textContent.trim();
          if (text === '' && (!currentBlock.querySelector('img, table, iframe') || currentBlock.tagName === 'P')) {
            currentBlock.parentNode.insertBefore(fragment, currentBlock);
            currentBlock.remove();
          } else {
            if (currentBlock.nextSibling) {
              currentBlock.parentNode.insertBefore(fragment, currentBlock.nextSibling);
            } else {
              currentBlock.parentNode.appendChild(fragment);
            }
          }
        } else {
          range.deleteContents();
          range.insertNode(fragment);
        }
      } else {
        this.contentArea.appendChild(fragment);
      }
    } else {
      this.contentArea.appendChild(fragment);
    }

    const lastChild = this.contentArea.lastElementChild;
    if (lastChild && lastChild.classList && lastChild.classList.contains('jbd-template')) {
      const p = document.createElement('p');
      p.innerHTML = '<br>';
      this.contentArea.appendChild(p);
    }

    this._handleInput();
  }

  openFindReplaceModal() {
    Dialog.openFindReplaceDialog({
      onFind: (findText, matchCase) => {
        if (!findText) return;
        this.contentArea.focus();
        if (window.find) {
          window.find(findText, matchCase, false, true, false, false, false);
        } else {
          alert('Search is not supported in this browser environment.');
        }
      },
      onReplace: (findText, replaceText) => {
        const sel = window.getSelection();
        if (sel && sel.toString().toLowerCase() === findText.toLowerCase()) {
          document.execCommand('insertText', false, replaceText);
          this._handleInput();
        }
      },
      onReplaceAll: (findText, replaceText, matchCase) => {
        if (!findText) return;
        const flags = matchCase ? 'g' : 'gi';
        const escaped = findText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        const regex = new RegExp(escaped, flags);
        this.setHTML(this.getHTML().replace(regex, replaceText));
        this._handleInput();
      }
    });
  }

  // --- Table Operations ---

  tableAddRowAbove() {
    TableManager.addRowAbove(TableManager.getActiveCell(this.contentArea));
    this._handleInput();
  }

  tableAddRowBelow() {
    TableManager.addRowBelow(TableManager.getActiveCell(this.contentArea));
    this._handleInput();
  }

  tableAddColLeft() {
    TableManager.addColLeft(TableManager.getActiveCell(this.contentArea));
    this._handleInput();
  }

  tableAddColRight() {
    TableManager.addColRight(TableManager.getActiveCell(this.contentArea));
    this._handleInput();
  }

  tableDeleteRow() {
    TableManager.deleteRow(TableManager.getActiveCell(this.contentArea));
    this._handleInput();
  }

  tableDeleteCol() {
    TableManager.deleteCol(TableManager.getActiveCell(this.contentArea));
    this._handleInput();
  }

  tableDeleteTable() {
    TableManager.deleteTable(TableManager.getActiveCell(this.contentArea));
    this._handleInput();
  }

  // --- Block Template Interactive Helpers ---

  /**
   * Appends a new question and answer item to the specified or closest FAQ block
   * @param {HTMLElement} [faqBlockEl] 
   */
  addFaqItem(faqBlockEl) {
    if (this.isSourceMode) return;
    const block = faqBlockEl || this.contentArea.querySelector('.jbd-faq-block');
    if (!block) return;

    const newItem = document.createElement('div');
    newItem.className = 'jbd-faq-item';
    newItem.innerHTML = `
      <div class="jbd-faq-header">
        <span class="jbd-faq-badge" aria-hidden="true">Q:</span>
        <h4 class="jbd-faq-question">New Question Title</h4>
      </div>
      <div class="jbd-faq-answer">
        <p>Enter your answer explanation here.</p>
      </div>
    `;

    const actions = block.querySelector('.jbd-faq-actions');
    if (actions) {
      block.insertBefore(newItem, actions);
    } else {
      block.appendChild(newItem);
    }

    this._handleInput();

    // Focus the new question title for quick editing
    const qHeading = newItem.querySelector('.jbd-faq-question');
    if (qHeading) {
      const sel = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(qHeading);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
      qHeading.focus();
    }
  }

  /**
   * Appends a new step to the specified or closest timeline component
   * @param {HTMLElement} [timelineContainerEl] 
   */
  addTimelineStep(timelineContainerEl) {
    if (this.isSourceMode) return;
    const container = timelineContainerEl || this.contentArea.querySelector('.jbd-timeline-container');
    if (!container) return;

    const ol = container.querySelector('.jbd-timeline') || container.querySelector('ol');
    if (!ol) return;

    const stepCount = ol.querySelectorAll('.jbd-step').length + 1;
    const newStep = document.createElement('li');
    newStep.className = 'jbd-step';
    newStep.innerHTML = `
      <div class="jbd-step-badge" aria-hidden="true">${stepCount}</div>
      <div class="jbd-step-body">
        <strong class="jbd-step-title">Step ${stepCount}: New Step Title</strong>
        <p>Enter step description here.</p>
      </div>
    `;

    ol.appendChild(newStep);
    this._handleInput();

    // Focus the new step title for immediate editing
    const titleEl = newStep.querySelector('.jbd-step-title');
    if (titleEl) {
      const sel = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(titleEl);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
      titleEl.focus();
    }
  }

  // --- Maximize / Fullscreen ---

  toggleMaximize() {
    this.isMaximized = !this.isMaximized;
    this.wrapper.classList.toggle('jbd-editor-maximized', this.isMaximized);
    document.body.classList.toggle('jbd-noscroll', this.isMaximized);
    if (this.toolbar) this.toolbar.updateActiveStates();
  }

  // --- Source View Toggle ---

  toggleSourceView() {
    this.isSourceMode = !this.isSourceMode;

    if (this.isSourceMode) {
      if (this.inlineToolbar) this.inlineToolbar.hide();
      this.sourceArea.value = formatHTML(this.getHTML());
      this.contentArea.style.display = 'none';
      this.sourceArea.style.display = 'block';
      this.sourceArea.focus();
    } else {
      this.setHTML(this.sourceArea.value);
      this.sourceArea.style.display = 'none';
      this.contentArea.style.display = 'block';
      this.contentArea.focus();
    }

    if (this.toolbar) this.toolbar.updateActiveStates();
  }

  /**
   * Cleans and beautifies HTML source code
   */
  formatSource() {
    if (this.isSourceMode) {
      this.sourceArea.value = formatHTML(this.sourceArea.value);
      this.contentArea.innerHTML = this.sourceArea.value;
    } else {
      this.setHTML(formatHTML(this.getHTML()));
    }
    this.syncToTarget();
  }

  // --- History (Undo / Redo) ---

  undo() {
    if (this.isSourceMode) return;
    const previous = this.history.undo(this.getHTML());
    if (previous !== null) {
      this.setHTML(previous);
      this.syncToTarget();
      this.updateStats();
      if (this.toolbar) this.toolbar.updateActiveStates();
    }
  }

  redo() {
    if (this.isSourceMode) return;
    const next = this.history.redo(this.getHTML());
    if (next !== null) {
      this.setHTML(next);
      this.syncToTarget();
      this.updateStats();
      if (this.toolbar) this.toolbar.updateActiveStates();
    }
  }

  // --- Public APIs ---

  getHTML() {
    return this.contentArea.innerHTML;
  }

  setHTML(html) {
    this.contentArea.innerHTML = html;
    this.sourceArea.value = html;
  }

  getText() {
    return this.contentArea.innerText || this.contentArea.textContent || '';
  }

  clear() {
    this.setHTML('');
    this.syncToTarget();
    this.history.record('', true);
    if (this.options.autoSaveKey) {
      StorageManager.clearDraft(this.options.autoSaveKey);
    }
    this.updateStats();
  }

  focus() {
    if (this.isSourceMode) {
      this.sourceArea.focus();
    } else {
      this.contentArea.focus();
    }
  }

  updateStats() {
    if (!this.options.showStatusBar || !this.statusStats) return;
    const text = this.getText().trim();
    const words = text ? text.split(/\s+/).length : 0;
    const chars = text.length;

    this.statusStats.textContent = `${words} words · ${chars} characters`;
  }

  updateDraftStatus(status) {
    if (!this.statusDraft) return;
    if (status === 'saving') {
      this.statusDraft.textContent = 'Saving draft...';
      this.statusDraft.className = 'jbd-editor-draft-indicator saving';
    } else if (status === 'saved') {
      const now = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      this.statusDraft.textContent = `Draft saved at ${now}`;
      this.statusDraft.className = 'jbd-editor-draft-indicator saved';
    } else {
      this.statusDraft.textContent = '';
      this.statusDraft.className = 'jbd-editor-draft-indicator';
    }
  }

  showDraftRestoredNotice(timestamp) {
    if (!this.statusDraft) return;
    const timeStr = new Date(timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    this.statusDraft.textContent = `Restored draft from ${timeStr}`;
    this.statusDraft.className = 'jbd-editor-draft-indicator restored';
    setTimeout(() => {
      this.statusDraft.textContent = '';
    }, 4000);
  }

  // --- Event Handling (Pub/Sub) ---
  /**
   * Subscribes to an editor lifecycle or content event ('change', 'focus', 'blur', 'ready', 'destroy')
   * @param {string} event 
   * @param {Function} callback 
   * @returns {CustomEditor}
   */
  on(event, callback) {
    if (!this._listeners) this._listeners = {};
    if (!this._listeners[event]) this._listeners[event] = [];
    this._listeners[event].push(callback);
    return this;
  }

  /**
   * Unsubscribes from an editor event
   * @param {string} event 
   * @param {Function} [callback] 
   * @returns {CustomEditor}
   */
  off(event, callback) {
    if (!this._listeners || !this._listeners[event]) return this;
    if (!callback) {
      delete this._listeners[event];
    } else {
      this._listeners[event] = this._listeners[event].filter(cb => cb !== callback);
    }
    return this;
  }

  /**
   * Dispatches an event to subscribed listeners
   * @param {string} event 
   * @param  {...any} args 
   */
  emit(event, ...args) {
    if (!this._listeners || !this._listeners[event]) return;
    this._listeners[event].forEach(cb => {
      try {
        cb.apply(this, args);
      } catch (err) {
        console.error(`JBDEditor error in "${event}" listener:`, err);
      }
    });
  }

  /**
   * Checks whether the editor content is empty or contains only whitespace/empty tags
   * @returns {boolean}
   */
  isEmpty() {
    const text = this.getText().trim();
    const hasMedia = !!this.contentArea.querySelector('img, table, iframe, hr');
    return text === '' && !hasMedia;
  }

  /**
   * Programmatically inserts arbitrary HTML at current cursor position
   * @param {string} html 
   */
  insertHTML(html) {
    if (this.isSourceMode) return;
    this.contentArea.focus();
    insertAtCursor(this.contentArea, html, this.savedSelectionRange);
    this._handleInput();
  }

  /**
   * Programmatically inserts plain text at current cursor position
   * @param {string} text 
   */
  insertText(text) {
    if (this.isSourceMode) return;
    this.contentArea.focus();
    document.execCommand('insertText', false, text);
    this._handleInput();
  }

  destroy() {
    if (this.autoSaver) this.autoSaver.cancel();

    this.contentArea.removeEventListener('input', this._handleInput);
    this.contentArea.removeEventListener('keydown', this._handleKeyDown);
    this.contentArea.removeEventListener('paste', this._handlePaste);
    if (this._handleClick) {
      this.contentArea.removeEventListener('click', this._handleClick);
    }
    document.removeEventListener('selectionchange', this._handleSelectionChange);

    if (this.target.form) {
      if (this._handleFormReset) {
        this.target.form.removeEventListener('reset', this._handleFormReset);
      }
      if (this._handleFormSubmit) {
        this.target.form.removeEventListener('submit', this._handleFormSubmit);
      }
    }

    if (this.isMaximized) {
      document.body.classList.remove('jbd-noscroll');
    }

    if (this.inlineToolbar) {
      this.inlineToolbar.destroy();
      this.inlineToolbar = null;
    }

    this.target.style.display = '';
    if (this.wrapper && this.wrapper.parentNode) {
      this.wrapper.parentNode.removeChild(this.wrapper);
    }

    CustomEditor._instances.delete(this.target);
    this.target.removeAttribute('data-jbd-initialized');
    this.emit('destroy', this);
    this._listeners = {};
  }
}

// Auto-initialize textareas with [data-jbd-editor] or class="jbd-editor" on DOMContentLoaded
if (typeof document !== 'undefined') {
  const bootAutoInit = () => {
    if (CustomEditor.autoInit !== false) {
      CustomEditor.initAll();
    }
  };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bootAutoInit);
  } else {
    bootAutoInit();
  }
}

export { CustomEditor as JBDEditor, CustomEditor as JByDesignEditor, CustomEditor as JalEditor, cleanDocumentHTML, cleanHTML };
export default CustomEditor;
