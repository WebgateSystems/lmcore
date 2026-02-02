import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]
  static values = {
    offset: { type: Number, default: 120 }
  }

  connect() {
    this.sections = []
    this.collectSections()
    this.boundHandleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.boundHandleScroll, { passive: true })
    // Initial check after a short delay to ensure DOM is ready
    setTimeout(() => this.handleScroll(), 100)
  }

  disconnect() {
    window.removeEventListener("scroll", this.boundHandleScroll)
  }

  collectSections() {
    this.linkTargets.forEach(link => {
      const href = link.getAttribute("href")
      if (href && href.startsWith("#")) {
        const sectionId = href.substring(1)
        const section = document.getElementById(sectionId)
        if (section) {
          this.sections.push({ id: sectionId, element: section, link: link })
        }
      }
    })
  }

  handleScroll() {
    const scrollY = window.scrollY
    const offset = this.offsetValue
    let activeSection = null

    // Find which section is currently in the viewport
    // We check from bottom to top so the topmost visible section wins
    for (let i = this.sections.length - 1; i >= 0; i--) {
      const section = this.sections[i]
      const rect = section.element.getBoundingClientRect()
      
      // Section is considered active if its top is at or above the offset line
      if (rect.top <= offset) {
        activeSection = section
        break
      }
    }

    // Clear all active states
    this.linkTargets.forEach(link => link.classList.remove("active"))
    document.querySelectorAll(".mobile-nav-link").forEach(link => link.classList.remove("active"))

    // Set active state
    if (activeSection) {
      activeSection.link.classList.add("active")
      
      // Also update mobile nav links
      const mobileLink = document.querySelector(`.mobile-nav-link[href="#${activeSection.id}"]`)
      if (mobileLink) {
        mobileLink.classList.add("active")
      }
    }
  }
}
