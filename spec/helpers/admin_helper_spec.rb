# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminHelper, type: :helper do
  describe "#user_status_badge_class" do
    it "maps each known status to its colour class" do
      {
        "active" => "md-bg-green-500",
        "pending" => "md-bg-amber-500",
        "suspended" => "md-bg-red-500",
        "deleted" => "md-bg-grey-500"
      }.each do |status, expected|
        expect(helper.user_status_badge_class(double(status: status))).to eq(expected)
      end
    end

    it "falls back to a neutral class for unknown statuses" do
      expect(helper.user_status_badge_class(double(status: "weird"))).to eq("md-bg-blue-grey-500")
    end
  end

  describe "#user_role_badge_class" do
    %w[super-admin admin moderator editor author user].each do |slug|
      it "returns the badge for role slug #{slug}" do
        role = double(slug: slug)
        user = double(highest_role: role)
        expect(helper.user_role_badge_class(user)).to be_present
      end
    end

    it "falls back when there's no role at all" do
      expect(helper.user_role_badge_class(double(highest_role: nil))).to eq("md-bg-blue-grey-500")
    end
  end

  describe "#role_badge_class" do
    it "maps known role slugs and falls back otherwise" do
      expect(helper.role_badge_class(double(slug: "admin"))).to eq("md-bg-blue-500")
      expect(helper.role_badge_class(double(slug: "moderator"))).to eq("md-bg-cyan-500")
      expect(helper.role_badge_class(double(slug: "editor"))).to eq("md-bg-indigo-500")
      expect(helper.role_badge_class(double(slug: "author"))).to eq("md-bg-teal-500")
      expect(helper.role_badge_class(double(slug: "user"))).to eq("md-bg-green-500")
      expect(helper.role_badge_class(double(slug: "ghost"))).to eq("md-bg-blue-grey-500")
      expect(helper.role_badge_class(nil)).to eq("md-bg-blue-grey-500")
    end
  end

  describe "#activity_badge_class / #activity_icon_class" do
    {
      "create_post" => [ "md-bg-green-500", /plus-circle/ ],
      "update_user" => [ "md-bg-blue-500",  /pencil/ ],
      "delete_post" => [ "md-bg-red-500",   /delete/ ],
      "suspend_user" => [ "md-bg-orange-500", /account-cancel/ ],
      "activate_user" => [ "md-bg-green-500", /check-circle/ ],
      "login_user" => [ "md-bg-blue-500",  /login/ ],
      "logout_user" => [ "md-bg-grey-500",  /logout/ ],
      "publish_post" => [ "md-bg-green-500", /publish/ ],
      "weird_thing"  => [ "md-bg-blue-grey-500", /information/ ]
    }.each do |action, (expected_class, expected_icon_re)|
      it "categorises #{action.inspect}" do
        expect(helper.activity_badge_class(action)).to eq(expected_class)
        expect(helper.activity_icon_class(action)).to match(expected_icon_re)
      end
    end

    it "returns the eye-off icon for plain 'draft' actions" do
      # `unpublish` happens to match the broader `/publish/` clause first
      # (production behavior, not a test bug); the `draft` shortcut still
      # resolves cleanly because it isn't a substring of any earlier case.
      expect(helper.activity_icon_class("save_as_draft")).to match(/eye-off/)
    end
  end

  describe "#format_bytes" do
    it "returns '0 B' for nil/zero" do
      expect(helper.format_bytes(nil)).to eq("0 B")
      expect(helper.format_bytes(0)).to eq("0 B")
    end

    it "scales through KB / MB / GB" do
      expect(helper.format_bytes(1024)).to eq("1.0 KB")
      expect(helper.format_bytes(1024 * 1024)).to eq("1.0 MB")
      expect(helper.format_bytes(1024 * 1024 * 1024)).to eq("1.0 GB")
    end

    it "caps at TB for very large numbers" do
      huge = 1024 ** 6
      expect(helper.format_bytes(huge)).to end_with("TB")
    end
  end

  describe "#admin_page_title" do
    it "sets the content_for and renders an h2" do
      output = helper.admin_page_title("Dashboard")
      expect(output).to include("Dashboard")
      expect(helper.content_for(:title)).to include("Dashboard")
    end
  end

  describe "#admin_breadcrumb" do
    it "renders a uk-breadcrumb list with the last item as plain text" do
      html = helper.admin_breadcrumb({ title: "Home", path: "/admin" }, { title: "Users", path: "/admin/users" }, { title: "Edit" })
      expect(html).to include("uk-breadcrumb")
      expect(html).to include("Home")
      expect(html).to include("Users")
      expect(html).to include("Edit")
      expect(html).not_to include('href="/admin/users/edit"')
    end
  end
end
