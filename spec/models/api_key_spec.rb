# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiKey, type: :model do
  let(:user) { create(:user) }
  let(:api_key) { create(:api_key, user: user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it "validates presence of name" do
      api_key = build(:api_key, user: user, name: nil)
      expect(api_key).not_to be_valid
      expect(api_key.errors[:name]).to be_present
    end

    it "generates key_digest and prefix automatically" do
      new_key = create(:api_key, user: user)
      expect(new_key.key_digest).to be_present
      expect(new_key.prefix).to be_present
    end

    it "validates uniqueness of key_digest at database level" do
      key1 = create(:api_key, user: user)
      # Insert directly to bypass callback and test database constraint
      expect {
        ApiKey.connection.execute(
          "INSERT INTO api_keys (id, user_id, name, key_digest, prefix, active, created_at, updated_at)
           VALUES ('#{SecureRandom.uuid}', '#{user.id}', 'Duplicate', '#{key1.key_digest}', 'dupprefix', true, NOW(), NOW())"
        )
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "scopes" do
    let!(:active_key) { create(:api_key, user: user, active: true) }
    let!(:inactive_key) { create(:api_key, user: user, active: false) }
    let!(:expired_key) { create(:api_key, user: user, active: true, expires_at: 1.day.ago) }

    describe ".active" do
      it "returns only active keys" do
        expect(described_class.active).to include(active_key, expired_key)
        expect(described_class.active).not_to include(inactive_key)
      end
    end

    describe ".inactive" do
      it "returns only inactive keys" do
        expect(described_class.inactive).to include(inactive_key)
        expect(described_class.inactive).not_to include(active_key)
      end
    end

    describe ".expired" do
      it "returns only expired keys" do
        expect(described_class.expired).to include(expired_key)
        expect(described_class.expired).not_to include(active_key)
      end
    end

    describe ".valid" do
      it "returns active and non-expired keys" do
        expect(described_class.valid).to include(active_key)
        expect(described_class.valid).not_to include(inactive_key, expired_key)
      end
    end
  end

  describe "#generate_key" do
    it "generates a raw key on create" do
      new_key = build(:api_key, user: user)
      expect(new_key.raw_key).to be_nil

      new_key.save!
      expect(new_key.raw_key).to be_present
      expect(new_key.raw_key.length).to eq(43) # Base64 encoded 32 bytes
    end

    it "generates a prefix from the raw key" do
      new_key = create(:api_key, user: user)
      expect(new_key.prefix).to eq(new_key.raw_key[0..7])
    end
  end

  describe "#authenticate" do
    it "returns true for correct key" do
      new_key = create(:api_key, user: user)
      expect(new_key.authenticate(new_key.raw_key)).to be true
    end

    it "returns false for incorrect key" do
      expect(api_key.authenticate("wrong_key")).to be false
    end
  end

  describe ".authenticate" do
    it "returns the api key for valid key" do
      new_key = create(:api_key, user: user)
      raw_key = new_key.raw_key

      found_key = described_class.authenticate(raw_key)
      expect(found_key).to eq(new_key)
    end

    it "returns nil for invalid key" do
      expect(described_class.authenticate("invalid_key_12345678")).to be_nil
    end

    it "returns nil for blank key" do
      expect(described_class.authenticate(nil)).to be_nil
      expect(described_class.authenticate("")).to be_nil
    end
  end

  describe "#regenerate!" do
    it "generates a new key" do
      old_prefix = api_key.prefix
      old_digest = api_key.key_digest

      new_raw_key = api_key.regenerate!

      expect(api_key.prefix).not_to eq(old_prefix)
      expect(api_key.key_digest).not_to eq(old_digest)
      expect(new_raw_key).to be_present
    end
  end

  describe "#revoke!" do
    it "sets active to false" do
      api_key.revoke!
      expect(api_key.active).to be false
    end
  end

  describe "#activate!" do
    it "sets active to true" do
      api_key.update!(active: false)
      api_key.activate!
      expect(api_key.active).to be true
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      api_key.update!(expires_at: 1.day.ago)
      expect(api_key.expired?).to be true
    end

    it "returns false when expires_at is in the future" do
      api_key.update!(expires_at: 1.day.from_now)
      expect(api_key.expired?).to be false
    end

    it "returns false when expires_at is nil" do
      api_key.update!(expires_at: nil)
      expect(api_key.expired?).to be false
    end
  end

  describe "#valid_key?" do
    it "returns true for active, non-expired key" do
      api_key.update!(active: true, expires_at: 1.day.from_now)
      expect(api_key.valid_key?).to be true
    end

    it "returns false for inactive key" do
      api_key.update!(active: false)
      expect(api_key.valid_key?).to be false
    end

    it "returns false for expired key" do
      api_key.update!(expires_at: 1.day.ago)
      expect(api_key.valid_key?).to be false
    end
  end

  describe "#has_scope?" do
    it "returns true when scope is included" do
      api_key.update!(scopes: [ "read", "write" ])
      expect(api_key.has_scope?("read")).to be true
    end

    it "returns false when scope is not included" do
      api_key.update!(scopes: [ "read" ])
      expect(api_key.has_scope?("write")).to be false
    end

    it "returns true when wildcard scope is present" do
      api_key.update!(scopes: [ "*" ])
      expect(api_key.has_scope?("anything")).to be true
    end
  end

  describe "#masked_key" do
    it "returns masked version of the key" do
      expect(api_key.masked_key).to match(/^#{api_key.prefix}\*{24}$/)
    end
  end
end
