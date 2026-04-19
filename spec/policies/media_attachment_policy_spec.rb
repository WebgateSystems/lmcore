# frozen_string_literal: true

require "rails_helper"

RSpec.describe MediaAttachmentPolicy do
  subject { described_class.new(user, attachment) }

  let(:owner)  { create(:user, :author) }
  let(:other)  { create(:user, :author) }
  let(:admin)  { create(:user, :admin) }

  let(:attachment) { create(:media_attachment, user: owner) }

  describe "as owner" do
    let(:user) { owner }

    it { is_expected.to permit_actions(%i[index create show update destroy attach]) }
  end

  describe "as another user" do
    let(:user) { other }

    it { is_expected.to permit_actions(%i[index create]) }
    it { is_expected.to forbid_actions(%i[show update destroy attach]) }
  end

  describe "as admin" do
    let(:user) { admin }

    it { is_expected.to permit_actions(%i[index create show update destroy attach]) }
  end

  describe "anonymous user" do
    let(:user) { nil }

    it { is_expected.to forbid_actions(%i[index create show update destroy attach]) }
  end

  describe "Scope" do
    let!(:owned)   { create(:media_attachment, user: owner) }
    let!(:foreign) { create(:media_attachment, user: other) }

    it "returns only own attachments for a regular user" do
      scope = described_class::Scope.new(owner, MediaAttachment.all).resolve
      expect(scope).to include(owned)
      expect(scope).not_to include(foreign)
    end

    it "returns all attachments for an admin" do
      scope = described_class::Scope.new(admin, MediaAttachment.all).resolve
      expect(scope).to include(owned, foreign)
    end

    it "returns none for an anonymous user" do
      scope = described_class::Scope.new(nil, MediaAttachment.all).resolve
      expect(scope).to be_empty
    end
  end
end
