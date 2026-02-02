import { Controller } from "@hotwired/stimulus"

// Mobile menu controller
// Manages mobile navigation menu toggle
export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    const isOpen = this.menuTarget.classList.contains("open")

    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.add("open")
    this.element.setAttribute("aria-expanded", "true")

    // Trap focus inside menu
    document.addEventListener("keydown", this.handleEscape.bind(this))
  }

  close() {
    this.menuTarget.classList.remove("open")
    this.element.setAttribute("aria-expanded", "false")

    document.removeEventListener("keydown", this.handleEscape.bind(this))
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
      this.element.focus()
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape.bind(this))
  }
}
