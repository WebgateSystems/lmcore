# frozen_string_literal: true

RSpec.shared_examples 'sluggable' do
  describe 'slug generation' do
    it 'generates a slug before validation' do
      record = build(described_class.name.underscore.to_sym)
      record.slug = nil
      record.valid?
      expect(record.slug).to be_present
    end

    it 'validates slug format' do
      record = build(described_class.name.underscore.to_sym, slug: 'Invalid Slug!')
      expect(record).not_to be_valid
      expect(record.errors[:slug]).to be_present
    end

    it 'validates slug presence' do
      record = build(described_class.name.underscore.to_sym, slug: nil)
      # Let before_validation callback run
      record.valid?
      # Slug should have been generated
      expect(record.slug).to be_present
    end
  end
end

RSpec.shared_examples 'translatable' do |*attributes|
  attributes.each do |attr|
    describe "##{attr}" do
      it "returns the value for the current locale" do
        record = build(described_class.name.underscore.to_sym)
        record.send("#{attr}_i18n=", { 'en' => 'English', 'pl' => 'Polish' })

        I18n.with_locale(:en) do
          expect(record.send(attr)).to eq('English')
        end
      end

      it "falls back to default locale when current locale is missing" do
        record = build(described_class.name.underscore.to_sym)
        record.send("#{attr}_i18n=", { 'en' => 'English' })

        I18n.with_locale(:pl) do
          expect(record.send(attr)).to eq('English')
        end
      end
    end
  end
end

RSpec.shared_examples 'publishable' do
  describe 'state machine' do
    it 'starts in draft state' do
      record = build(described_class.name.underscore.to_sym)
      expect(record.status).to eq('draft')
    end

    it 'can be submitted for review' do
      record = create(described_class.name.underscore.to_sym, status: 'draft')
      record.submit!
      expect(record.status).to eq('pending')
    end

    it 'can be published' do
      record = create(described_class.name.underscore.to_sym, status: 'draft')
      record.publish!
      expect(record.status).to eq('published')
      expect(record.published_at).to be_present
    end

    it 'can be archived' do
      record = create(described_class.name.underscore.to_sym)
      record.publish!
      record.archive!
      expect(record.status).to eq('archived')
    end
  end

  describe 'scopes' do
    it 'filters by status' do
      draft = create(described_class.name.underscore.to_sym, status: 'draft')
      published = create(described_class.name.underscore.to_sym, status: 'published', published_at: Time.current)

      expect(described_class.draft).to include(draft)
      expect(described_class.published).to include(published)
    end
  end
end

RSpec.shared_examples 'taggable' do
  describe 'tagging' do
    it 'can have tags' do
      record = create(described_class.name.underscore.to_sym)
      record.tag_list = 'ruby, rails, testing'
      record.save!

      expect(record.tags.count).to eq(3)
      expect(record.tag_list).to include('ruby')
    end

    it 'can add individual tags' do
      record = create(described_class.name.underscore.to_sym)
      record.add_tag('new-tag')

      expect(record.has_tag?('new-tag')).to be true
    end

    it 'can remove tags' do
      record = create(described_class.name.underscore.to_sym)
      record.tag_list = 'ruby, rails'
      record.save!
      record.remove_tag('ruby')

      expect(record.has_tag?('ruby')).to be false
      expect(record.has_tag?('rails')).to be true
    end
  end
end

RSpec.shared_examples 'reactable' do
  describe 'reactions' do
    let(:user) { create(:user) }
    let(:record) { create(described_class.name.underscore.to_sym) }

    it 'can receive reactions' do
      record.react!(user, 'like')
      expect(record.reacted_by?(user)).to be true
    end

    it 'updates reaction type' do
      record.react!(user, 'like')
      record.react!(user, 'love')

      expect(record.reactions.find_by(user: user).reaction_type).to eq('love')
    end

    it 'can remove reactions' do
      record.react!(user, 'like')
      record.unreact!(user)

      expect(record.reacted_by?(user)).to be false
    end

    it 'provides reactions summary' do
      user2 = create(:user)
      record.react!(user, 'like')
      record.react!(user2, 'like')

      expect(record.reactions_summary).to eq({ 'like' => 2 })
    end
  end
end

RSpec.shared_examples 'commentable' do
  describe 'comments' do
    let(:user) { create(:user) }
    let(:record) { create(described_class.name.underscore.to_sym) }

    it 'can receive comments' do
      comment = record.add_comment(content: 'Test comment', user: user)
      expect(comment).to be_persisted
      expect(record.comments).to include(comment)
    end

    it 'can receive guest comments' do
      comment = record.add_comment(
        content: 'Guest comment',
        guest_name: 'Guest',
        guest_email: 'guest@example.com'
      )
      expect(comment).to be_persisted
    end

    it 'returns root comments' do
      root = record.add_comment(content: 'Root', user: user)
      reply = root.reply_to(content: 'Reply', user: user)

      expect(record.root_comments).to include(root)
      expect(record.root_comments).not_to include(reply)
    end
  end
end
