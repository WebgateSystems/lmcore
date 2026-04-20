# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserTheme, type: :model do
  let(:user) { create(:user) }
  let(:theme) { create(:theme) }
  let(:other_theme) { create(:theme) }

  describe "scopes" do
    it ".active returns only active records" do
      active = UserTheme.create!(user: user, theme: theme, active: true)
      _inactive = UserTheme.create!(user: user, theme: other_theme, active: false)

      expect(UserTheme.active).to contain_exactly(active)
    end

    it ".purchased returns only records with a purchased_at timestamp" do
      bought = UserTheme.create!(user: user, theme: theme, purchased_at: Time.current)
      _free = UserTheme.create!(user: user, theme: other_theme, purchased_at: nil)

      expect(UserTheme.purchased).to contain_exactly(bought)
    end
  end

  describe "#activate! / #deactivate!" do
    it "activates the record" do
      ut = UserTheme.create!(user: user, theme: theme, active: false)
      ut.activate!
      expect(ut.reload.active).to be true
    end

    it "deactivates the record" do
      ut = UserTheme.create!(user: user, theme: theme, active: true)
      ut.deactivate!
      expect(ut.reload.active).to be false
    end
  end

  describe "#purchase!" do
    it "stamps purchased_at when not yet purchased" do
      ut = UserTheme.create!(user: user, theme: theme)
      expect { ut.purchase! }.to change { ut.reload.purchased_at }.from(nil)
    end

    it "is a no-op when already purchased" do
      ut = UserTheme.create!(user: user, theme: theme, purchased_at: 2.days.ago)
      original = ut.purchased_at
      ut.purchase!
      expect(ut.reload.purchased_at).to be_within(1.second).of(original)
    end

    it "#purchased? reflects timestamp presence" do
      ut = UserTheme.new(purchased_at: nil)
      expect(ut.purchased?).to be false
      ut.purchased_at = Time.current
      expect(ut.purchased?).to be true
    end
  end

  describe "customizations" do
    it "reads and writes a single key" do
      ut = UserTheme.create!(user: user, theme: theme, customizations: {})
      ut.set_customization(:color, "#fff")
      ut.save!
      expect(ut.reload.customization("color")).to eq("#fff")
    end

    it "reset_customizations! clears the hash" do
      ut = UserTheme.create!(user: user, theme: theme, customizations: { "x" => 1 })
      ut.reset_customizations!
      expect(ut.reload.customizations).to eq({})
    end
  end

  describe "deactivating siblings on activation" do
    it "deactivates other themes for the same user when this one becomes active" do
      first = UserTheme.create!(user: user, theme: theme, active: true)
      second = UserTheme.create!(user: user, theme: other_theme, active: false)

      second.update!(active: true)

      expect(first.reload.active).to be false
      expect(second.reload.active).to be true
    end
  end
end
