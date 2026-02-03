# frozen_string_literal: true

require "rails_helper"

RSpec.describe Donation, type: :model do
  let(:donor) { create(:user) }
  let(:recipient) { create(:user) }
  let(:donation) { create(:donation, donor: donor, recipient: recipient) }

  describe "associations" do
    it { is_expected.to belong_to(:donor).class_name("User").optional }
    it { is_expected.to belong_to(:recipient).class_name("User") }
    it { is_expected.to belong_to(:payment).optional }
  end

  describe "validations" do
    subject { build(:donation, donor: donor, recipient: recipient) }

    it { is_expected.to validate_presence_of(:amount_cents) }
    it { is_expected.to validate_numericality_of(:amount_cents).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(%w[EUR USD PLN UAH GBP]) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending completed failed]) }

    it "validates that donor cannot donate to themselves" do
      self_donation = build(:donation, donor: donor, recipient: donor)
      expect(self_donation).not_to be_valid
      expect(self_donation.errors[:recipient]).to include("can't donate to yourself")
    end

    context "when donor is nil (guest donation)" do
      it "requires donor_name" do
        guest_donation = build(:donation, donor: nil, recipient: recipient, donor_name: nil, donor_email: "test@test.com")
        expect(guest_donation).not_to be_valid
        expect(guest_donation.errors[:donor_name]).to be_present
      end

      it "requires donor_email" do
        guest_donation = build(:donation, donor: nil, recipient: recipient, donor_name: "Guest", donor_email: nil)
        expect(guest_donation).not_to be_valid
        expect(guest_donation.errors[:donor_email]).to be_present
      end
    end
  end

  describe "scopes" do
    let!(:completed_donation) { create(:donation, donor: create(:user), recipient: recipient, status: "completed") }
    let!(:pending_donation) { create(:donation, donor: create(:user), recipient: recipient, status: "pending") }
    let!(:failed_donation) { create(:donation, donor: create(:user), recipient: recipient, status: "failed") }
    let!(:anonymous_donation) { create(:donation, donor: create(:user), recipient: recipient, anonymous: true) }
    let!(:recurring_donation) { create(:donation, donor: create(:user), recipient: recipient, recurring: true) }

    describe ".completed" do
      it "returns only completed donations" do
        expect(described_class.completed).to include(completed_donation)
        expect(described_class.completed).not_to include(pending_donation, failed_donation)
      end
    end

    describe ".pending" do
      it "returns only pending donations" do
        expect(described_class.pending).to include(pending_donation)
      end
    end

    describe ".failed" do
      it "returns only failed donations" do
        expect(described_class.failed).to include(failed_donation)
      end
    end

    describe ".anonymous" do
      it "returns only anonymous donations" do
        expect(described_class.anonymous).to include(anonymous_donation)
      end
    end

    describe ".recurring" do
      it "returns only recurring donations" do
        expect(described_class.recurring).to include(recurring_donation)
      end
    end

    describe ".for_recipient" do
      it "returns donations for specific recipient" do
        expect(described_class.for_recipient(recipient)).to include(completed_donation, pending_donation)
      end
    end

    describe ".from_donor" do
      it "returns donations from specific donor" do
        expect(described_class.from_donor(donor)).to include(donation)
      end
    end
  end

  describe "#amount" do
    it "returns amount in currency units" do
      donation.update!(amount_cents: 1000)
      expect(donation.amount).to eq(10.0)
    end
  end

  describe "#amount=" do
    it "sets amount_cents from currency units" do
      donation.amount = 25.50
      expect(donation.amount_cents).to eq(2550)
    end
  end

  describe "#formatted_amount" do
    it "returns formatted amount with currency symbol" do
      donation.update!(amount_cents: 1000, currency: "EUR")
      expect(donation.formatted_amount).to eq("€ 10.00")
    end
  end

  describe "#currency_symbol" do
    it "returns correct symbol for each currency" do
      expect(build(:donation, currency: "EUR").currency_symbol).to eq("€")
      expect(build(:donation, currency: "USD").currency_symbol).to eq("$")
      expect(build(:donation, currency: "PLN").currency_symbol).to eq("zł")
      expect(build(:donation, currency: "UAH").currency_symbol).to eq("₴")
      expect(build(:donation, currency: "GBP").currency_symbol).to eq("£")
    end
  end

  describe "#complete!" do
    it "changes status to completed" do
      donation.complete!
      expect(donation.status).to eq("completed")
    end
  end

  describe "#fail!" do
    it "changes status to failed" do
      donation.fail!
      expect(donation.status).to eq("failed")
    end
  end

  describe "#completed?" do
    it "returns true when status is completed" do
      donation.update!(status: "completed")
      expect(donation.completed?).to be true
    end
  end

  describe "#display_donor_name" do
    it "returns 'Anonymous' for anonymous donations" do
      donation.update!(anonymous: true)
      expect(donation.display_donor_name).to eq("Anonymous")
    end

    it "returns donor full name for non-anonymous donations" do
      expect(donation.display_donor_name).to eq(donor.full_name)
    end

    it "returns donor_name for guest donations" do
      guest_donation = create(:donation, donor: nil, recipient: recipient, donor_name: "Guest Donor", donor_email: "guest@test.com")
      expect(guest_donation.display_donor_name).to eq("Guest Donor")
    end
  end

  describe "#guest_donation?" do
    it "returns true when donor_id is nil" do
      guest_donation = create(:donation, donor: nil, recipient: recipient, donor_name: "Guest", donor_email: "guest@test.com")
      expect(guest_donation.guest_donation?).to be true
    end

    it "returns false when donor is present" do
      expect(donation.guest_donation?).to be false
    end
  end
end
