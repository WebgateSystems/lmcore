# frozen_string_literal: true

ayder = User.find_by!(email: 'ayder@gmail.com')
return if ayder.posts.exists?

log('  [Blog AM] Creating posts...')

posts_data_file = File.join(__dir__, 'data', 'posts.yml')
posts_data = YAML.load_file(posts_data_file, permitted_classes: [ Time, Date, Symbol ])

posts_data.each do |raw|
  data = raw.deep_symbolize_keys

  category = ayder.categories.find_by(slug: data[:category_slug])
  tag_slugs = data[:tag_slugs] || []

  # Remap 'ua' locale key to 'uk' for Rails convention
  remap = ->(hash) { hash.transform_keys { |k| k == 'ua' ? 'uk' : k } }

  post = Post.new(
    author: ayder,
    category: category,
    slug: data[:slug],
    featured: data[:featured] || false,
    status: data[:status] || 'published',
    published_at: data[:published_at],
    published_by: ayder,
    comments_enabled: true,
    external_source: data[:source_name]
  )
  post.title_i18n = remap.call(data[:title] || {})
  post.subtitle_i18n = remap.call(data[:subtitle] || {})
  post.lead_i18n = remap.call(data[:lead] || {})
  post.content_i18n = remap.call(data[:content] || {})
  post.save!

  tag_slugs.each do |slug|
    tag = Tag.find_by(slug: slug)
    Tagging.create!(taggable: post, tag: tag) if tag
  end
end

log("  [Blog AM] Created #{ayder.posts.count} posts")
