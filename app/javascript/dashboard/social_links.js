import Sortable from 'sortablejs'

class SocialLinksBuilder {
  constructor(root) {
    this.root = root
    this.list = root.querySelector('[data-social-links-list]')
    this.template = root.querySelector('[data-social-links-template]')
    this.addButton = root.querySelector('[data-social-links-add]')

    this.addButton?.addEventListener('click', () => this.addRow())
    this.list?.addEventListener('click', (event) => {
      const removeButton = event.target.closest('[data-social-links-remove]')
      if (!removeButton) return

      removeButton.closest('[data-social-links-row]')?.remove()
    })
    this.installSortable()
  }

  addRow() {
    if (!this.template || !this.list) return

    const fragment = this.template.content.cloneNode(true)
    this.list.appendChild(fragment)
    this.list.querySelector('[data-social-links-row]:last-child input')?.focus()
  }

  installSortable() {
    if (!this.list || this.list.dataset.socialLinksSortable === 'true') return

    Sortable.create(this.list, {
      handle: '[data-social-links-handle]',
      animation: 150
    })
    this.list.dataset.socialLinksSortable = 'true'
  }
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-social-links-builder]').forEach((root) => {
    if (root.dataset.socialLinksReady === 'true') return

    root.dataset.socialLinksReady = 'true'
    new SocialLinksBuilder(root)
  })
})
