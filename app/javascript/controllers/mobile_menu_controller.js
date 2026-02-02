import { Controller } from "@hotwired/stimulus"

// Mobile menu controller
// Manages full-screen mobile navigation menu
// The mini logo in header acts as the menu trigger
export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    this.boundHandleEscape = this.handleEscape.bind(this)
    this.isOpen = false
  }

  toggle(event) {
    // Find the trigger button
    this.triggerButton = event.currentTarget
    
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true
    
    // Add open class to trigger button for animation
    if (this.triggerButton) {
      this.triggerButton.classList.add("open")
      this.triggerButton.setAttribute("aria-expanded", "true")
    }
    
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("open")
    }
    
    // Lock body scroll
    document.body.style.overflow = "hidden"

    // Listen for escape key
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  close() {
    this.isOpen = false
    
    // Remove open class from trigger button
    if (this.triggerButton) {
      this.triggerButton.classList.remove("open")
      this.triggerButton.setAttribute("aria-expanded", "false")
    }
    
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("open")
    }
    
    // Restore body scroll
    document.body.style.overflow = ""

    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
      if (this.triggerButton) {
        this.triggerButton.focus()
      }
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleEscape)
    document.body.style.overflow = ""
  }
}
