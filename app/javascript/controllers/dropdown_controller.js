import { Controller } from "@hotwired/stimulus"

// Dropdown controller
// Manages dropdown menu open/close state
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleEscape = this.handleEscape.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const isOpen = this.element.getAttribute("data-open") === "true"

    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.element.setAttribute("data-open", "true")
    this.element.querySelector("button")?.setAttribute("aria-expanded", "true")

    // Add event listeners for closing
    document.addEventListener("click", this.handleClickOutside)
    document.addEventListener("keydown", this.handleEscape)

    // Focus first menu item
    setTimeout(() => {
      const firstItem = this.menuTarget?.querySelector("a, button")
      firstItem?.focus()
    }, 100)
  }

  close() {
    this.element.setAttribute("data-open", "false")
    this.element.querySelector("button")?.setAttribute("aria-expanded", "false")

    // Remove event listeners
    document.removeEventListener("click", this.handleClickOutside)
    document.removeEventListener("keydown", this.handleEscape)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
      this.element.querySelector("button")?.focus()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
    document.removeEventListener("keydown", this.handleEscape)
  }
}
