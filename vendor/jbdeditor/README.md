# JByDesign Editor (`jbdeditor`)

> **Attachable, Zero-Dependency, WCAG 2.2 Level AA Compliant Vanilla JavaScript Rich Text Editor.**
> 100% pure native browser JavaScript (ES modules and standalone bundle). Runs on `file:///` and HTTP/HTTPS without Node.js or build tools.

---

## ⚡ 1-Minute Quickstart

### Method 1: Zero-JS Declarative Integration (Automatic)
Simply include the stylesheet and script, then add `data-jbd-editor` to any `<textarea>`. `JBDEditor` will auto-initialize on page load with zero custom script:

```html
<!-- Include stylesheet and script -->
<link rel="stylesheet" href="css/editor.css">
<script src="src/jbdeditor.js"></script>

<!-- Just add data-jbd-editor to your form textarea -->
<form action="/save" method="POST">
  <textarea 
    data-jbd-editor 
    data-jbd-toolbar="basic" 
    data-jbd-height="360px" 
    data-jbd-placeholder="Write your article..."
    name="content"
  >Initial content</textarea>
  <button type="submit">Submit</button>
</form>
```

---

### Method 2: Standard 1-Line JavaScript (`JBDEditor.attach`)

```html
<link rel="stylesheet" href="css/editor.css">
<script src="src/jbdeditor.js"></script>

<textarea id="my-editor" name="content">Initial document...</textarea>

<script>
  const editor = JBDEditor.attach('#my-editor', {
    toolbar: 'basic',        // 'full' | 'basic' | 'minimal' | 'article'
    height: '380px',
    placeholder: 'Type your message...',
    autoSaveKey: 'my_draft', // LocalStorage draft recovery
    onChange: (html, text) => {
      console.log('Word count:', text.split(/\s+/).length);
    }
  });
</script>
```

---

### Method 3: ES Modules (Modern Modular Setup)

```javascript
import { JBDEditor } from './src/editor.js';

const editor = JBDEditor.attach('#my-textarea', {
  toolbar: 'article',
  height: '400px'
});
```

---

## 🛠️ Dynamic SPAs, HTMX, Alpine.js & Turbo

JBDEditor provides a global instance registry so you never get duplicate editors or memory leaks in dynamic pages:

```javascript
// 1. Initialize all textareas after AJAX / HTMX / Turbo swap
JBDEditor.initAll();

// 2. Retrieve an existing editor instance anytime
const editor = JBDEditor.get('#my-textarea');
console.log(editor.getHTML());

// 3. Cleanly detach / destroy when navigating away or unmounting components
JBDEditor.detach('#my-textarea');

// Or destroy all active editors at once:
JBDEditor.destroyAll();
```

---

## 🎛️ Toolbar Presets

Choose from built-in presets or supply an array of tool buttons:

| Preset | Description | Buttons Included |
| :--- | :--- | :--- |
| `'full'` *(Default)* | Enterprise rich text suite | Headings, inline formats, colors, align, lists, links, images, tables, templates, find/replace, undo/redo, source view, maximize |
| `'basic'` | Streamlined content editing | Headings, bold, italic, underline, clear format, clean up document, align, lists, link, table, templates, undo/redo, source view, maximize |
| `'minimal'` | Simple comments & notes | Bold, italic, underline, link, lists, undo/redo |
| `'article'` | Editorial journalism & publishing | Headings, text formatting, colors, alignments, media, block templates, find/replace, source view |
| `false` | Distraction-free clean canvas | No toolbar, purely keyboard shortcut driven |

```javascript
JBDEditor.attach('#textarea', { toolbar: 'article' });
```

---

## 🫧 Floating Inline Toolbar (Medium / Notion Style)

JBDEditor includes an optional floating selection toolbar that appears contextually over highlighted text:

```javascript
// Enable default inline bubble toolbar:
const editor = JBDEditor.attach('#my-textarea', {
  inlineToolbar: true
});

// Distraction-free setup (no fixed header toolbar, only floating bubble toolbar):
// Default menu: Paragraph Format, Bold, Italic, Underline, Alignments, Lists, Indent/Outdent, Link/Unlink
const editor = JBDEditor.attach('#my-textarea', {
  toolbar: false,
  inlineToolbar: true
});

// Custom inline button set:
const editor = JBDEditor.attach('#my-textarea', {
  inlineToolbar: ['formatBlock', 'bold', 'italic', 'underline', 'alignCenter', 'link', 'unlink']
});
```

---

## 📝 Declarative HTML Attributes

When using declarative auto-init, configure the editor directly on `<textarea>`:

| Attribute | Example | Description |
| :--- | :--- | :--- |
| `data-jbd-editor` | `data-jbd-editor="true"` | Marks textarea for automatic initialization |
| `data-jbd-toolbar` | `data-jbd-toolbar="article"` | Sets toolbar preset (`'full'`, `'basic'`, `'minimal'`, `'article'`, or `'false'`) |
| `data-jbd-inline-toolbar` | `data-jbd-inline-toolbar="true"` | Enables Medium/Notion-style floating selection bubble toolbar |
| `data-jbd-height` | `data-jbd-height="400px"` | Sets minimum editor height |
| `data-jbd-placeholder` | `data-jbd-placeholder="Start writing..."` | Custom placeholder text |
| `data-jbd-autosave` | `data-jbd-autosave="post_draft"` | Unique key for LocalStorage draft caching |
| `data-jbd-clean-paste` | `data-jbd-clean-paste="true"` | Automatically strips element styles &amp; classes when pasting documents (defaults to `true`) |
| `data-jbd-status` | `data-jbd-status="false"` | Set to `"false"` to hide bottom word/character counter |

---

## 🧹 Document Paste & Cleanup Tool (Strips Styles & Classes)

When users copy and paste documents from **Microsoft Word**, **Google Docs**, **Apple Pages**, emails, or other websites, the clipboard often contains messy inline styles (`font-family`, `font-size`, `margin`, `color`, `line-height`, `mso-*`), unwanted classes (`MsoNormal`, `c1`, `c2`, `WordSection1`), and bloated container `<span>` tags that break your site's typography.

JBDEditor automatically applies an intelligent **Clean Up Tool** on paste:
- **Removes all inline `style="..."` attributes** across elements.
- **Removes foreign `class="..."` attributes** (with optional whitelist support).
- **Preserves semantic document hierarchy:** Headings (`<h1>`–`<h6>`), paragraphs, bold (`<strong>`/`<b>`), italic (`<em>`/`<i>`), underline (`<u>`), lists, links (`<a>`), images (`<img>`), and tables.
- **Converts inline styles to semantic HTML tags** (e.g. `style="font-weight:bold"` &rarr; `<strong>`) before stripping styles so formatting is not lost.
- **Fixes Google Docs artifacts:** Unwraps Google Docs' fake-bold wrapper (`<b style="font-weight:normal">`), strips `docs-internal-guid-*` IDs.
- **Normalizes Microsoft Office artifacts:** Strips `<!--[if !mso]>` conditional comments, `<o:p>` paragraph markers, and Office XML namespaces.
- **Unwraps redundant `<span>` tags:** Any empty or attribute-less container spans are cleanly flattened into the document.
- **Accessible table styling:** Automatically applies `jbd-table jbd-table-bordered` to pasted tables.

### Programmatic Cleanup API:
```javascript
// Clean the entire editor document on demand
editor.cleanDocument();

// Clean only the currently highlighted text/selection
editor.cleanSelection();

// Clean selection if active, otherwise cleans whole document
editor.cleanUp();

// Standalone utility function (works with any HTML string)
const cleanHTML = JBDEditor.cleanDocumentHTML(dirtyWordOrGoogleDocHTML, {
  removeStyles: true,           // Default: true
  removeClasses: true,          // Default: true
  convertSemanticStyles: true,  // Default: true
  unwrapRedundantSpans: true,   // Default: true
  preserveClasses: ['keep-me']  // Optional whitelist of classes to keep
});
```

### Paste Cleanup Configuration:
```javascript
const editor = JBDEditor.attach('#my-textarea', {
  cleanPaste: true, // Enabled by default; set false to disable
  cleanPasteOptions: {
    preserveClasses: ['custom-callout'] // Optional class whitelist
  }
});
```

---

## 🚀 Native Form & Framework Integration

JBDEditor automatically handles form life cycles:
1. **Form Submit Sync:** Listens to parent `<form>` submission and guarantees the latest HTML is copied to the `<textarea>`.
2. **Reactive Frameworks:** Dispatches native `input` and `change` events on the `<textarea>` so `v-model` (Vue), `x-model` (Alpine), and HTML5 constraint validation react automatically.
3. **Form Reset:** Listens to `<form>` reset and restores original initial values.

```javascript
// Native FormData works out of the box!
const form = document.querySelector('form');
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const formData = new FormData(form);
  console.log(formData.get('content')); // Fully updated HTML!
});
```

---

## 📡 Events & Lifecycle Hooks

Subscribe via options or the Pub/Sub `.on()` / `.off()` API:

```javascript
const editor = JBDEditor.attach('#my-textarea', {
  onReady: (ed) => console.log('Editor ready!'),
  onChange: (html, text) => console.log('Content changed'),
  onFocus: (ed) => console.log('Editor focused'),
  onBlur: (ed) => console.log('Editor blurred')
});

// Or using event listeners:
editor.on('change', (html, text) => {
  updateCharCounter(text.length);
});

editor.on('ready', () => {
  editor.insertHTML('<p>Welcome!</p>');
});
```

---

## 📚 Instance API Reference

```javascript
// Content Management
editor.getHTML();              // Returns formatted HTML string
editor.setHTML('<p>Hello</p>'); // Sets editor content
editor.getText();              // Returns clean plain text
editor.clear();                // Clears content and draft cache
editor.isEmpty();              // Returns true if content is blank

// Cursor & Insertion
editor.insertHTML('<strong>Bold</strong>'); // Inserts HTML at cursor
editor.insertText('Plain text');            // Inserts text at cursor
editor.focus();                             // Focuses content area

// Templates & Dialogs
editor.openTemplateModal();    // Opens accessible Block Template browser
editor.toggleSourceView();     // Switches between visual and clean indented HTML source
editor.toggleMaximize();       // Toggles full-screen maximize mode

// Lifecycle
editor.destroy();              // Cleanly tears down DOM and unbinds events
```

---

## ♿ Accessibility (WCAG 2.2 Level AA & ADA Title III)

- **Keyboard Navigation:**
  - <kbd>Alt + F10</kbd>: Focus toolbar
  - <kbd>Left / Right Arrow</kbd>: Roving tabindex between toolbar buttons
  - <kbd>Esc</kbd>: Exit toolbar or close modal dialogs
  - <kbd>Tab / Shift + Tab</kbd>: Trapped inside dialog modals
- **Screen Reader Support:**
  - `role="textbox"`, `aria-multiline="true"`, `aria-labelledby`, and `aria-required` mirroring native `<textarea>`.
  - Accessible tables with `<th scope="col">` and `<th scope="row">`.
  - Live regions (`aria-live="polite"`) for word count and auto-save statuses.
  - High Contrast / Windows Forced Colors mode support.

