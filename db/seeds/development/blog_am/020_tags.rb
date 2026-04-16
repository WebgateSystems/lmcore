# frozen_string_literal: true

log('  [Blog AM] Creating tags...')

blog_am_tags = %w[krym ukraina atr putin zelenskyy war freedom dzhemilev covid pandemia]

created = 0
blog_am_tags.each do |tag_name|
  Tag.find_or_create_by!(name: tag_name) do |tag|
    tag.slug = tag_name
    created += 1
  end
end

log("  [Blog AM] Ensured #{blog_am_tags.size} tags exist (#{created} newly created)")
