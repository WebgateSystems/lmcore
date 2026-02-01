# frozen_string_literal: true

return if Follow.exists? || Reaction.exists?

log('Creating Follows and Reactions...')

# Get users
users = User.where(username: %w[user1 user2 user3 user4 user5])
authors = User.where(username: %w[jan_kowalski olena_shevchenko jonas_kazlauskas])
posts = Post.where(status: 'published').limit(5)

# Create follows - users follow authors
users.each do |user|
  authors.each do |author|
    next if user == author

    Follow.create!(follower: user, followed: author)
  end
end

# Authors follow each other
authors.each do |author|
  authors.each do |other_author|
    next if author == other_author

    Follow.create!(follower: author, followed: other_author)
  end
end

log("  Created #{Follow.count} follows")

# Create reactions on posts
reaction_types = Reaction::TYPES # %w[like love haha wow sad angry]

posts.each do |post|
  users.sample(rand(2..4)).each do |user|
    Reaction.create!(
      user: user,
      reactable: post,
      reaction_type: reaction_types.sample
    )
  end
end

log("  Created #{Reaction.count} reactions")
