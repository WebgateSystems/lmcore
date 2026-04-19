// Dashboard entry point - separate from the admin (Scutum) bundle
import "bootstrap/dist/js/bootstrap.bundle"

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
