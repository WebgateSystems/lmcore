# frozen_string_literal: true

require "rails_helper"

RSpec.describe Theme, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }

    it "validates uniqueness of slug" do
      create(:theme, slug: "uniq-theme-slug")
      duplicate = build(:theme, slug: "uniq-theme-slug")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to be_present
    end

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[inactive active default]) }
    it { is_expected.to validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0).only_integer }

    it "requires version in semver format" do
      theme = build(:theme, version: "1.0")
      expect(theme).not_to be_valid
      expect(theme.errors[:version]).to be_present
    end

    it "accepts a valid semver version" do
      expect(build(:theme, version: "2.13.4")).to be_valid
    end
  end

  describe "scopes" do
    let!(:active)   { create(:theme, status: "active") }
    let!(:default_theme) { create(:theme, :default, slug: "default-theme") }
    let!(:inactive) { create(:theme, :inactive) }
    let!(:premium)  { create(:theme, :premium) }
    let!(:system_theme) { create(:theme, :system) }

    it ".active includes both 'active' and 'default'" do
      expect(Theme.active).to include(active, default_theme)
      expect(Theme.active).not_to include(inactive)
    end

    it ".inactive returns only inactive themes" do
      expect(Theme.inactive).to contain_exactly(inactive)
    end

    it ".system_themes returns only is_system" do
      expect(Theme.system_themes).to include(default_theme, system_theme)
    end

    it ".premium / .free split by is_premium" do
      expect(Theme.premium).to include(premium)
      expect(Theme.free).to include(active, inactive)
    end

    it ".ordered orders by name asc" do
      expect(Theme.ordered.to_a).to eq(Theme.all.order(name: :asc).to_a)
    end
  end

  describe ".default_theme" do
    it "prefers the explicit 'default' status" do
      explicit = create(:theme, :default, slug: "default-explicit")
      create(:theme, :system, status: "active")

      expect(Theme.default_theme).to eq(explicit)
    end

    it "falls back to the first system+active theme if nothing is marked default" do
      system_active = create(:theme, :system, status: "active", name: "Aaa")
      expect(Theme.default_theme).to eq(system_active)
    end
  end

  describe "price helpers" do
    it "exposes price as a decimal in dollars/zł" do
      theme = build(:theme, price_cents: 2999)
      expect(theme.price).to eq(29.99)
    end

    it "stores price= as cents" do
      theme = build(:theme)
      theme.price = 12.5
      expect(theme.price_cents).to eq(1250)
    end

    it "free? when not premium" do
      expect(build(:theme, is_premium: false, price_cents: 0)).to be_free
      expect(build(:theme, is_premium: false, price_cents: 999)).to be_free
    end

    it "free? when premium but with zero price" do
      expect(build(:theme, is_premium: true, price_cents: 0)).to be_free
    end

    it "premium? requires both flag and positive price" do
      expect(build(:theme, :premium)).to be_premium
      expect(build(:theme, is_premium: true, price_cents: 0)).not_to be_premium
    end
  end

  describe "system?/default?/active?" do
    it "system? mirrors the is_system flag" do
      expect(build(:theme, :system)).to be_system
    end

    it "default? is true only for status='default'" do
      expect(build(:theme, :default)).to be_default
      expect(build(:theme, status: "active")).not_to be_default
    end

    it "active? covers both 'active' and 'default'" do
      expect(build(:theme, status: "active")).to be_active
      expect(build(:theme, :default)).to be_active
      expect(build(:theme, :inactive)).not_to be_active
    end
  end

  describe ".available_for" do
    let!(:default_theme) { create(:theme, :default, slug: "default") }
    let!(:am_theme) { create(:theme, slug: "am", name: "AM", status: "active") }
    let!(:am_owner) { create(:user, username: "am") }

    before do
      ThemeAccess.create!(theme: am_theme, user: am_owner)
    end

    it "hides the AM theme from regular users" do
      user = create(:user, username: "regular")
      expect(described_class.available_for(user)).to include(default_theme)
      expect(described_class.available_for(user)).not_to include(am_theme)
    end

    it "allows the AM theme for the am blog owner" do
      expect(described_class.available_for(am_owner)).to include(am_theme)
    end
  end

  describe "#available_for?" do
    it "allows public themes with no exclusive users" do
      theme = create(:theme)
      expect(theme.available_for?(create(:user))).to be true
    end

    it "restricts exclusive themes to assigned users" do
      theme = create(:theme, slug: "am")
      owner = create(:user, username: "am")
      ThemeAccess.create!(theme: theme, user: owner)

      expect(theme.available_for?(create(:user, username: "regular"))).to be false
      expect(theme.available_for?(owner)).to be true
    end
  end

  describe "status transitions" do
    it "#activate! sets status to active" do
      theme = create(:theme, :inactive)
      theme.activate!
      expect(theme.reload.status).to eq("active")
    end

    it "#deactivate! works on a non-default theme" do
      theme = create(:theme, status: "active")
      theme.deactivate!
      expect(theme.reload.status).to eq("inactive")
    end

    it "#deactivate! is a no-op on a default theme (cannot demote the default)" do
      theme = create(:theme, :default)
      theme.deactivate!
      expect(theme.reload.status).to eq("default")
    end

    it "#set_as_default! demotes any current default and promotes self" do
      old_default = create(:theme, :default, slug: "old-default")
      candidate   = create(:theme, status: "active", slug: "new-default")

      candidate.set_as_default!

      expect(candidate.reload.status).to eq("default")
      expect(old_default.reload.status).to eq("active")
    end
  end

  describe "template helpers" do
    let(:theme) { create(:theme, slug: "am", path: "am") }

    it "#template_path uses path when present, falling back to slug" do
      expect(theme.template_path.to_s).to end_with("/themes/am")
    end

    it "#layout_template returns nil when the theme has no top-level layout.liquid" do
      # The `am` theme uses `layouts/application.liquid`, not a top-level
      # `layout.liquid`, so the helper safely returns nil.
      expect(theme.layout_template).to be_nil
    end

    it "#template_for returns nil for a non-existent template" do
      expect(theme.template_for("nope-#{SecureRandom.hex}")).to be_nil
    end

    it "#template_for returns content for an existing template" do
      expect(theme.template_for("index")).to be_a(String)
    end

    it "#partial returns nil for a non-existent partial" do
      expect(theme.partial("not-a-real-partial-#{SecureRandom.hex}")).to be_nil
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:user_themes).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_themes) }
    it { is_expected.to have_many(:theme_accesses).dependent(:destroy) }
    it { is_expected.to have_many(:exclusive_users).through(:theme_accesses).source(:user) }
  end
end
