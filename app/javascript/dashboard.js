// Dashboard entry point - separate from the admin (Scutum) bundle
import * as bootstrap from "bootstrap/dist/js/bootstrap.bundle"

// Rich text editor (Posts dashboard form)
import "./dashboard/attachment_library"
import "./dashboard/post_editor"
import "./dashboard/social_links"
import "./dashboard/tag_picker"

// Theme switcher (light/dark)
const THEME_STORAGE_KEY = 'dashboard-theme'
const rootElement = document.documentElement
const mediaQuery = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null
const savedTheme = localStorage.getItem(THEME_STORAGE_KEY)
const prefersDark = mediaQuery?.matches ?? false
const initialIsDark = savedTheme ? savedTheme === 'dark' : prefersDark

function applyTheme(isDark) {
  rootElement.classList.toggle('theme-dark', isDark)
  rootElement.setAttribute('data-theme', isDark ? 'dark' : 'light')
  localStorage.setItem(THEME_STORAGE_KEY, isDark ? 'dark' : 'light')
}

applyTheme(initialIsDark)

document.addEventListener('DOMContentLoaded', () => {
  // Theme toggle
  const toggleBtn = document.getElementById('theme-toggle-btn')
  if (toggleBtn) {
    toggleBtn.addEventListener('click', () => {
      const isDark = rootElement.classList.contains('theme-dark')
      applyTheme(!isDark)
    })
  }

  // Sidebar collapse/expand
  const SIDEBAR_COLLAPSED_KEY = 'dashboardSidebarCollapsed'
  const app = document.querySelector('[data-dashboard-app]')
  const toggleButton = document.querySelector('[data-sidebar-toggle]')
  const overlay = document.querySelector('[data-sidebar-overlay]')
  const collapseToggle = document.querySelector('[data-sidebar-collapse-toggle]')
  if (!app || !toggleButton || !overlay) return

  const closeSidebar = () => { app.classList.remove('dashboard-app--sidebar-open') }
  const toggleSidebar = () => { app.classList.toggle('dashboard-app--sidebar-open') }

  const updateCollapseToggleState = () => {
    if (!collapseToggle) return
    const isDesktop = window.matchMedia('(min-width: 1024px)').matches
    if (!isDesktop) {
      app.classList.remove('dashboard-app--sidebar-collapsed')
      collapseToggle.setAttribute('aria-expanded', 'true')
      return
    }
    const storedCollapsed = localStorage.getItem(SIDEBAR_COLLAPSED_KEY) === 'true'
    if (storedCollapsed) {
      app.classList.add('dashboard-app--sidebar-collapsed')
    } else {
      app.classList.remove('dashboard-app--sidebar-collapsed')
    }
    const isCollapsed = app.classList.contains('dashboard-app--sidebar-collapsed')
    collapseToggle.setAttribute('aria-expanded', String(!isCollapsed))
  }

  if (collapseToggle) {
    collapseToggle.addEventListener('click', () => {
      if (!window.matchMedia('(min-width: 1024px)').matches) return
      const isCollapsed = app.classList.toggle('dashboard-app--sidebar-collapsed')
      localStorage.setItem(SIDEBAR_COLLAPSED_KEY, String(isCollapsed))
      updateCollapseToggleState()
    })
  }

  toggleButton.addEventListener('click', toggleSidebar)
  overlay.addEventListener('click', closeSidebar)

  app.querySelectorAll('.dashboard-nav__button').forEach((button) => {
    button.addEventListener('click', () => {
      if (window.matchMedia('(max-width: 768px)').matches) closeSidebar()
    })
  })

  window.addEventListener('resize', () => {
    if (!window.matchMedia('(max-width: 768px)').matches) closeSidebar()
    updateCollapseToggleState()
  })

  updateCollapseToggleState()

  // Alert dismiss
  document.querySelectorAll('[data-dismiss-alert]').forEach((button) => {
    button.addEventListener('click', function() {
      const alert = this.closest('.alert')
      if (alert) {
        alert.style.opacity = '0'
        alert.style.transform = 'translateY(-10px)'
        alert.style.transition = 'opacity 0.2s ease, transform 0.2s ease'
        setTimeout(() => alert.remove(), 200)
      }
    })
  })

  document.querySelectorAll('.alert-success').forEach((alert) => {
    setTimeout(() => {
      const closeBtn = alert.querySelector('[data-dismiss-alert]')
      if (closeBtn) closeBtn.click()
    }, 5000)
  })

  // Settings: language picker.
  // Keeps the "Default language" dropdown in sync with the "Available languages"
  // checkboxes -- only checked locales remain selectable as default; if the
  // current default is unchecked, we fall back to the first available one.
  document.querySelectorAll('[data-locale-picker]').forEach((picker) => {
    const checkboxes = picker.querySelectorAll('[data-locale-picker-checkbox]')
    const defaultSelect = picker.querySelector('[data-locale-picker-default]')
    if (!checkboxes.length || !defaultSelect) return

    // Snapshot the human-readable label for every locale option so we can
    // re-create entries after the user re-checks a previously removed one.
    const labels = new Map()
    checkboxes.forEach((cb) => {
      const card = cb.closest('.locale-option')
      const tag = card?.querySelector('.locale-option__tag')?.textContent?.trim() || cb.value.toUpperCase()
      const name = card?.querySelector('.locale-option__name')?.textContent?.trim() || ''
      labels.set(cb.value, [tag, name].filter(Boolean).join(' '))
    })

    const refreshDefaultOptions = () => {
      const previous = defaultSelect.value
      const checked = Array.from(checkboxes).filter((cb) => cb.checked).map((cb) => cb.value)
      defaultSelect.innerHTML = ''
      checked.forEach((code) => {
        const option = document.createElement('option')
        option.value = code
        option.textContent = labels.get(code) || code.toUpperCase()
        defaultSelect.appendChild(option)
      })
      if (checked.includes(previous)) {
        defaultSelect.value = previous
      } else if (checked.length) {
        defaultSelect.value = checked[0]
      }
    }

    const refreshCardState = (cb) => {
      const card = cb.closest('.locale-option')
      if (card) card.classList.toggle('is-checked', cb.checked)
    }

    checkboxes.forEach((cb) => {
      cb.addEventListener('change', () => {
        if (cb.checked === false) {
          // Disallow unchecking the last remaining locale -- the blog must
          // always have at least one publication language.
          const stillChecked = Array.from(checkboxes).filter((other) => other.checked)
          if (stillChecked.length === 0) {
            cb.checked = true
            return
          }
        }
        refreshCardState(cb)
        refreshDefaultOptions()
      })
    })
  })

  // Content locale tabs for forms that edit multiple translations at once.
  document.querySelectorAll('[data-locale-switcher]').forEach((root) => {
    if (root.dataset.localeSwitcherInitialized === 'true') return
    root.dataset.localeSwitcherInitialized = 'true'

    const tabs = Array.from(root.querySelectorAll('[data-locale-tab]'))
    const panels = Array.from(root.querySelectorAll('[data-locale-panel]'))
    if (tabs.length === 0 || panels.length === 0) return

    const activate = (locale) => {
      tabs.forEach((tab) => tab.classList.toggle('active', tab.dataset.localeTab === locale))
      panels.forEach((panel) => panel.classList.toggle('d-none', panel.dataset.localePanel !== locale))
    }

    const initialLocale = root.dataset.activeLocale || tabs[0].dataset.localeTab
    activate(initialLocale)

    tabs.forEach((tab) => {
      tab.addEventListener('click', (event) => {
        event.preventDefault()
        activate(tab.dataset.localeTab)
      })
    })
  })

  // Gallery bulk upload with progress bar.
  document.querySelectorAll('[data-gallery-upload-form]').forEach((form) => {
    if (form.dataset.galleryUploadInitialized === 'true') return
    form.dataset.galleryUploadInitialized = 'true'

    const input = form.querySelector('[data-gallery-upload-input]')
    const progressWrap = form.querySelector('[data-gallery-upload-progress-wrap]')
    const progressBar = form.querySelector('[data-gallery-upload-progress]')
    const status = form.querySelector('[data-gallery-upload-status]')
    const fileList = form.querySelector('[data-gallery-upload-file-list]')
    const dropzone = form.querySelector('[data-gallery-dropzone]')
    const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]')
    const uploadUrl = form.dataset.galleryUploadUrl
    if (!input || !progressWrap || !progressBar || !status || !submitBtn || !uploadUrl) return
    const progressLabel = form.dataset.galleryUploadTextProgress || 'Uploading'
    const doneLabel = form.dataset.galleryUploadTextDone || 'Uploaded'
    const failedLabel = form.dataset.galleryUploadTextFailed || 'Failed'
    const heicUnavailableLabel = form.dataset.galleryUploadTextHeicFailed || 'Preview unavailable for this HEIC file.'

    const isHeicFile = (file) => {
      const name = (file?.name || '').toLowerCase()
      const type = (file?.type || '').toLowerCase()
      return name.endsWith('.heic') || name.endsWith('.heif') || type.includes('heic') || type.includes('heif')
    }

    const revokePreviewUrls = () => {
      if (!fileList) return
      fileList.querySelectorAll('[data-preview-object-url]').forEach((element) => {
        const url = element.getAttribute('data-preview-object-url')
        if (url) URL.revokeObjectURL(url)
      })
    }

    const buildImageFromBlob = (blob, fileName) => {
      if (!(blob instanceof Blob)) return null
      const objectUrl = URL.createObjectURL(blob)
      const img = document.createElement('img')
      img.src = objectUrl
      img.alt = fileName
      img.style.maxWidth = '100%'
      img.style.maxHeight = '110px'
      img.style.objectFit = 'cover'
      img.setAttribute('data-preview-object-url', objectUrl)
      return img
    }

    const resolvePreviewImage = async (file) => {
      if (isHeicFile(file)) return null
      return buildImageFromBlob(file, file.name)
    }

    const renderSelectedFiles = async () => {
      if (!fileList) return
      revokePreviewUrls()
      const files = Array.from(input.files || [])
      if (files.length === 0) {
        fileList.innerHTML = ''
        return
      }
      fileList.innerHTML = ''
      files.forEach((file) => {
        const col = document.createElement('div')
        col.className = 'col-6 col-md-4 col-xl-3'

        const card = document.createElement('div')
        card.className = 'border rounded p-2 h-100'

        const mediaWrap = document.createElement('div')
        mediaWrap.className = 'mb-2 d-flex align-items-center justify-content-center'
        mediaWrap.style.minHeight = '100px'
        mediaWrap.style.maxHeight = '120px'
        mediaWrap.style.overflow = 'hidden'
        mediaWrap.style.background = 'rgba(0,0,0,0.02)'

        const name = document.createElement('div')
        name.className = 'text-body-3'
        name.style.wordBreak = 'break-all'
        name.textContent = file.name

        card.appendChild(mediaWrap)
        card.appendChild(name)
        col.appendChild(card)
        fileList.appendChild(col)

        if (isHeicFile(file)) {
          mediaWrap.innerHTML = ''
          const icon = document.createElement('i')
          icon.className = 'bi bi-file-earmark-image'
          icon.style.fontSize = '24px'
          mediaWrap.appendChild(icon)
          const msg = document.createElement('div')
          msg.className = 'text-body-3 text-muted mt-1 text-center'
          msg.textContent = heicUnavailableLabel
          mediaWrap.appendChild(msg)
          return
        }

        const isRenderableImage = file.type.startsWith('image/') || isHeicFile(file)
        if (!isRenderableImage) {
          mediaWrap.innerHTML = ''
          const icon = document.createElement('i')
          icon.className = 'bi bi-file-earmark-image'
          icon.style.fontSize = '24px'
          mediaWrap.appendChild(icon)
          return
        }

        resolvePreviewImage(file).then((img) => {
          mediaWrap.innerHTML = ''
          if (img) {
            mediaWrap.appendChild(img)
            return
          }

          const icon = document.createElement('i')
          icon.className = 'bi bi-file-earmark-break'
          icon.style.fontSize = '24px'
          mediaWrap.appendChild(icon)
          if (isHeicFile(file)) {
            const msg = document.createElement('div')
            msg.className = 'text-body-3 text-muted mt-1'
            msg.textContent = heicFailedLabel
            mediaWrap.appendChild(msg)
          }
        })
      })
    }

    input.addEventListener('change', renderSelectedFiles)

    if (dropzone) {
      const onDrag = (event) => {
        event.preventDefault()
        event.stopPropagation()
        dropzone.classList.add('border-primary')
      }
      const onLeave = (event) => {
        event.preventDefault()
        event.stopPropagation()
        dropzone.classList.remove('border-primary')
      }
      const onDrop = (event) => {
        event.preventDefault()
        event.stopPropagation()
        dropzone.classList.remove('border-primary')
        const files = Array.from(event.dataTransfer?.files || [])
        if (files.length === 0) return
        const dt = new DataTransfer()
        files.forEach((file) => dt.items.add(file))
        input.files = dt.files
        renderSelectedFiles()
      }

      dropzone.addEventListener('dragenter', onDrag)
      dropzone.addEventListener('dragover', onDrag)
      dropzone.addEventListener('dragleave', onLeave)
      dropzone.addEventListener('drop', onDrop)
    }

    form.addEventListener('submit', (event) => {
      const files = Array.from(input.files || [])
      if (files.length === 0) return

      event.preventDefault()
      progressWrap.classList.remove('d-none')
      submitBtn.disabled = true
      progressBar.style.width = '0%'
      status.textContent = `${progressLabel} 0/${files.length}`

      const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
      let completed = 0
      let failed = 0

      const uploadOne = (file, done) => {
        const xhr = new XMLHttpRequest()
        xhr.open('POST', uploadUrl)
        xhr.responseType = 'json'
        if (token) xhr.setRequestHeader('X-CSRF-Token', token)

        xhr.upload.addEventListener('progress', (e) => {
          if (!e.lengthComputable) return
          const fileProgress = e.loaded / e.total
          const overall = ((completed + fileProgress) / files.length) * 100
          progressBar.style.width = `${Math.round(overall)}%`
          status.textContent = `${progressLabel} ${completed}/${files.length}`
        })

        xhr.addEventListener('load', () => {
          completed += 1
          if (xhr.status < 200 || xhr.status >= 300) failed += 1
          const overall = (completed / files.length) * 100
          progressBar.style.width = `${Math.round(overall)}%`
          status.textContent = `${progressLabel} ${completed}/${files.length}`
          done()
        })

        xhr.addEventListener('error', () => {
          completed += 1
          failed += 1
          done()
        })

        const body = new FormData()
        body.append('photos[images][]', file)
        xhr.send(body)
      }

      const queue = files.slice()
      const next = () => {
        const file = queue.shift()
        if (!file) {
          if (failed > 0) {
            status.textContent = `${failedLabel}: ${failed}/${files.length}`
            submitBtn.disabled = false
          } else {
            status.textContent = `${doneLabel} ${completed}/${files.length}`
            window.location.reload()
          }
          return
        }
        uploadOne(file, next)
      }

      next()
    })
  })

  // Gallery row drag-and-drop sorting.
  document.querySelectorAll('[data-gallery-sortable]').forEach((tbody) => {
    if (tbody.dataset.gallerySortableInitialized === 'true') return
    tbody.dataset.gallerySortableInitialized = 'true'

    const reorderUrl = tbody.dataset.galleryReorderUrl
    const status = document.querySelector('[data-gallery-sort-status]')
    const savingLabel = status?.dataset.sortSaving || 'Saving order...'
    const savedLabel = status?.dataset.sortSaved || 'Order saved.'
    const failedLabel = status?.dataset.sortFailed || 'Failed to save order.'
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    let draggedRow = null
    let orderChanged = false

    const getRows = () => Array.from(tbody.querySelectorAll('tr[data-photo-id]'))

    const persistOrder = async () => {
      if (!reorderUrl || !orderChanged) return
      const ids = getRows().map((row) => row.dataset.photoId).filter(Boolean)
      if (ids.length === 0) return
      try {
        if (status) status.textContent = savingLabel
        const response = await fetch(reorderUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-Token': token || ''
          },
          body: JSON.stringify({ photo_ids: ids })
        })
        if (!response.ok) throw new Error('reorder_failed')
        if (status) status.textContent = savedLabel
      } catch (_error) {
        if (status) status.textContent = failedLabel
      } finally {
        orderChanged = false
      }
    }

    const attachRowEvents = (row) => {
      row.addEventListener('dragstart', () => {
        draggedRow = row
        row.classList.add('opacity-50')
      })

      row.addEventListener('dragend', async () => {
        row.classList.remove('opacity-50')
        draggedRow = null
        await persistOrder()
      })

      row.addEventListener('dragover', (event) => {
        event.preventDefault()
        if (!draggedRow || draggedRow === row) return

        const rect = row.getBoundingClientRect()
        const before = event.clientY < rect.top + rect.height / 2

        if (before) {
          if (row.previousElementSibling !== draggedRow) {
            tbody.insertBefore(draggedRow, row)
            orderChanged = true
          }
        } else if (row.nextElementSibling !== draggedRow) {
          tbody.insertBefore(draggedRow, row.nextElementSibling)
          orderChanged = true
        }
      })
    }

    getRows().forEach(attachRowEvents)
  })

  // Blog menu editor drag-and-drop sorting.
  document.querySelectorAll('[data-menu-editor-sortable]').forEach((tbody) => {
    if (tbody.dataset.menuEditorInitialized === 'true') return
    tbody.dataset.menuEditorInitialized = 'true'

    let draggedRow = null

    const rows = () => Array.from(tbody.querySelectorAll('tr[data-menu-item-id]'))

    const attachRowEvents = (row) => {
      row.addEventListener('dragstart', () => {
        draggedRow = row
        row.classList.add('dragging')
      })

      row.addEventListener('dragend', () => {
        row.classList.remove('dragging')
        row.classList.remove('drag-over')
        draggedRow = null
      })

      row.addEventListener('dragover', (event) => {
        event.preventDefault()
        if (!draggedRow || draggedRow === row) return

        row.classList.add('drag-over')
        const rect = row.getBoundingClientRect()
        const before = event.clientY < rect.top + rect.height / 2

        if (before) {
          if (row.previousElementSibling !== draggedRow) tbody.insertBefore(draggedRow, row)
        } else if (row.nextElementSibling !== draggedRow) {
          tbody.insertBefore(draggedRow, row.nextElementSibling)
        }
      })

      row.addEventListener('dragleave', () => {
        row.classList.remove('drag-over')
      })

      row.addEventListener('drop', (event) => {
        event.preventDefault()
        row.classList.remove('drag-over')
      })
    }

    rows().forEach(attachRowEvents)
  })

})

// Dashboard index search.
//
// Wires every `[data-dashboard-search-form]` to debounced auto-submit when
// the user types 3+ characters (or clears the field entirely). Mirrors the
// public site filter (`public/themes/am/js/filters.js`): submit goes
// through Turbo Drive as a regular GET, the URL updates, and the index
// re-renders with `?q=...` filtering applied server-side.
//
// Re-runs on `turbo:load` because Turbo Drive replaces the body without
// firing `DOMContentLoaded`, and we use sessionStorage to restore focus +
// caret position so the user's typing is not interrupted by the navigation.
;(function() {
  const FOCUS_KEY = 'lm_dashboard_search_focus'
  const CURSOR_KEY = 'lm_dashboard_search_cursor'
  const MIN_CHARS = 3
  const DEBOUNCE_MS = 400

  function initSearchForms() {
    document.querySelectorAll('[data-dashboard-search-form]').forEach((form) => {
      if (form.dataset.dashboardSearchInitialized === 'true') return
      form.dataset.dashboardSearchInitialized = 'true'

      const input = form.querySelector('[data-dashboard-search-input]')
      if (!input) return

      let debounceId = null
      let lastSubmittedValue = (input.value || '').trim()

      input.addEventListener('input', () => {
        const value = (input.value || '').trim()
        // 1..MIN_CHARS-1 chars: wait for more typing — too noisy to query on
        // every keystroke. 0 chars: explicit clear, submit so the user gets
        // their full list back.
        if (value.length > 0 && value.length < MIN_CHARS) return
        if (value === lastSubmittedValue) return

        clearTimeout(debounceId)
        debounceId = setTimeout(() => {
          lastSubmittedValue = value
          rememberFocus(input)
          if (typeof form.requestSubmit === 'function') {
            form.requestSubmit()
          } else {
            form.submit()
          }
        }, DEBOUNCE_MS)
      })

      // Pressing Enter submits immediately, also persist focus.
      form.addEventListener('submit', () => rememberFocus(input))
    })

    restoreSearchFocus()
  }

  function rememberFocus(input) {
    if (document.activeElement !== input) return
    try {
      sessionStorage.setItem(FOCUS_KEY, '1')
      sessionStorage.setItem(CURSOR_KEY, String(input.selectionStart ?? input.value.length))
    } catch (_e) {}
  }

  function restoreSearchFocus() {
    let shouldFocus = false
    try { shouldFocus = sessionStorage.getItem(FOCUS_KEY) === '1' } catch (_e) {}
    if (!shouldFocus) return

    const input = document.querySelector('[data-dashboard-search-input]')
    if (!input) return

    let cursor = input.value.length
    try {
      const stored = sessionStorage.getItem(CURSOR_KEY)
      if (stored !== null) cursor = Math.min(Number(stored), input.value.length)
      sessionStorage.removeItem(FOCUS_KEY)
      sessionStorage.removeItem(CURSOR_KEY)
    } catch (_e) {}

    window.requestAnimationFrame(() => {
      input.focus({ preventScroll: true })
      try { input.setSelectionRange(cursor, cursor) } catch (_e) {}
    })
  }

  document.addEventListener('DOMContentLoaded', initSearchForms)
  document.addEventListener('turbo:load', initSearchForms)
})()

// Destructive-action confirmation modal.
//
// Replaces the browser's native `window.confirm()` (and the equally ugly
// Turbo `data-turbo-confirm` prompt) with a styled Bootstrap modal that
// can warn the user about cascading deletes — see
// `app/views/dashboard/shared/_confirm_destroy_modal.html.slim`.
//
// Two ways for a delete button to opt in:
//
//   1. Rich form (preferred for content-destroying actions like deleting
//      a post/video/photo). The button_to wraps a form carrying:
//
//        data-confirm-destroy="true"
//        data-confirm-destroy-title="Delete this video forever?"
//        data-confirm-destroy-message='You are about to delete "Foo".'
//        data-confirm-destroy-detail="This is permanent. The video and …"
//        data-confirm-destroy-action="Delete forever"
//
//   2. Legacy fallback — any form with the existing Rails/Turbo
//      `data-turbo-confirm="Are you sure?"` is also intercepted, so all
//      pre-existing dashboard delete buttons still get the styled modal
//      without any view-level changes. We use the Turbo confirm string
//      as the message and pull title/action labels from sensible defaults
//      stored on the modal element.
//
// The interceptor uses a CAPTURE-phase submit listener: it must run before
// any other handler (e.g., browser default submission) so we can stop the
// form, ask the user, and only then re-submit programmatically with
// `data-confirm-destroy-confirmed="true"` set so the second pass falls
// straight through.
;(function() {
  function setupConfirmDestroy() {
    const modalEl = document.querySelector('[data-confirm-destroy-modal]')
    if (!modalEl || modalEl.dataset.confirmDestroyInitialized === 'true') return
    modalEl.dataset.confirmDestroyInitialized = 'true'

    const titleEl   = modalEl.querySelector('[data-confirm-destroy-title]')
    const messageEl = modalEl.querySelector('[data-confirm-destroy-message]')
    const detailEl  = modalEl.querySelector('[data-confirm-destroy-detail]')
    const actionLabelEl = modalEl.querySelector('[data-confirm-destroy-action-label]')
    const confirmBtn = modalEl.querySelector('[data-confirm-destroy-confirm-btn]')
    const confirmIcon = confirmBtn?.querySelector('i')
    const cancelBtn  = modalEl.querySelector('[data-confirm-destroy-cancel-btn]')
    if (!titleEl || !messageEl || !detailEl || !actionLabelEl || !confirmBtn) return

    const defaults = {
      title:   modalEl.dataset.defaultTitle   || 'Confirm action',
      message: modalEl.dataset.defaultMessage || 'Are you sure?',
      action:  modalEl.dataset.defaultAction  || 'Delete',
      variant: 'danger',
      icon: 'bi bi-trash3'
    }

    const modal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: 'static' })
    let pendingForm = null
    // Tracks whether the dialog was dismissed via the confirm button vs
    // the cancel/close/backdrop path. Without this we'd have no way to
    // distinguish "user explicitly cancelled" from "user confirmed and we
    // already re-submitted" inside `hidden.bs.modal`.
    let confirmed = false

    const applyConfirmButtonStyle = (variant, iconClass) => {
      confirmBtn.classList.remove('btn-dashboard-danger', 'btn-dashboard-primary', 'btn-dashboard-secondary')
      const safeVariant = ['danger', 'primary', 'secondary'].includes(variant) ? variant : defaults.variant
      confirmBtn.classList.add(`btn-dashboard-${safeVariant}`)
      if (confirmIcon) confirmIcon.className = iconClass || defaults.icon
    }

    document.addEventListener('submit', function(event) {
      const form = event.target
      if (!(form instanceof HTMLFormElement)) return
      if (form.dataset.confirmDestroyConfirmed === 'true') return

      const richMode = form.dataset.confirmDestroy === 'true'
      const legacyMessage = form.dataset.turboConfirm
      if (!richMode && (!legacyMessage || legacyMessage.length === 0)) return

      event.preventDefault()
      event.stopPropagation()

      pendingForm = form
      confirmed = false

      if (richMode) {
        titleEl.textContent   = form.dataset.confirmDestroyTitle   || defaults.title
        messageEl.textContent = form.dataset.confirmDestroyMessage || defaults.message
        const detailText = form.dataset.confirmDestroyDetail
        if (detailText && detailText.length > 0) {
          detailEl.textContent = detailText
          detailEl.classList.remove('d-none')
        } else {
          detailEl.textContent = ''
          detailEl.classList.add('d-none')
        }
        actionLabelEl.textContent = form.dataset.confirmDestroyAction || defaults.action
        applyConfirmButtonStyle(form.dataset.confirmDestroyVariant, form.dataset.confirmDestroyActionIcon)
      } else {
        titleEl.textContent   = defaults.title
        messageEl.textContent = legacyMessage
        detailEl.textContent  = ''
        detailEl.classList.add('d-none')
        actionLabelEl.textContent = defaults.action
        applyConfirmButtonStyle(defaults.variant, defaults.icon)
      }

      modal.show()
      // Focus the safe option (Cancel) by default so an accidental
      // Enter-press doesn't permanently delete the user's content.
      window.requestAnimationFrame(() => (cancelBtn || confirmBtn).focus())
    }, true)

    confirmBtn.addEventListener('click', function() {
      if (!pendingForm) return
      confirmed = true

      const form = pendingForm
      pendingForm = null
      form.dataset.confirmDestroyConfirmed = 'true'

      modal.hide()

      // Re-submit AFTER the modal close transition has started so focus
      // restoration and aria state don't trip over the page navigation.
      window.requestAnimationFrame(() => {
        if (typeof form.requestSubmit === 'function') {
          form.requestSubmit()
        } else {
          form.submit()
        }
      })
    })

    modalEl.addEventListener('hidden.bs.modal', function() {
      if (!confirmed) pendingForm = null
      confirmed = false
    })
  }

  document.addEventListener('DOMContentLoaded', setupConfirmDestroy)
  document.addEventListener('turbo:load', setupConfirmDestroy)
})()
