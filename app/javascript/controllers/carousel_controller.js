import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]
  static values = {
    interval: { type: Number, default: 7000 }
  }

  connect() {
    this.currentIndex = 0
    this.cards = this.trackTarget.querySelectorAll('.partner-card')
    this.totalCards = this.cards.length
    this.cardsPerView = this.calculateCardsPerView()

    // Start auto-scroll
    this.startAutoScroll()

    // Handle resize
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)

    // Pause on hover
    this.element.addEventListener('mouseenter', () => this.stopAutoScroll())
    this.element.addEventListener('mouseleave', () => this.startAutoScroll())
  }

  disconnect() {
    this.stopAutoScroll()
    window.removeEventListener('resize', this.handleResize)
  }

  calculateCardsPerView() {
    const viewportWidth = window.innerWidth
    if (viewportWidth >= 1024) return 4
    if (viewportWidth >= 768) return 3
    if (viewportWidth >= 640) return 2
    return 1
  }

  handleResize() {
    this.cardsPerView = this.calculateCardsPerView()
    this.updatePosition()
  }

  get maxIndex() {
    return Math.max(0, this.totalCards - this.cardsPerView)
  }

  next() {
    if (this.currentIndex < this.maxIndex) {
      this.currentIndex++
    } else {
      this.currentIndex = 0
    }
    this.updatePosition()
    this.resetAutoScroll()
  }

  prev() {
    if (this.currentIndex > 0) {
      this.currentIndex--
    } else {
      this.currentIndex = this.maxIndex
    }
    this.updatePosition()
    this.resetAutoScroll()
  }

  updatePosition() {
    if (this.currentIndex > this.maxIndex) {
      this.currentIndex = this.maxIndex
    }
    // Calculate offset based on actual card width including gap
    const card = this.cards[0]
    if (card) {
      const cardStyle = window.getComputedStyle(card)
      const cardWidth = card.offsetWidth + parseFloat(cardStyle.marginLeft) + parseFloat(cardStyle.marginRight)
      const offset = this.currentIndex * cardWidth
      this.trackTarget.style.transform = `translateX(-${offset}px)`
    }
  }

  startAutoScroll() {
    if (this.autoScrollTimer) return
    this.autoScrollTimer = setInterval(() => {
      this.next()
    }, this.intervalValue)
  }

  stopAutoScroll() {
    if (this.autoScrollTimer) {
      clearInterval(this.autoScrollTimer)
      this.autoScrollTimer = null
    }
  }

  resetAutoScroll() {
    this.stopAutoScroll()
    this.startAutoScroll()
  }
}
