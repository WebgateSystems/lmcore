# frozen_string_literal: true

return if Comment.exists?

log('Creating Comments...')

# Get published posts
posts = Post.where(status: 'published')
users = User.where(username: %w[user1 user2 user3 user4 user5])
authors = User.where(username: %w[jan_kowalski olena_shevchenko jonas_kazlauskas])
all_commenters = users + authors

sample_comments = {
  'en' => [
    'Great article! Thanks for sharing.',
    'Very insightful analysis.',
    'I partially disagree, but appreciate the perspective.',
    'This is exactly what more people need to understand.',
    'Could you elaborate on this point?',
    "Important topic that doesn't get enough attention."
  ],
  'pl' => [
    'Świetny artykuł! Dziękuję za podzielenie się.',
    'Bardzo wnikliwa analiza.',
    'Częściowo się nie zgadzam, ale doceniam perspektywę.',
    'To jest dokładnie to, co więcej ludzi powinno zrozumieć.',
    'Czy mógłbyś rozwinąć ten wątek?',
    'Ważny temat, który nie dostaje wystarczającej uwagi.'
  ],
  'uk' => [
    'Чудова стаття! Дякую за публікацію.',
    'Дуже проникливий аналіз.',
    'Частково не погоджуюсь, але ціную точку зору.',
    'Це саме те, що більше людей повинні зрозуміти.',
    'Чи можете ви детальніше розповісти про це?',
    'Важлива тема, яка не отримує достатньо уваги.'
  ],
  'lt' => [
    'Puikus straipsnis! Ačiū, kad pasidalinote.',
    'Labai įžvalgi analizė.',
    'Iš dalies nesutinku, bet vertinu požiūrį.',
    'Būtent tai daugiau žmonių turėtų suprasti.',
    'Ar galėtumėte plačiau paaiškinti šį punktą?',
    'Svarbi tema, kuriai skiriama per mažai dėmesio.'
  ]
}

reply_comments = [
  'I agree with you.',
  'Interesting point!',
  'Thanks for your comment.',
  'Good observation.',
  'You make a valid point.',
  'I see it differently, but respect your view.'
]

posts.each do |post|
  # Determine locale from title
  locale = post.title_i18n.keys.first || 'en'
  comments_for_locale = sample_comments[locale] || sample_comments['en']

  # Add 2-4 comments per post
  rand(2..4).times do
    commenter = all_commenters.sample
    next unless commenter

    comment = Comment.create!(
      user: commenter,
      commentable: post,
      content: comments_for_locale.sample,
      status: 'approved',
      approved_at: Time.current
    )

    # Sometimes add a reply (1 in 3 chance)
    next unless rand(3).zero?

    reply_author = all_commenters.sample
    next unless reply_author

    Comment.create!(
      user: reply_author,
      commentable: post,
      parent: comment,
      content: reply_comments.sample,
      status: 'approved',
      approved_at: Time.current
    )
  end
end

log("Created #{Comment.count} comments")
