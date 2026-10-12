/**
 * HistoryManager - Handles Undo/Redo stack management with snapshot throttling
 */
export class HistoryManager {
  /**
   * @param {number} maxStackSize 
   */
  constructor(maxStackSize = 50) {
    this.maxStackSize = maxStackSize;
    this.undoStack = [];
    this.redoStack = [];
    this.lastSnapshotTime = 0;
    this.throttleDelay = 500;
  }

  /**
   * Push a new snapshot to undo stack
   * @param {string} content 
   * @param {boolean} force - Force new snapshot without throttling (e.g., command executions)
   */
  record(content, force = false) {
    const now = Date.now();
    const lastItem = this.undoStack[this.undoStack.length - 1];

    if (lastItem === content) return;

    if (!force && (now - this.lastSnapshotTime < this.throttleDelay) && this.undoStack.length > 0) {
      // Overwrite the most recent snapshot during rapid consecutive typing
      this.undoStack[this.undoStack.length - 1] = content;
    } else {
      this.undoStack.push(content);
      if (this.undoStack.length > this.maxStackSize) {
        this.undoStack.shift();
      }
    }

    this.lastSnapshotTime = now;
    // Any new edit clears redo branch
    this.redoStack = [];
  }

  /**
   * @param {string} currentContent 
   * @returns {string | null}
   */
  undo(currentContent) {
    if (!this.canUndo()) return null;

    // Save current content to redo stack
    this.redoStack.push(currentContent);
    return this.undoStack.pop();
  }

  /**
   * @param {string} currentContent 
   * @returns {string | null}
   */
  redo(currentContent) {
    if (!this.canRedo()) return null;

    // Push current content back to undo stack
    this.undoStack.push(currentContent);
    return this.redoStack.pop();
  }

  canUndo() {
    return this.undoStack.length > 0;
  }

  canRedo() {
    return this.redoStack.length > 0;
  }

  clear() {
    this.undoStack = [];
    this.redoStack = [];
  }
}
