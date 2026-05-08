# frozen_string_literal: true

require "rails_helper"

RSpec.describe TranslatePostMissingFieldsWorker, type: :worker do
  let(:author) { create(:user, :author) }
  let(:post_record) { create(:post, author: author) }

  describe "#perform" do
    it "stores assistant result on the dashboard job run" do
      run = create(:dashboard_job_run,
        user: author,
        post: post_record,
        job_type: "post_translation",
        status: "queued",
        payload: {
          request: {
            source_locale: "pl",
            target_locales: %w[en uk],
            content_format: "markdown",
            content: { title: "Polski tytuł", content_source: "Polski tekst" },
            requested_by_id: author.id
          }
        })
      client = instance_double(Assistant::PostTranslationClient)
      allow(Assistant::PostTranslationClient).to receive(:new).and_return(client)
      allow(client).to receive(:call).and_return(
        "translations" => {
          "en" => { "title" => "EN", "content_source" => "EN body" },
          "uk" => { "title" => "UK", "content_source" => "UK body" }
        },
        "warnings" => []
      )

      described_class.new.perform(author.id, post_record.id, run.id)

      run.reload
      expect(run.status).to eq("completed")
      expect(run.stage).to eq("finished")
      expect(run.progress_current).to eq(2)
      expect(run.payload.dig("result", "translations", "en", "title")).to eq("EN")
      expect(client).to have_received(:call).with(hash_including(
        source_locale: "pl",
        target_locales: %w[en uk],
        content_format: "markdown",
        content: hash_including("title" => "Polski tytuł"),
        metadata: hash_including(post_id: post_record.id, blog_user_id: author.id, requested_by_id: author.id)
      ))
    end

    it "returns early when user, post or run cannot be found" do
      expect(Assistant::PostTranslationClient).not_to receive(:new)

      described_class.new.perform(SecureRandom.uuid, post_record.id, SecureRandom.uuid)
    end

    it "marks the run as failed and re-raises assistant errors" do
      run = create(:dashboard_job_run,
        user: author,
        post: post_record,
        job_type: "post_translation",
        status: "queued",
        payload: {
          request: {
            source_locale: "pl",
            target_locales: %w[en],
            content: { title: "Polski tytuł" }
          }
        })
      client = instance_double(Assistant::PostTranslationClient)
      allow(Assistant::PostTranslationClient).to receive(:new).and_return(client)
      allow(client).to receive(:call).and_raise(Assistant::PostTranslationClient::Error, "assistant timeout")

      expect {
        described_class.new.perform(author.id, post_record.id, run.id)
      }.to raise_error(Assistant::PostTranslationClient::Error, "assistant timeout")

      run.reload
      expect(run.status).to eq("failed")
      expect(run.error_message).to eq("assistant timeout")
    end
  end
end
