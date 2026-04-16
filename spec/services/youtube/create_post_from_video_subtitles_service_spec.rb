# frozen_string_literal: true

require "rails_helper"

RSpec.describe Youtube::CreatePostFromVideoSubtitlesService, type: :service do
  let(:author) { create(:user, :author) }
  let(:video) { create(:video, author: author, title_i18n: { "en" => "Video title" }, description_i18n: { "en" => "Desc" }) }

  describe "#call" do
    it "creates draft post linked to video" do
      service = described_class.new(user: author, video: video)
      ok_status = instance_double(Process::Status, success?: true)
      allow(service).to receive(:run_command)
        .and_return(
          [ '{"language":"en"}', "", ok_status ],
          [ "", "", ok_status ]
        )
      allow(service).to receive(:fetch_transcript).and_return("Line one\nLine two")

      result = service.call

      expect(result[:result]).to eq(:created)
      post = result[:post]
      expect(post).to be_present
      expect(post.video_id).to eq(video.id)
      expect(post.status).to eq("draft")
      expect(post.content_i18n["en"]).to include("Line one")
    end
  end
end
