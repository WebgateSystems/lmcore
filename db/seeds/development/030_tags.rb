# frozen_string_literal: true

return unless Tag.count.zero?

log('Creating Tags...')

# Common tags for the platform
tags = [
  # General
  'breaking-news', 'analysis', 'interview', 'investigation', 'opinion', 'editorial',
  # Politics
  'ukraine', 'russia', 'poland', 'lithuania', 'eu', 'nato', 'usa', 'china',
  'democracy', 'elections', 'corruption', 'war-crimes', 'sanctions', 'diplomacy',
  # Technology
  'privacy', 'security', 'open-source', 'censorship', 'surveillance', 'encryption',
  'social-media', 'big-tech', 'disinformation', 'fact-check',
  # Society
  'human-rights', 'freedom-of-speech', 'refugees', 'veterans', 'ptsd',
  'civil-society', 'activism', 'protests',
  # Culture
  'art', 'literature', 'cinema', 'music', 'theatre', 'history',
  # Media
  'journalism', 'media', 'propaganda', 'truth', 'transparency'
]

tags.each do |tag_name|
  Tag.create!(name: tag_name, slug: tag_name)
end

log("Created #{Tag.count} tags")
