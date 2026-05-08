const FIELD_NAMES = ['title', 'subtitle', 'lead', 'content_source', 'keywords', 'meta_description']

function initPostTranslation(root) {
  if (root.dataset.postTranslationInitialized === 'true') return
  root.dataset.postTranslationInitialized = 'true'

  const button = root.querySelector('[data-post-translation-button]')
  if (!button) return

  button.addEventListener('click', async () => {
    const postEditor = root.__postEditor
    postEditor?.activeEditor()?.syncToTextarea()

    const sourceLocale = activeLocale(root)
    const targetLocales = missingTargetLocales(root, sourceLocale)
    const status = root.querySelector('[data-post-translation-status]')

    if (targetLocales.length === 0) {
      setStatus(status, root.dataset.translationNothingLabel || 'No empty translations to fill.', 'muted')
      return
    }

    const content = collectLocaleContent(root, sourceLocale)
    if (Object.values(content).every((value) => isBlank(value))) {
      setStatus(status, root.dataset.translationMissingSourceLabel || 'The active language has no content to translate.', 'danger')
      return
    }

    await translateMissing(root, button, status, sourceLocale, targetLocales, content)
  })
}

async function translateMissing(root, button, status, sourceLocale, targetLocales, content) {
  const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
  const originalText = button.textContent
  button.disabled = true
  button.textContent = root.dataset.translationLoadingLabel || 'Translating...'
  setStatus(status, '', 'muted')

  try {
    const response = await fetch(root.dataset.translationUrl, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': token || ''
      },
      body: JSON.stringify({
        translation: {
          source_locale: sourceLocale,
          target_locales: targetLocales,
          content_format: root.dataset.contentFormat || document.getElementById('post_content_format')?.value || 'html',
          content: content
        }
      })
    })
    const payload = await response.json()
    if (!response.ok) throw new Error(payload.error || payload.errors || 'Translation failed')

    const result = await waitForTranslation(payload.data?.status_url)
    const translations = result.translations || {}
    applyTranslations(root, translations)
    const label = root.dataset.translationDoneLabel || 'Translations filled.'
    const translatedLocales = Object.keys(translations)
    setStatus(status, `${label} ${(translatedLocales.length ? translatedLocales : targetLocales).join(', ').toUpperCase()}`, 'success')
  } catch (error) {
    setStatus(status, error.message || 'Translation failed.', 'danger')
  } finally {
    button.disabled = false
    button.textContent = originalText
  }
}

async function waitForTranslation(statusUrl) {
  if (!statusUrl) throw new Error('Translation status URL missing')

  while (true) {
    await delay(2500)

    const response = await fetch(statusUrl, {
      method: 'GET',
      headers: { 'Accept': 'application/json' }
    })
    const payload = await response.json()
    if (!response.ok) throw new Error(payload.error || payload.errors || 'Translation failed')

    const data = payload.data || {}
    if (data.status === 'completed') return data
    if (data.status === 'failed') throw new Error(data.error_message || 'Translation failed')
  }
}

function delay(ms) {
  return new Promise((resolve) => window.setTimeout(resolve, ms))
}

function activeLocale(root) {
  const activeTab = root.querySelector('[data-locale-tab].active')
  return activeTab?.dataset.localeTab || root.dataset.activeLocale || ''
}

function missingTargetLocales(root, sourceLocale) {
  return Array.from(root.querySelectorAll('[data-locale-panel]'))
    .map((panel) => panel.dataset.localePanel)
    .filter((locale) => locale && locale !== sourceLocale)
    .filter((locale) => localeIsCompletelyBlank(root, locale))
}

function localeIsCompletelyBlank(root, locale) {
  return FIELD_NAMES.every((fieldName) => isBlank(fieldValue(root, locale, fieldName)))
}

function collectLocaleContent(root, locale) {
  return FIELD_NAMES.reduce((memo, fieldName) => {
    const value = fieldValue(root, locale, fieldName)
    if (!isBlank(value)) memo[fieldName] = value
    return memo
  }, {})
}

function fieldValue(root, locale, fieldName) {
  if (fieldName === 'content_source') {
    const editor = editorForLocale(root, locale)
    if (editor) return editor.currentValue()
  }

  const field = root.querySelector(fieldSelector(locale, fieldName))
  return field?.value || ''
}

function applyTranslations(root, translations) {
  Object.entries(translations).forEach(([locale, fields]) => {
    if (!localeIsCompletelyBlank(root, locale)) return

    FIELD_NAMES.forEach((fieldName) => {
      if (!(fieldName in fields)) return

      const field = root.querySelector(fieldSelector(locale, fieldName))
      if (!field) return

      field.value = fields[fieldName] || ''
      field.dispatchEvent(new Event('input', { bubbles: true }))

      if (fieldName === 'content_source') {
        const editor = editorForLocale(root, locale)
        editor?.setValue(fields[fieldName] || '')
      }
    })
  })
}

function fieldSelector(locale, fieldName) {
  return `[name="post[${fieldName}_i18n][${locale}]"]`
}

function isBlank(value) {
  const text = String(value || '').trim()
  if (text.length === 0) return true

  const withoutEmptyHtml = text
    .replace(/<p>(\s|&nbsp;|<br\s*\/?>)*<\/p>/gi, '')
    .replace(/<br\s*\/?>/gi, '')
    .replace(/&nbsp;/gi, '')
    .replace(/\s+/g, '')

  return withoutEmptyHtml.length === 0
}

function editorForLocale(root, locale) {
  return root.__postEditor?.editors?.find((item) => item.locale === locale)
}

function setStatus(element, message, variant) {
  if (!element) return

  element.textContent = message
  element.classList.remove('text-muted', 'text-danger', 'text-success')
  element.classList.add(`text-${variant}`)
}

function init() {
  document.querySelectorAll('[data-post-translation]').forEach(initPostTranslation)
}

document.addEventListener('DOMContentLoaded', init)
document.addEventListener('turbo:load', init)
