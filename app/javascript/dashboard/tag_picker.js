const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content || ''

class DashboardTagPicker {
  constructor(root) {
    this.root = root
    this.select = root.querySelector('[data-dashboard-tag-picker-select]')
    this.tokens = root.querySelector('[data-dashboard-tag-picker-tokens]')
    this.input = root.querySelector('[data-dashboard-tag-picker-input]')
    this.suggestions = root.querySelector('[data-dashboard-tag-picker-suggestions]')
    this.error = root.querySelector('[data-dashboard-tag-picker-error]')
    this.createUrl = root.dataset.createUrl
    this.emptyNameLabel = root.dataset.emptyName || 'Enter a tag name.'
    this.createFailedLabel = root.dataset.createFailed || 'Could not create tag.'
    this.createLabel = root.dataset.createLabel || 'Create'
    this.removeLabel = root.dataset.removeLabel || 'Remove'
    this.control = root.querySelector('.dashboard-tag-picker__control')

    if (!this.select || !this.tokens || !this.input || !this.suggestions) return

    this.input.addEventListener('input', () => {
      this.clearError()
      this.renderSuggestions()
    })
    this.control?.addEventListener('click', () => this.input.focus())
    this.input.addEventListener('focus', () => this.renderSuggestions())
    this.input.addEventListener('keydown', (event) => this.handleKeydown(event))
    this.tokens.addEventListener('click', (event) => {
      const removeButton = event.target.closest('[data-dashboard-tag-remove]')
      if (!removeButton) return

      this.removeTag(removeButton.dataset.tagId)
    })
    this.suggestions.addEventListener('mousedown', (event) => {
      event.preventDefault()
      const option = event.target.closest('[data-dashboard-tag-suggestion]')
      if (!option) return

      if (option.dataset.tagId) {
        this.selectTag(option.dataset.tagId)
      } else {
        this.createAndSelect(this.input.value)
      }
    })
    document.addEventListener('click', (event) => {
      if (!this.root.contains(event.target)) this.hideSuggestions()
    })

    this.renderTokens()
  }

  options() {
    return Array.from(this.select.options).map((option) => ({
      id: option.value,
      name: option.dataset.name || option.textContent.trim(),
      selected: option.selected
    }))
  }

  selectedOptions() {
    return this.options().filter((option) => option.selected)
  }

  handleKeydown(event) {
    if (event.key === 'Backspace' && this.input.value === '') {
      const last = this.selectedOptions().at(-1)
      if (last) this.removeTag(last.id)
      return
    }

    if (event.key !== 'Enter') return

    event.preventDefault()
    const query = this.input.value.trim()
    if (!query) {
      this.showError(this.emptyNameLabel)
      return
    }

    const existing = this.options().find((option) => option.name.toLowerCase() === query.toLowerCase())
    if (existing) {
      this.selectTag(existing.id)
    } else {
      this.createAndSelect(query)
    }
  }

  selectTag(id) {
    const option = Array.from(this.select.options).find((entry) => entry.value === String(id))
    if (!option) return

    option.selected = true
    this.input.value = ''
    this.hideSuggestions()
    this.renderTokens()
  }

  removeTag(id) {
    const option = Array.from(this.select.options).find((entry) => entry.value === String(id))
    if (!option) return

    option.selected = false
    this.renderTokens()
    this.input.focus()
  }

  async createAndSelect(rawName) {
    const name = rawName.trim()
    if (!name || !this.createUrl) return

    this.input.disabled = true
    this.clearError()
    try {
      const response = await fetch(this.createUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'X-CSRF-Token': csrfToken()
        },
        body: JSON.stringify({ tag: { name } })
      })
      const payload = await response.json().catch(() => ({}))
      if (!response.ok) {
        const firstError = Array.isArray(payload.errors) ? payload.errors[0] : null
        throw new Error(firstError || this.createFailedLabel)
      }

      const option = this.upsertOption(payload)
      option.selected = true
      this.input.value = ''
      this.hideSuggestions()
      this.renderTokens()
    } catch (error) {
      this.showError(error.message || this.createFailedLabel)
    } finally {
      this.input.disabled = false
      this.input.focus()
    }
  }

  upsertOption(tag) {
    const id = String(tag.id)
    let option = Array.from(this.select.options).find((entry) => entry.value === id)
    if (!option) {
      option = document.createElement('option')
      option.value = id
      this.select.appendChild(option)
    }
    option.dataset.name = tag.name || tag.slug || id
    option.textContent = tag.name || tag.slug || id
    return option
  }

  renderTokens() {
    this.tokens.innerHTML = ''
    this.selectedOptions().forEach((option) => {
      const token = document.createElement('span')
      token.className = 'dashboard-tag-picker__token'
      token.innerHTML = `
        <span>${this.escapeHtml(option.name)}</span>
        <button type="button" aria-label="${this.escapeHtml(this.removeLabel)} ${this.escapeHtml(option.name)}" data-dashboard-tag-remove data-tag-id="${option.id}">&times;</button>
      `
      this.tokens.appendChild(token)
    })
  }

  renderSuggestions() {
    const query = this.input.value.trim().toLowerCase()
    const matches = this.options()
      .filter((option) => !option.selected)
      .filter((option) => query === '' || option.name.toLowerCase().includes(query))
      .slice(0, 8)

    this.suggestions.innerHTML = ''
    matches.forEach((option) => {
      const item = document.createElement('button')
      item.type = 'button'
      item.className = 'dashboard-tag-picker__suggestion'
      item.dataset.dashboardTagSuggestion = 'true'
      item.dataset.tagId = option.id
      item.textContent = option.name
      this.suggestions.appendChild(item)
    })

    if (query && !this.options().some((option) => option.name.toLowerCase() === query)) {
      const create = document.createElement('button')
      create.type = 'button'
      create.className = 'dashboard-tag-picker__suggestion dashboard-tag-picker__suggestion--create'
      create.dataset.dashboardTagSuggestion = 'true'
      create.textContent = `${this.createLabel} "${this.input.value.trim()}"`
      this.suggestions.appendChild(create)
    }

    this.suggestions.classList.toggle('d-none', this.suggestions.children.length === 0)
  }

  hideSuggestions() {
    this.suggestions.classList.add('d-none')
  }

  showError(message) {
    if (!this.error) return
    this.error.textContent = message
    this.error.classList.remove('d-none')
  }

  clearError() {
    if (!this.error) return
    this.error.textContent = ''
    this.error.classList.add('d-none')
  }

  escapeHtml(value) {
    return String(value || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
  }
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-dashboard-tag-picker]').forEach((root) => {
    if (root.dataset.dashboardTagPickerReady === 'true') return

    root.dataset.dashboardTagPickerReady = 'true'
    new DashboardTagPicker(root)
  })
})
