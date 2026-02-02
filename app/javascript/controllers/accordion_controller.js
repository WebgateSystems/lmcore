import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  toggle(event) {
    const button = event.currentTarget
    const item = button.closest('.faq-item')
    const isExpanded = button.getAttribute('aria-expanded') === 'true'

    // Close all other items
    this.itemTargets.forEach(otherItem => {
      if (otherItem !== item) {
        const otherButton = otherItem.querySelector('.faq-question')
        otherButton.setAttribute('aria-expanded', 'false')
        otherItem.classList.remove('active')
      }
    })

    // Toggle current item
    button.setAttribute('aria-expanded', !isExpanded)
    item.classList.toggle('active', !isExpanded)
  }
}
