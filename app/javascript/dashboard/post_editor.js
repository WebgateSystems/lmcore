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
    this.toolbarControls = []
    this.sourceViewEnabled = false
    this.sourceTextarea = null
    this.tiptapElement = null
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
    this.sourceViewEnabled = false
    this.sourceTextarea = null
    this.tiptapElement = null
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
    this.textarea.classList.add('d-none')
    this.textarea.classList.remove('post-editor__fallback')
    const editorEl = document.createElement('div')
    editorEl.className = 'post-editor__tiptap'
    this.tiptapElement = editorEl
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
        onUpdate: () => this.syncToTextarea(),
        onSelectionUpdate: () => this.refreshToolbarState(),
        onTransaction: () => this.refreshToolbarState()
      })
    } catch (error) {
      console.error('[post-editor] TipTap init failed, falling back to plain textarea', error)
      this.tiptap = null
      this.fallbackToPlainTextarea(error)
      return
    }

    this.renderToolbar('html')
    this.refreshToolbarState()
  }

  mountMarkdown() {
    this.textarea.classList.add('d-none')
    this.textarea.classList.remove('post-editor__fallback')
    const ta = document.createElement('textarea')
    ta.className = 'post-editor__easymde'
    this.host.innerHTML = ''
    this.host.appendChild(ta)
    ta.value = this.textarea.value || ''

    try {
      const mdButton = (name, action, icon, title, extra = {}) => ({ name, action, icon, title, ...extra })
      this.easymde = new EasyMDE({
        element: ta,
        autoDownloadFontAwesome: false,
        spellChecker: false,
        status: false,
        toolbar: [
          mdButton('bold', EasyMDE.toggleBold, '<i class="bi bi-type-bold"></i>', 'Bold'),
          mdButton('italic', EasyMDE.toggleItalic, '<i class="bi bi-type-italic"></i>', 'Italic'),
          mdButton('heading-1', EasyMDE.toggleHeading1, '<i class="bi bi-type-h1"></i>', 'Heading 1'),
          mdButton('heading-2', EasyMDE.toggleHeading2, '<i class="bi bi-type-h2"></i>', 'Heading 2'),
          mdButton('heading-3', EasyMDE.toggleHeading3, '<i class="bi bi-type-h3"></i>', 'Heading 3'),
          '|',
          mdButton('quote', EasyMDE.toggleBlockquote, '<i class="bi bi-blockquote-left"></i>', 'Quote'),
          mdButton('unordered-list', EasyMDE.toggleUnorderedList, '<i class="bi bi-list-ul"></i>', 'Bulleted list'),
          mdButton('ordered-list', EasyMDE.toggleOrderedList, '<i class="bi bi-list-ol"></i>', 'Numbered list'),
          '|',
          mdButton('link', EasyMDE.drawLink, '<i class="bi bi-link-45deg"></i>', 'Insert link'),
          mdButton('insert-table', EasyMDE.drawTable, '<i class="bi bi-table"></i>', 'Insert table'),
          mdButton('code', EasyMDE.toggleCodeBlock, '<i class="bi bi-code-slash"></i>', 'Code block'),
          '|',
          mdButton('preview', EasyMDE.togglePreview, '<i class="bi bi-eye"></i>', 'Preview', { noDisable: true }),
          mdButton('side-by-side', EasyMDE.toggleSideBySide, '<i class="bi bi-layout-split"></i>', 'Side by side', { noDisable: true }),
          mdButton('fullscreen', EasyMDE.toggleFullScreen, '<i class="bi bi-arrows-fullscreen"></i>', 'Fullscreen', { noDisable: true })
        ]
      })
      this.easymde.codemirror.on('change', () => this.syncToTextarea())
    } catch (error) {
      console.error('[post-editor] EasyMDE init failed, falling back to plain textarea', error)
      this.easymde = null
      this.fallbackToPlainTextarea(error)
      return
    }

    this.renderToolbar('markdown')
    this.refreshToolbarState()
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
    this.toolbarControls = []

    if (format === 'html' && this.tiptap) {
      const addControl = ({ label, command, isActive, canRun }) => {
        const button = document.createElement('button')
        button.type = 'button'
        button.className = 'btn btn-sm btn-outline-secondary post-editor__tool-btn'
        button.textContent = label
        button.addEventListener('click', (event) => {
          event.preventDefault()
          command()
          this.refreshToolbarState()
        })
        toolbar.appendChild(button)
        this.toolbarControls.push({ button, isActive, canRun })
      }

      const separator = () => {
        const spacer = document.createElement('span')
        spacer.className = 'post-editor__toolbar-separator'
        toolbar.appendChild(spacer)
      }

      addControl({
        label: toolbar.dataset.boldLabel || 'B',
        command: () => this.tiptap.chain().focus().toggleBold().run(),
        isActive: () => this.tiptap.isActive('bold'),
        canRun: () => this.tiptap.can().chain().focus().toggleBold().run()
      })
      addControl({
        label: toolbar.dataset.italicLabel || 'I',
        command: () => this.tiptap.chain().focus().toggleItalic().run(),
        isActive: () => this.tiptap.isActive('italic'),
        canRun: () => this.tiptap.can().chain().focus().toggleItalic().run()
      })
      separator()
      addControl({
        label: toolbar.dataset.h2Label || 'H2',
        command: () => this.tiptap.chain().focus().toggleHeading({ level: 2 }).run(),
        isActive: () => this.tiptap.isActive('heading', { level: 2 }),
        canRun: () => this.tiptap.can().chain().focus().toggleHeading({ level: 2 }).run()
      })
      addControl({
        label: toolbar.dataset.h3Label || 'H3',
        command: () => this.tiptap.chain().focus().toggleHeading({ level: 3 }).run(),
        isActive: () => this.tiptap.isActive('heading', { level: 3 }),
        canRun: () => this.tiptap.can().chain().focus().toggleHeading({ level: 3 }).run()
      })
      separator()
      addControl({
        label: toolbar.dataset.bulletListLabel || 'List',
        command: () => this.tiptap.chain().focus().toggleBulletList().run(),
        isActive: () => this.tiptap.isActive('bulletList'),
        canRun: () => this.tiptap.can().chain().focus().toggleBulletList().run()
      })
      addControl({
        label: toolbar.dataset.orderedListLabel || '1.',
        command: () => this.tiptap.chain().focus().toggleOrderedList().run(),
        isActive: () => this.tiptap.isActive('orderedList'),
        canRun: () => this.tiptap.can().chain().focus().toggleOrderedList().run()
      })
      addControl({
        label: toolbar.dataset.quoteLabel || 'Quote',
        command: () => this.tiptap.chain().focus().toggleBlockquote().run(),
        isActive: () => this.tiptap.isActive('blockquote'),
        canRun: () => this.tiptap.can().chain().focus().toggleBlockquote().run()
      })
      separator()
      addControl({
        label: toolbar.dataset.linkLabel || 'Link',
        command: () => this.setLinkFromPrompt(toolbar.dataset.linkPrompt || 'Paste URL'),
        isActive: () => this.tiptap.isActive('link'),
        canRun: () => this.tiptap.can().chain().focus().setLink({ href: 'https://example.com' }).run()
      })
      addControl({
        label: toolbar.dataset.unlinkLabel || 'Unlink',
        command: () => this.tiptap.chain().focus().unsetLink().run(),
        isActive: () => false,
        canRun: () => this.tiptap.isActive('link')
      })
      separator()
      addControl({
        label: toolbar.dataset.undoLabel || 'Undo',
        command: () => this.tiptap.chain().focus().undo().run(),
        isActive: () => false,
        canRun: () => this.tiptap.can().chain().focus().undo().run()
      })
      addControl({
        label: toolbar.dataset.redoLabel || 'Redo',
        command: () => this.tiptap.chain().focus().redo().run(),
        isActive: () => false,
        canRun: () => this.tiptap.can().chain().focus().redo().run()
      })
      separator()
      addControl({
        label: toolbar.dataset.sourceLabel || 'Source',
        command: () => this.toggleSourceView(),
        isActive: () => this.sourceViewEnabled,
        canRun: () => true
      })
    }

    if (this.library) {
      const button = document.createElement('button')
      button.type = 'button'
      button.className = 'btn btn-sm btn-outline-secondary post-editor__tool-btn'
      button.textContent = toolbar.dataset.insertImageLabel || 'Insert image'
      button.addEventListener('click', () => this.openLibraryPicker(format))
      toolbar.appendChild(button)
    }
  }

  setLinkFromPrompt(promptLabel) {
    if (!this.tiptap) return
    const previousUrl = this.tiptap.getAttributes('link').href || ''
    const input = window.prompt(promptLabel, previousUrl)
    if (input === null) return
    const href = input.trim()
    if (href.length === 0) {
      this.tiptap.chain().focus().unsetLink().run()
      return
    }
    this.tiptap.chain().focus().extendMarkRange('link').setLink({ href }).run()
  }

  refreshToolbarState() {
    if (!this.toolbarControls.length) return
    this.toolbarControls.forEach(({ button, isActive, canRun }) => {
      const active = typeof isActive === 'function' ? Boolean(isActive()) : false
      const enabled = this.sourceViewEnabled ? active : (typeof canRun === 'function' ? Boolean(canRun()) : true)
      button.classList.toggle('is-active', active)
      button.disabled = !enabled
    })
  }

  toggleSourceView() {
    if (!this.tiptap || !this.tiptapElement) return
    if (this.sourceViewEnabled) {
      const html = this.sourceTextarea ? this.sourceTextarea.value : this.textarea.value
      this.tiptap.commands.setContent(html || '', false)
      this.textarea.value = html || ''
      this.host.innerHTML = ''
      this.host.appendChild(this.tiptapElement)
      this.sourceTextarea = null
      this.sourceViewEnabled = false
      this.refreshToolbarState()
      return
    }

    this.syncToTextarea()
    const source = document.createElement('textarea')
    source.className = 'post-editor__source-view form-control'
    source.rows = 16
    source.value = this.textarea.value || ''
    source.addEventListener('input', () => {
      const value = source.value || ''
      this.textarea.value = value
      this.tiptap.commands.setContent(value, false)
    })

    this.host.innerHTML = ''
    this.host.appendChild(source)
    this.sourceTextarea = source
    this.sourceViewEnabled = true
    this.refreshToolbarState()
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
