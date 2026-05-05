// Inline images library used by post_editor.js.
// Lists existing attachments, supports drag&drop ordering, inline metadata
// editing (alt + caption per locale) and uploading new images. Holds an
// in-memory list of orphan IDs so that on form submit they can be linked to
// the post being created.

import Sortable from 'sortablejs'

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content || ''

const escapeHtml = (value) => String(value || '')
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')

class AttachmentLibrary {
  constructor(root) {
    this.root = root
    this.list = root.querySelector('[data-library-list]')
    this.input = root.querySelector('[data-library-upload-input]')
    this.uploadButton = root.querySelector('[data-library-upload-button]')
    this.attachableType = root.dataset.attachableType
    this.attachableId = root.dataset.attachableId || null
    this.attachmentType = root.dataset.attachmentType || 'image'
    this.pendingContainer = document.querySelector('[data-pending-attachment-ids]')
    this.attachments = []
    this.pickResolver = null
    this.bind()
    root.__attachmentLibrary = this
  }

  bind() {
    if (this.uploadButton && this.input) {
      this.uploadButton.addEventListener('click', () => this.input.click())
      this.input.addEventListener('change', (event) => this.handleUpload(event))
    }
    this.refresh()
  }

  async refresh() {
    const params = new URLSearchParams({ attachment_type: this.attachmentType })
    if (this.attachableId) {
      params.set('attachable_type', this.attachableType)
      params.set('attachable_id', this.attachableId)
    } else {
      params.set('orphan', 'true')
    }
    const response = await fetch(`/api/v1/media_attachments?${params.toString()}`, {
      headers: { Accept: 'application/json' },
      credentials: 'same-origin'
    })
    if (!response.ok) return
    const data = await response.json()
    this.attachments = data.attachments || []
    this.render()
  }

  render() {
    this.list.innerHTML = ''
    this.attachments.forEach((attachment) => this.list.appendChild(this.renderItem(attachment)))
    this.installSortable()
    this.refreshPendingHiddenInputs()
  }

  installSortable() {
    if (this._sortable) this._sortable.destroy()
    this._sortable = Sortable.create(this.list, {
      handle: '[data-handle]',
      animation: 150,
      onEnd: () => this.persistOrder()
    })
  }

  renderItem(attachment) {
    const item = document.createElement('li')
    item.className = 'attachment-library__item'
    item.dataset.attachmentId = attachment.id
    item.draggable = Boolean(attachment.shortcode)
    item.innerHTML = `
      <span data-handle class="attachment-library__handle bi bi-grip-vertical" aria-hidden="true"></span>
      ${attachment.thumb_url ? `<img class="attachment-library__thumb" src="${attachment.thumb_url}" alt="">` : '<span class="attachment-library__thumb attachment-library__thumb--placeholder bi bi-file-earmark"></span>'}
      <div class="attachment-library__meta">
        <input type="text" class="form-control form-control-sm attachment-library__title" placeholder="${attachment.attachment_type === 'document' ? 'display name' : 'title'}" data-field="title_i18n" />
        ${attachment.attachment_type === 'image' ? '<input type="text" class="form-control form-control-sm attachment-library__alt" placeholder="alt text" data-field="alt_text_i18n" />' : ''}
        ${attachment.attachment_type === 'image' ? '<input type="text" class="form-control form-control-sm attachment-library__caption" placeholder="caption" data-field="caption_i18n" />' : ''}
        ${attachment.file_name ? `<small class="attachment-library__filename" title="${escapeHtml(attachment.file_name)}">${escapeHtml(attachment.file_name)}</small>` : ''}
      </div>
      <div class="attachment-library__actions">
        ${attachment.shortcode ? `<button type="button" class="btn btn-sm btn-outline-primary" data-action="insert">${this.root.dataset.insertLabel || 'Insert'}</button>` : ''}
        <button type="button" class="btn btn-sm btn-outline-secondary" data-action="copy" title="${attachment.shortcode || ''}">${this.root.dataset.copyLabel || 'Copy'}</button>
        <button type="button" class="btn btn-sm btn-outline-danger" data-action="delete">${this.root.dataset.deleteLabel || 'Delete'}</button>
      </div>
    `
    const locale = this.root.dataset.activeLocale || 'en'
    const title = item.querySelector('[data-field="title_i18n"]')
    const alt = item.querySelector('[data-field="alt_text_i18n"]')
    const cap = item.querySelector('[data-field="caption_i18n"]')
    title.value = attachment.title_i18n?.[locale] || ''
    title.addEventListener('change', () => this.persistMeta(attachment, 'title_i18n', locale, title.value))
    if (alt) {
      alt.value = attachment.alt_text_i18n?.[locale] || ''
      alt.addEventListener('change', () => this.persistMeta(attachment, 'alt_text_i18n', locale, alt.value))
    }
    if (cap) {
      cap.value = attachment.caption_i18n?.[locale] || ''
      cap.addEventListener('change', () => this.persistMeta(attachment, 'caption_i18n', locale, cap.value))
    }

    item.querySelector('[data-action="insert"]')?.addEventListener('click', () => {
      if (this.pickResolver) {
        this.pickResolver(attachment)
        this.pickResolver = null
      } else {
        this.dispatchInsert(attachment)
      }
    })
    item.addEventListener('dragstart', (event) => {
      if (!attachment.shortcode) return
      event.dataTransfer.effectAllowed = 'copyMove'
      event.dataTransfer.setData('application/x-libremedia-attachment', JSON.stringify(attachment))
      event.dataTransfer.setData('text/plain', attachment.shortcode)
      event.dataTransfer.setData('text/html', '')
    })
    item.querySelector('[data-action="copy"]')?.addEventListener('click', () => {
      if (attachment.shortcode) navigator.clipboard?.writeText(attachment.shortcode)
    })
    item.querySelector('[data-action="delete"]')?.addEventListener('click', () => this.delete(attachment))
    return item
  }

  async handleUpload(event) {
    const files = Array.from(event.target.files || [])
    if (files.length === 0) return
    for (const file of files) {
      await this.upload(file)
    }
    this.input.value = ''
    this.refresh()
  }

  async upload(file) {
    const formData = new FormData()
    formData.append('media_attachment[file]', file)
    formData.append('media_attachment[attachment_type]', this.attachmentType)
    if (this.attachableId) {
      formData.append('attachable_type', this.attachableType)
      formData.append('attachable_id', this.attachableId)
    }
    await fetch('/api/v1/media_attachments', {
      method: 'POST',
      body: formData,
      headers: { 'X-CSRF-Token': csrfToken(), Accept: 'application/json' },
      credentials: 'same-origin'
    })
  }

  async persistMeta(attachment, field, locale, value) {
    const next = Object.assign({}, attachment[field] || {})
    next[locale] = value
    attachment[field] = next
    await fetch(`/api/v1/media_attachments/${attachment.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken(), Accept: 'application/json' },
      credentials: 'same-origin',
      body: JSON.stringify({ media_attachment: { [field]: next } })
    })
  }

  async persistOrder() {
    const items = Array.from(this.list.querySelectorAll('[data-attachment-id]'))
    await Promise.all(items.map((node, index) => fetch(`/api/v1/media_attachments/${node.dataset.attachmentId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken(), Accept: 'application/json' },
      credentials: 'same-origin',
      body: JSON.stringify({ media_attachment: { position: index } })
    })))
  }

  async delete(attachment) {
    if (!window.confirm(this.root.dataset.deleteConfirm || 'Delete this file?')) return
    await fetch(`/api/v1/media_attachments/${attachment.id}`, {
      method: 'DELETE',
      headers: { 'X-CSRF-Token': csrfToken(), Accept: 'application/json' },
      credentials: 'same-origin'
    })
    this.refresh()
  }

  refreshPendingHiddenInputs() {
    if (!this.pendingContainer || this.attachableId) return
    this.pendingContainer.innerHTML = ''
    this.attachments.forEach((attachment) => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'pending_attachment_ids[]'
      input.value = attachment.id
      this.pendingContainer.appendChild(input)
    })
  }

  pick(callback) {
    this.pickResolver = callback
  }

  dispatchInsert(attachment) {
    this.root.dispatchEvent(new CustomEvent('attachment-library:insert', {
      bubbles: true,
      detail: { attachment }
    }))
  }

  openUploadDialog() {
    if (this.input) this.input.click()
  }
}

function init() {
  document.querySelectorAll('[data-attachment-library]').forEach((root) => {
    if (root.__attachmentLibrary) return
    new AttachmentLibrary(root)
  })
}

document.addEventListener('DOMContentLoaded', init)
document.addEventListener('turbo:load', init)
