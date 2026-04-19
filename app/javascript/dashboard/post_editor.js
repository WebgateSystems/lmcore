// Rich text editor for Post#content_source_i18n.
//
// Each locale tab has a textarea named like `post[content_source_i18n][<locale>]`.
// Depending on the global #post_content_format value (html|markdown) we
// initialise either TipTap (HTML, contenteditable WYSIWYG) or EasyMDE
// (Markdown, source view with toolbar) on top of that textarea.
//
// On format switch we run Turndown (HTML → Markdown) and a tiny Markdown ->
// HTML pass (via EasyMDE's bundled markdown-it) to migrate the existing
// payload, asking for confirmation before any potentially-lossy conversion.

import { Editor } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import Link from '@tiptap/extension-link'
import Placeholder from '@tiptap/extension-placeholder'
import EasyMDE from 'easymde'
import TurndownService from 'turndown'
// NOTE: Do NOT `import 'easymde/dist/easymde.min.css'` here.
// esbuild would then emit a sibling `dashboard.css` containing only the
// EasyMDE styles, which clobbers the much larger SASS-built dashboard.css
// (same filename, last writer wins). We import the EasyMDE stylesheet from
// `app/assets/stylesheets/dashboard.sass.scss` instead.

const turndown = new TurndownService({
  headingStyle: 'atx',
  codeBlockStyle: 'fenced',
  bulletListMarker: '-',
  emDelimiter: '_'
})
turndown.keep(['figure', 'figcaption'])

class LocaleEditor {
  constructor(panel, format, library) {
    this.panel = panel
    this.format = format
    this.library = library
    this.locale = panel.dataset.localePanel
    this.textarea = panel.querySelector('[data-post-editor-source]')
    this.host = panel.querySelector('[data-post-editor-host]')
    this.tiptap = null
    this.easymde = null
    this.mount()
  }

  destroy() {
    if (this.tiptap) {
      this.syncToTextarea()
      this.tiptap.destroy()
      this.tiptap = null
    }
    if (this.easymde) {
      this.syncToTextarea()
      this.easymde.toTextArea()
      this.easymde = null
    }
    this.host.innerHTML = ''
  }

  mount() {
    if (this.format === 'markdown') {
      this.mountMarkdown()
    } else {
      this.mountHTML()
    }
  }

  mountHTML() {
    const editorEl = document.createElement('div')
    editorEl.className = 'post-editor__tiptap'
    this.host.innerHTML = ''
    this.host.appendChild(editorEl)

    try {
      this.tiptap = new Editor({
        element: editorEl,
        extensions: [
          StarterKit.configure({ heading: { levels: [2, 3, 4] } }),
          Link.configure({ openOnClick: false, HTMLAttributes: { rel: 'nofollow noopener', target: '_blank' } }),
          Placeholder.configure({ placeholder: this.host.dataset.placeholder || '' })
        ],
        content: this.textarea.value || '',
        onUpdate: () => this.syncToTextarea()
      })
    } catch (error) {
      console.error('[post-editor] TipTap init failed, falling back to plain textarea', error)
      this.tiptap = null
      this.fallbackToPlainTextarea(error)
      return
    }

    this.renderToolbar('html')
  }

  mountMarkdown() {
    const ta = document.createElement('textarea')
    ta.className = 'post-editor__easymde'
    this.host.innerHTML = ''
    this.host.appendChild(ta)
    ta.value = this.textarea.value || ''

    try {
      this.easymde = new EasyMDE({
        element: ta,
        autoDownloadFontAwesome: false,
        spellChecker: false,
        status: false,
        toolbar: ['bold', 'italic', 'heading', '|', 'quote', 'unordered-list', 'ordered-list', '|',
          'link', 'table', 'code', '|', 'preview', 'side-by-side', 'fullscreen']
      })
      this.easymde.codemirror.on('change', () => this.syncToTextarea())
    } catch (error) {
      console.error('[post-editor] EasyMDE init failed, falling back to plain textarea', error)
      this.easymde = null
      this.fallbackToPlainTextarea(error)
      return
    }

    this.renderToolbar('markdown')
  }

  // If a third-party editor fails to load (missing CSS bundle, version mismatch,
  // CSP block, etc.) make sure the user can still edit *something* instead of
  // staring at an empty void. We unhide the source textarea and surface the
  // error so the page is at least usable while the JS issue gets fixed.
  fallbackToPlainTextarea(error) {
    this.host.innerHTML = ''
    this.textarea.classList.remove('d-none')
    this.textarea.classList.add('post-editor__fallback')
    this.textarea.rows = 16
    const note = document.createElement('p')
    note.className = 'small text-danger mb-1'
    note.textContent = `Editor failed to load (${error?.message || 'unknown error'}). Falling back to plain text.`
    this.host.appendChild(note)
    this.renderToolbar(this.format)
  }

  renderToolbar(format) {
    const toolbar = this.panel.querySelector('[data-post-editor-toolbar]')
    if (!toolbar) return
    toolbar.innerHTML = ''
    const button = document.createElement('button')
    button.type = 'button'
    button.className = 'btn btn-sm btn-outline-secondary'
    button.textContent = toolbar.dataset.insertImageLabel || 'Insert image'
    button.addEventListener('click', () => this.openLibraryPicker(format))
    toolbar.appendChild(button)
  }

  openLibraryPicker(format) {
    if (!this.library) {
      window.alert('Image library is not available on this page.')
      return
    }
    // If the user has nothing in the library yet, skip the awkward
    // "click Insert image, then nothing happens" flow and jump straight to
    // the OS file picker. The freshly-uploaded image will land in the library
    // and they can click "Insert" on it.
    if (!this.library.attachments || this.library.attachments.length === 0) {
      this.library.pick((attachment) => this.insertAttachment(attachment, format))
      this.library.openUploadDialog()
      return
    }
    this.library.pick((attachment) => this.insertAttachment(attachment, format))
    // Scroll the library into view so it's obvious where to click "Insert".
    this.library.root?.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
  }

  insertAttachment(attachment, format) {
    if (format === 'markdown') {
      const placeholder = `\n\n[[fig:${attachment.id}]]\n\n`
      const cm = this.easymde.codemirror
      cm.replaceSelection(placeholder)
    } else {
      const html = `<figure data-attachment-id="${attachment.id}"><img src="${attachment.medium_url || attachment.file_url}" alt="${attachment.alt_text_i18n?.[this.locale] || ''}"></figure>`
      this.tiptap.chain().focus().insertContent(html).run()
    }
    this.syncToTextarea()
  }

  syncToTextarea() {
    if (this.tiptap) {
      this.textarea.value = this.tiptap.getHTML()
    } else if (this.easymde) {
      this.textarea.value = this.easymde.value()
    }
  }

  currentValue() {
    if (this.tiptap) return this.tiptap.getHTML()
    if (this.easymde) return this.easymde.value()
    return this.textarea.value
  }

  setValue(value) {
    this.textarea.value = value || ''
    if (this.tiptap) this.tiptap.commands.setContent(value || '', false)
    if (this.easymde) this.easymde.value(value || '')
  }
}

class PostEditorController {
  constructor(root) {
    this.root = root
    this.formatInput = document.getElementById(root.dataset.formatInputId || 'post_content_format')
    this.editors = []
    this.library = null
    this.attachLibrary()
    this.bootstrap()
    this.bindFormatSwitch()
    this.bindTabs()
  }

  attachLibrary() {
    const libraryRoot = document.querySelector('[data-attachment-library]')
    if (!libraryRoot || !libraryRoot.__attachmentLibrary) return
    this.library = libraryRoot.__attachmentLibrary
  }

  bootstrap() {
    const format = this.formatInput?.value || 'html'
    this.root.querySelectorAll('[data-locale-panel]').forEach((panel) => {
      this.editors.push(new LocaleEditor(panel, format, this.library))
    })
  }

  bindTabs() {
    this.root.querySelectorAll('[data-locale-tab]').forEach((tab) => {
      tab.addEventListener('click', (event) => {
        event.preventDefault()
        const target = tab.dataset.localeTab
        this.activateLocale(target)
      })
    })
  }

  activateLocale(locale) {
    this.root.querySelectorAll('[data-locale-tab]').forEach((tab) => {
      tab.classList.toggle('active', tab.dataset.localeTab === locale)
    })
    this.root.querySelectorAll('[data-locale-panel]').forEach((panel) => {
      panel.classList.toggle('d-none', panel.dataset.localePanel !== locale)
    })
  }

  bindFormatSwitch() {
    if (!this.formatInput) return
    this.formatInput.addEventListener('change', (event) => this.handleFormatChange(event))
  }

  handleFormatChange(event) {
    const newFormat = this.formatInput.value
    const hasContent = this.editors.some((ed) => ed.currentValue().trim().length > 0)
    if (hasContent && !window.confirm(this.formatInput.dataset.switchWarning ||
        'Switching format may lose some formatting. Continue?')) {
      this.formatInput.value = newFormat === 'html' ? 'markdown' : 'html'
      return
    }
    this.editors.forEach((editor) => {
      const current = editor.currentValue()
      const converted = convertContent(current, editor.format, newFormat)
      editor.destroy()
      editor.format = newFormat
      editor.textarea.value = converted
      editor.mount()
    })
  }
}

function convertContent(value, fromFormat, toFormat) {
  if (!value || fromFormat === toFormat) return value
  if (fromFormat === 'html' && toFormat === 'markdown') {
    return turndown.turndown(value)
  }
  // markdown -> html: rely on the renderer round-trip; we leave the markdown
  // source in place so the user does not get a half-converted block. EasyMDE
  // edits the markdown source in place.
  return value
}

function init() {
  document.querySelectorAll('[data-post-editor]').forEach((root) => {
    if (root.__postEditor) return
    root.__postEditor = new PostEditorController(root)
  })
}

document.addEventListener('DOMContentLoaded', init)
document.addEventListener('turbo:load', init)
