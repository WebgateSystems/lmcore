# frozen_string_literal: true

log('=== Loading Blog AM (Ayder Muzhdabaev) seeds ===')

Dir[Rails.root.join('db', 'seeds', 'development', 'blog_am', '*.rb')].sort.each { |seed| load seed }

log('=== Blog AM seeds loaded ===')
