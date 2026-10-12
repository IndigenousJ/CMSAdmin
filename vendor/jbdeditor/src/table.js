/**
 * TableManager - Table creation and cell/row/column manipulation for JBDEditor
 * Fully WCAG 2.1/2.2 AA compliant with semantic <th scope="col"> and <th scope="row"> headers.
 */
import { createElement } from './utils.js';

export class TableManager {
  /**
   * Generates a fully accessible HTML table element with WCAG scope attributes
   * @param {Object} options
   * @param {number} [options.rows=3]
   * @param {number} [options.cols=3]
   * @param {'row' | 'col' | 'both' | 'none'} [options.headerType='row']
   * @param {boolean} [options.hasHeader=true] Backward compatibility
   * @param {string} [options.caption='']
   * @param {boolean} [options.bordered=true]
   * @returns {HTMLTableElement}
   */
  static createTable({ rows = 3, cols = 3, headerType = null, hasHeader = true, caption = '', bordered = true }) {
    const hType = headerType || (hasHeader ? 'row' : 'none');
    const hasHeaderRow = (hType === 'row' || hType === 'both');
    const hasHeaderCol = (hType === 'col' || hType === 'both');

    const table = createElement('table', {
      className: `jbd-table ${bordered ? 'jbd-table-bordered' : ''}`,
      style: { width: '100%', borderCollapse: 'collapse' }
    });

    if (caption && caption.trim()) {
      const capEl = createElement('caption', { className: 'jbd-table-caption' }, [caption.trim()]);
      table.appendChild(capEl);
    }

    const tbody = createElement('tbody');

    if (hasHeaderRow) {
      const thead = createElement('thead');
      const headerRow = createElement('tr');
      for (let c = 0; c < cols; c++) {
        const th = createElement('th', { scope: 'col' }, [`Header ${c + 1}`]);
        headerRow.appendChild(th);
      }
      thead.appendChild(headerRow);
      table.appendChild(thead);
      rows = rows - 1; // first row was header
    }

    for (let r = 0; r < Math.max(1, rows); r++) {
      const tr = createElement('tr');
      for (let c = 0; c < cols; c++) {
        if (c === 0 && hasHeaderCol) {
          const th = createElement('th', { scope: 'row' }, [`Row Header ${r + 1}`]);
          tr.appendChild(th);
        } else {
          const td = createElement('td', {}, [`Cell ${r + 1},${c + 1}`]);
          tr.appendChild(td);
        }
      }
      tbody.appendChild(tr);
    }

    table.appendChild(tbody);
    return table;
  }

  /**
   * Finds the current table cell (td or th) under active cursor
   * @param {HTMLElement} container 
   * @returns {HTMLTableCellElement | null}
   */
  static getActiveCell(container) {
    const selection = window.getSelection();
    if (!selection || selection.rangeCount === 0) return null;
    let node = selection.anchorNode;
    if (!node) return null;
    if (node.nodeType === Node.TEXT_NODE) node = node.parentNode;

    while (node && node !== container) {
      if (node.tagName === 'TD' || node.tagName === 'TH') {
        return node;
      }
      node = node.parentNode;
    }
    return null;
  }

  /**
   * Check if a table uses row headers (th with scope="row" in first column)
   * @param {HTMLTableElement} table 
   * @returns {boolean}
   */
  static hasRowHeaders(table) {
    if (!table) return false;
    const firstCells = table.querySelectorAll('tbody tr > :first-child');
    return Array.from(firstCells).some(c => c.tagName === 'TH');
  }

  /**
   * Add a row above the current cell
   * @param {HTMLTableCellElement} cell 
   */
  static addRowAbove(cell) {
    if (!cell) return;
    const row = cell.closest('tr');
    if (!row) return;
    const table = cell.closest('table');
    const isHead = row.parentElement && row.parentElement.tagName === 'THEAD';
    const hasRowHeaders = TableManager.hasRowHeaders(table);

    const newRow = createElement('tr');
    const cols = row.children.length;
    for (let i = 0; i < cols; i++) {
      if (isHead) {
        newRow.appendChild(createElement('th', { scope: 'col' }, ['&nbsp;']));
      } else if (i === 0 && hasRowHeaders) {
        newRow.appendChild(createElement('th', { scope: 'row' }, ['&nbsp;']));
      } else {
        newRow.appendChild(createElement('td', {}, ['&nbsp;']));
      }
    }

    row.parentNode.insertBefore(newRow, row);
  }

  /**
   * Add a row below current cell
   * @param {HTMLTableCellElement} cell 
   */
  static addRowBelow(cell) {
    if (!cell) return;
    const row = cell.closest('tr');
    if (!row) return;
    const table = cell.closest('table');
    const isHead = row.parentElement && row.parentElement.tagName === 'THEAD';
    const hasRowHeaders = TableManager.hasRowHeaders(table);

    const newRow = createElement('tr');
    const cols = row.children.length;
    for (let i = 0; i < cols; i++) {
      if (isHead) {
        newRow.appendChild(createElement('th', { scope: 'col' }, ['&nbsp;']));
      } else if (i === 0 && hasRowHeaders) {
        newRow.appendChild(createElement('th', { scope: 'row' }, ['&nbsp;']));
      } else {
        newRow.appendChild(createElement('td', {}, ['&nbsp;']));
      }
    }

    row.parentNode.insertBefore(newRow, row.nextSibling);
  }

  /**
   * Add column to the left of current cell
   * @param {HTMLTableCellElement} cell 
   */
  static addColLeft(cell) {
    if (!cell) return;
    const table = cell.closest('table');
    if (!table) return;

    const colIndex = cell.cellIndex;
    const rows = table.querySelectorAll('tr');

    rows.forEach(r => {
      const isHeaderRow = r.parentElement && r.parentElement.tagName === 'THEAD';
      let newCell;
      if (isHeaderRow) {
        newCell = createElement('th', { scope: 'col' }, ['&nbsp;']);
      } else {
        newCell = createElement('td', {}, ['&nbsp;']);
      }

      if (colIndex < r.children.length) {
        r.insertBefore(newCell, r.children[colIndex]);
      } else {
        r.appendChild(newCell);
      }
    });
  }

  /**
   * Add column to the right of current cell
   * @param {HTMLTableCellElement} cell 
   */
  static addColRight(cell) {
    if (!cell) return;
    const table = cell.closest('table');
    if (!table) return;

    const colIndex = cell.cellIndex;
    const rows = table.querySelectorAll('tr');

    rows.forEach(r => {
      const isHeaderRow = r.parentElement && r.parentElement.tagName === 'THEAD';
      let newCell;
      if (isHeaderRow) {
        newCell = createElement('th', { scope: 'col' }, ['&nbsp;']);
      } else {
        newCell = createElement('td', {}, ['&nbsp;']);
      }

      const nextCell = r.children[colIndex + 1];
      if (nextCell) {
        r.insertBefore(newCell, nextCell);
      } else {
        r.appendChild(newCell);
      }
    });
  }

  /**
   * Delete current row
   * @param {HTMLTableCellElement} cell 
   */
  static deleteRow(cell) {
    if (!cell) return;
    const row = cell.closest('tr');
    if (!row) return;
    const table = cell.closest('table');
    row.remove();
    if (table && table.querySelectorAll('tr').length === 0) {
      table.remove();
    }
  }

  /**
   * Delete current column
   * @param {HTMLTableCellElement} cell 
   */
  static deleteCol(cell) {
    if (!cell) return;
    const table = cell.closest('table');
    if (!table) return;
    const colIndex = cell.cellIndex;

    const rows = table.querySelectorAll('tr');
    rows.forEach(r => {
      if (r.children[colIndex]) {
        r.children[colIndex].remove();
      }
    });

    if (table.querySelector('tr') && table.querySelector('tr').children.length === 0) {
      table.remove();
    }
  }

  /**
   * Delete entire table
   * @param {HTMLTableCellElement} cell 
   */
  static deleteTable(cell) {
    if (!cell) return;
    const table = cell.closest('table');
    if (table) table.remove();
  }
}
