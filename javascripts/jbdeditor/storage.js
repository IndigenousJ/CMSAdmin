/**
 * StorageManager - Handles local persistence, draft auto-saving, and draft restoration
 * Zero external dependencies. Uses browser LocalStorage with fallback handling.
 */
export class StorageManager {
  /**
   * Check if localStorage is supported and accessible
   */
  static isAvailable() {
    try {
      const testKey = '__storage_test__';
      window.localStorage.setItem(testKey, testKey);
      window.localStorage.removeItem(testKey);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Save draft with timestamp metadata
   * @param {string} key 
   * @param {string} content 
   * @returns {boolean} Success status
   */
  static saveDraft(key, content) {
    if (!this.isAvailable() || !key) return false;
    try {
      const payload = {
        content,
        timestamp: Date.now()
      };
      window.localStorage.setItem(`jbd_draft_${key}`, JSON.stringify(payload));
      return true;
    } catch (e) {
      console.warn('StorageManager: Failed to save draft', e);
      return false;
    }
  }

  /**
   * Load draft payload
   * @param {string} key 
   * @returns {{ content: string, timestamp: number } | null}
   */
  static loadDraft(key) {
    if (!this.isAvailable() || !key) return null;
    try {
      const raw = window.localStorage.getItem(`jbd_draft_${key}`) || window.localStorage.getItem(`jal_draft_${key}`);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch (e) {
      console.warn('StorageManager: Failed to parse draft data', e);
      return null;
    }
  }

  /**
   * Clear draft from storage
   * @param {string} key 
   */
  static clearDraft(key) {
    if (!this.isAvailable() || !key) return;
    try {
      window.localStorage.removeItem(`jbd_draft_${key}`);
      window.localStorage.removeItem(`jal_draft_${key}`);
    } catch (e) {
      console.warn('StorageManager: Failed to clear draft', e);
    }
  }

  /**
   * Check if a valid draft exists
   * @param {string} key 
   * @returns {boolean}
   */
  static hasDraft(key) {
    return !!this.loadDraft(key);
  }

  /**
   * Creates a debounced auto-save runner
   * @param {string} key 
   * @param {() => string} getContent 
   * @param {number} delay 
   * @param {(status: 'saving' | 'saved' | 'idle') => void} [onStatusChange]
   * @returns {{ trigger: () => void, cancel: () => void }}
   */
  static createAutoSaver(key, getContent, delay = 1000, onStatusChange = null) {
    let timer = null;

    const trigger = () => {
      if (timer) clearTimeout(timer);
      if (onStatusChange) onStatusChange('saving');

      timer = setTimeout(() => {
        const content = getContent();
        StorageManager.saveDraft(key, content);
        if (onStatusChange) onStatusChange('saved');
        timer = null;
      }, delay);
    };

    const cancel = () => {
      if (timer) {
        clearTimeout(timer);
        timer = null;
      }
      if (onStatusChange) onStatusChange('idle');
    };

    return { trigger, cancel };
  }
}
