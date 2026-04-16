# frozen_string_literal: true

ayder = User.find_by!(email: 'ayder@gmail.com')
first_post = ayder.posts.order(:created_at).first
return unless first_post
return if first_post.comments.exists?

log('  [Blog AM] Creating comments...')

comment1 = Comment.create!(
  user: ayder,
  commentable: first_post,
  content: 'Кроме этого "мирного" ультиматума, Кремль продолжает наступление – пока медийное – на крымском направлении. Ему не дает покоя то, что Верховная Рада, Правительство, Президент, наконец, разблокировали государственную поддержку телеканалу ATR, что про воду в Крым больше нигде на официальном уровне не говорится, как и о снятии с России каких-либо санкций.',
  status: 'approved',
  approved_at: Time.current,
  approved_by: ayder
)

comment2 = Comment.create!(
  user: ayder,
  commentable: first_post,
  content: 'То есть – задание, поставленное Кремлем своим агентам влияния и медиадиверсантам в Украине, провалено. Но "боевая" задача для них осталась. А Меджлис крымскотатарского народа, телеканал ATR и лично его гендиректор Ленур Ислямов как координатор Гражданской блокады Крыма 2015 года являются теми важнейшими мишенями.',
  status: 'approved',
  approved_at: Time.current,
  approved_by: ayder
)

Comment.create!(
  user: ayder,
  commentable: first_post,
  parent: comment1,
  content: 'Дякую за коментар! Ви абсолютно праві щодо медійного наступу.',
  status: 'approved',
  approved_at: Time.current,
  approved_by: ayder
)

Comment.create!(
  commentable: first_post,
  guest_name: 'Павло Бабченко',
  guest_email: 'pavlo@example.com',
  content: 'Поэтому сегодня на пресс-конференции президента представитель телеканализации под названием "НАШ" публично протранслировал Владимиру Зеленскому ложь о том, что якобы Ленур Ислямов – гражданин России.',
  status: 'approved',
  approved_at: Time.current,
  approved_by: ayder
)

log("  [Blog AM] Created #{first_post.comments.count} comments")
