# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "validations" do
    subject { build(:payment) }

    it { is_expected.to validate_presence_of(:payment_provider) }
    it { is_expected.to validate_inclusion_of(:payment_provider).in_array(%w[stripe paypal manual]) }
    it { is_expected.to validate_presence_of(:payment_type) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:amount_cents).only_integer.is_greater_than(0) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(%w[EUR USD PLN UAH GBP]) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:subscription).optional }
  end

  describe "scopes" do
    let!(:completed) { create(:payment, :completed) }
    let!(:pending)   { create(:payment) }
    let!(:failed)    { create(:payment, :failed) }
    let!(:refunded)  { create(:payment, :refunded) }

    it ".completed / .pending / .failed / .refunded" do
      expect(described_class.completed).to contain_exactly(completed)
      expect(described_class.pending).to contain_exactly(pending)
      expect(described_class.failed).to contain_exactly(failed)
      expect(described_class.refunded).to contain_exactly(refunded)
    end

    it ".for_subscriptions / .for_donations" do
      donation = create(:payment, :donation)
      expect(described_class.for_donations).to contain_exactly(donation)
      expect(described_class.for_subscriptions).to include(pending, completed, failed, refunded)
    end

    it ".in_period filters by paid_at range" do
      old_payment = create(:payment, :completed, paid_at: 2.years.ago)
      results = described_class.in_period(1.day.ago, 1.day.from_now)
      expect(results).to include(completed)
      expect(results).not_to include(old_payment)
    end
  end

  describe "AASM state machine" do
    let(:payment) { create(:payment, fee_cents: 30) }

    it "starts in :pending" do
      expect(payment).to be_pending
    end

    it "transitions pending -> processing -> completed" do
      payment.process!
      expect(payment).to be_processing
      payment.complete!
      expect(payment).to be_completed
      expect(payment.paid_at).to be_within(1.second).of(Time.current)
      expect(payment.net_amount_cents).to eq(payment.amount_cents - 30)
    end

    it "can fail from pending" do
      payment.fail!
      expect(payment).to be_failed
    end

    it "refunds a completed payment and timestamps refunded_at" do
      payment.process!
      payment.complete!
      payment.refund!
      expect(payment).to be_refunded
      expect(payment.refunded_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "money helpers" do
    let(:payment) { build(:payment, amount_cents: 1234, fee_cents: 50, net_amount_cents: 1184, currency: "EUR") }

    it "exposes #amount / #fee / #net_amount as decimals" do
      expect(payment.amount).to eq(12.34)
      expect(payment.fee).to eq(0.5)
      expect(payment.net_amount).to eq(11.84)
    end

    it "lets you assign #amount in dollars/euros and stores cents" do
      payment.amount = 7.5
      expect(payment.amount_cents).to eq(750)
    end

    it "formats amount with the right currency symbol" do
      expect(payment.formatted_amount).to eq("€ 12.34")
      payment.currency = "USD"
      expect(payment.formatted_amount).to eq("$ 12.34")
      payment.currency = "PLN"
      expect(payment.formatted_amount).to eq("zł 12.34")
      payment.currency = "UAH"
      expect(payment.formatted_amount).to eq("₴ 12.34")
      payment.currency = "GBP"
      expect(payment.formatted_amount).to eq("£ 12.34")
    end

    it "falls back to the currency code itself when there's no symbol" do
      payment.currency = "JPY"
      expect(payment.currency_symbol).to eq("JPY")
    end
  end

  describe "#refundable?" do
    it "is true for a completed payment within 30 days that hasn't been refunded" do
      p = create(:payment, :completed, paid_at: 5.days.ago)
      expect(p).to be_refundable
    end

    it "is false once already refunded" do
      p = create(:payment, :refunded)
      expect(p).not_to be_refundable
    end

    it "is false when paid_at is older than 30 days" do
      p = create(:payment, :completed, paid_at: 35.days.ago)
      expect(p).not_to be_refundable
    end
  end

  describe "type predicates" do
    it { expect(build(:payment, payment_type: "subscription")).to be_subscription_payment }
    it { expect(build(:payment, payment_type: "donation")).to be_donation_payment }
  end
end
