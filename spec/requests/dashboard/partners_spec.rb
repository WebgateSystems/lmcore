# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Partners", type: :request do
  let(:author) { create(:user, :author) }

  before { sign_in author }

  describe "GET /dashboard/partners" do
    it "renders the index" do
      create(:partner, user: author)
      get dashboard_partners_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/partners" do
    it "creates a partner owned by the user and assigns position" do
      expect {
        post dashboard_partners_path, params: { partner: { name: "Partner Test", url: "https://example.com" } }
      }.to change { Partner.for_user(author).count }.by(1)
      expect(response).to redirect_to(dashboard_partners_path)
      expect(Partner.for_user(author).last.position).to be_present
    end
  end

  describe "POST /dashboard/partners/reorder" do
    let!(:p1) { create(:partner, user: author, position: 1) }
    let!(:p2) { create(:partner, user: author, position: 2) }

    it "updates partner positions" do
      post reorder_dashboard_partners_path, params: { partner_ids: [ p2.id, p1.id ] }
      expect(response).to have_http_status(:ok)
      expect(p1.reload.position).to eq(2)
      expect(p2.reload.position).to eq(1)
    end

    it "returns 400 when partner ids are malformed" do
      post reorder_dashboard_partners_path, params: { partner_ids: [ "not-a-uuid" ] }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns 400 when partner belongs to another user" do
      other = create(:user, :author)
      foreign = create(:partner, user: other)
      post reorder_dashboard_partners_path, params: { partner_ids: [ foreign.id ] }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "DELETE /dashboard/partners/:id" do
    it "destroys the partner when the actor is a moderator" do
      moderator = create(:user, :moderator)
      partner = create(:partner, user: moderator)
      sign_out author
      sign_in moderator
      expect { delete dashboard_partner_path(partner) }.to change(Partner, :count).by(-1)
    end
  end
end
