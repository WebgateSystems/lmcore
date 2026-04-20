// Dashboard entry point - separate from the admin (Scutum) bundle
import * as bootstrap from "bootstrap/dist/js/bootstrap.bundle"

// Rich text editor (Posts dashboard form)
import "./dashboard/attachment_library"
import "./dashboard/post_editor"

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
    const cancelBtn  = modalEl.querySelector('[data-confirm-destroy-cancel-btn]')
    if (!titleEl || !messageEl || !detailEl || !actionLabelEl || !confirmBtn) return

    const defaults = {
      title:   modalEl.dataset.defaultTitle   || 'Confirm action',
      message: modalEl.dataset.defaultMessage || 'Are you sure?',
      action:  modalEl.dataset.defaultAction  || 'Delete'
    }

    const modal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: 'static' })
    let pendingForm = null
    // Tracks whether the dialog was dismissed via the confirm button vs
    // the cancel/close/backdrop path. Without this we'd have no way to
    // distinguish "user explicitly cancelled" from "user confirmed and we
    // already re-submitted" inside `hidden.bs.modal`.
    let confirmed = false

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
      } else {
        titleEl.textContent   = defaults.title
        messageEl.textContent = legacyMessage
        detailEl.textContent  = ''
        detailEl.classList.add('d-none')
        actionLabelEl.textContent = defaults.action
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
