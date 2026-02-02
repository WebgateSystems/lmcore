import { Controller } from "@hotwired/stimulus"

// Theme toggle controller
// Manages light/dark theme switching with localStorage persistence
export default class extends Controller {
  static values = {
    storageKey: { type: String, default: "libremedia-theme" }
  }

  connect() {
    this.applyStoredTheme()
    this.watchSystemPreference()
  }

  toggle() {
    const html = document.documentElement
    const currentTheme = html.getAttribute("data-theme")
    const newTheme = currentTheme === "dark" ? "light" : "dark"

    this.setTheme(newTheme)
  }

  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    localStorage.setItem(this.storageKeyValue, theme)

    // Update meta theme-color for mobile browsers
    const metaThemeColor = document.querySelector('meta[name="theme-color"]')
    if (metaThemeColor) {
      metaThemeColor.content = theme === "dark" ? "#020617" : "#14B8A6"
    }
  }

  applyStoredTheme() {
    const storedTheme = localStorage.getItem(this.storageKeyValue)

    if (storedTheme) {
      this.setTheme(storedTheme)
    } else if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      this.setTheme("dark")
    } else {
      this.setTheme("light")
    }
  }

  watchSystemPreference() {
    const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")

    mediaQuery.addEventListener("change", (e) => {
      // Only auto-switch if user hasn't set a preference
      if (!localStorage.getItem(this.storageKeyValue)) {
        this.setTheme(e.matches ? "dark" : "light")
      }
    })
  }
}
