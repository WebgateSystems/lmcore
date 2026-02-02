import { Controller } from "@hotwired/stimulus"

// Video controller
// Manages video playback for hero section
export default class extends Controller {
  static targets = ["player", "source"]
  static values = {
    locale: { type: String, default: "en" }
  }

  connect() {
    // Video paths for different locales
    this.videoPaths = {
      en: "/videos/opener-en.mp4",
      pl: "/videos/opener-pl.mp4",
      uk: "/videos/opener-uk.mp4"
    }
  }

  play(event) {
    event.preventDefault()

    const videoPath = this.videoPaths[this.localeValue] || this.videoPaths.en

    // Set video source
    if (this.hasSourceTarget && this.hasPlayerTarget) {
      this.sourceTarget.src = videoPath
      this.playerTarget.load()
      this.playerTarget.classList.add("active")
      this.playerTarget.play()

      // Hide placeholder
      this.element.querySelector(".video-poster")?.classList.add("hidden")
    }
  }
}
