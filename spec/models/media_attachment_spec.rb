# frozen_string_literal: true

RSpec.describe MediaAttachment do
  describe "#download_name" do
    it "uses the assigned title and appends the stored file extension" do
      attachment = build(:media_attachment, :document, title_i18n: { "en" => "Author assigned name" })
      allow(attachment).to receive(:file_name).and_return("uuid-value.pdf")

      I18n.with_locale(:en) do
        expect(attachment.download_name).to eq("Author assigned name.pdf")
      end
    end

    it "does not append the extension twice when the title already has one" do
      attachment = build(:media_attachment, :document, title_i18n: { "en" => "Author assigned name.pdf" })
      allow(attachment).to receive(:file_name).and_return("uuid-value.pdf")

      I18n.with_locale(:en) do
        expect(attachment.download_name).to eq("Author assigned name.pdf")
      end
    end
  end
end
