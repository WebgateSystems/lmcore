# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminDashboardPolicy do
  subject(:policy) { described_class.new(user, nil) }

  context "when user is admin" do
    let(:user) { create(:user, :admin) }

    it "permits index and show" do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
    end

    it "returns full scope" do
      create(:user)
      scope = described_class::Scope.new(user, User.all).resolve
      expect(scope.count).to eq(User.count)
    end
  end

  context "when user is not admin" do
    let(:user) { create(:user) }

    it "denies index and show" do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
    end

    it "returns nil scope" do
      expect(described_class::Scope.new(user, User.all).resolve).to be_nil
    end
  end
end
