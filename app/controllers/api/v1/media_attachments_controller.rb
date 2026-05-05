# frozen_string_literal: true

module Api
  module V1
    # Manages MediaAttachment uploads for the rich text editor (inline images,
    # documents). Uploads can be orphaned (no `attachable_id` yet) when the
    # post/page hasn't been saved; CleanupOrphanMediaAttachmentsWorker eventually
    # removes the unused ones, and dashboard controllers link them on create/update.
    class MediaAttachmentsController < BaseController
      before_action :load_attachment, only: %i[show update destroy]

      ALLOWED_ATTACHABLE_TYPES = %w[Post Page].freeze

      def index
        scope = policy_scope(MediaAttachment)
        scope = scope.where(attachment_type: params[:attachment_type]) if params[:attachment_type].present?
        scope = filter_by_attachable(scope)
        scope = scope.order(:position, :created_at)
        render json: { attachments: scope.map { |a| serialize(a) } }
      end

      def show
        authorize @attachment
        render json: { attachment: serialize(@attachment) }
      end

      def create
        # Class-level check first so verify_authorized is satisfied even if
        # resolve_attachable! raises Pundit::NotAuthorizedError below.
        authorize MediaAttachment
        attachable = resolve_attachable!
        attachment = MediaAttachment.new(create_params)
        attachment.user = current_user
        attachment.attachable = attachable if attachable
        authorize attachment

        if attachment.save
          render json: { attachment: serialize(attachment) }, status: :created
        else
          render_error(I18n.t("errors.validation_failed"),
                       status: :unprocessable_entity,
                       errors: attachment.errors.full_messages)
        end
      end

      def update
        authorize @attachment
        if @attachment.update(update_params)
          render json: { attachment: serialize(@attachment) }
        else
          render_error(I18n.t("errors.validation_failed"),
                       status: :unprocessable_entity,
                       errors: @attachment.errors.full_messages)
        end
      end

      def destroy
        authorize @attachment
        @attachment.destroy!
        render json: { success: true }
      end

      private

      def load_attachment
        @attachment = MediaAttachment.find(params[:id])
      end

      def filter_by_attachable(scope)
        return scope.where(attachable_id: nil, user_id: current_user.id) if params[:orphan].to_s == "true"

        if params[:attachable_type].present? && params[:attachable_id].present?
          scope.where(attachable_type: params[:attachable_type], attachable_id: params[:attachable_id])
        else
          scope
        end
      end

      def resolve_attachable!
        return nil if params[:attachable_type].blank? || params[:attachable_id].blank?

        type = params[:attachable_type].to_s
        unless ALLOWED_ATTACHABLE_TYPES.include?(type)
          raise Pundit::NotAuthorizedError, "Unsupported attachable type"
        end

        klass = type.safe_constantize
        raise Pundit::NotAuthorizedError, "Unsupported attachable type" unless klass

        record = klass.find(params[:attachable_id])
        ensure_attachable_authorized!(record)
        record
      end

      def ensure_attachable_authorized!(record)
        case record
        when Post, Page
          unless record.author_id == current_user.id || current_user.admin?
            raise Pundit::NotAuthorizedError, "Cannot attach to this resource"
          end
        else
          raise Pundit::NotAuthorizedError, "Cannot attach to this resource"
        end
      end

      def create_params
        params.require(:media_attachment).permit(
          :file, :attachment_type, :position,
          title_i18n: {},
          alt_text_i18n: {},
          caption_i18n: {}
        )
      end

      def update_params
        params.require(:media_attachment).permit(
          :position,
          title_i18n: {},
          alt_text_i18n: {},
          caption_i18n: {}
        )
      end

      def serialize(att)
        {
          id: att.id,
          attachment_type: att.attachment_type,
          attachable_type: att.attachable_type,
          attachable_id: att.attachable_id,
          position: att.position,
          title_i18n: att.title_i18n,
          alt_text_i18n: att.alt_text_i18n,
          caption_i18n: att.caption_i18n,
          file_url: att.file&.url,
          thumb_url: att.image? ? att.file&.thumb&.url : nil,
          medium_url: att.image? ? att.file&.medium&.url : nil,
          file_name: att.file_name,
          content_type: att.content_type,
          file_size_bytes: att.file_size_bytes,
          human_file_size: att.human_file_size,
          shortcode: att.image? ? "[[fig:#{att.id}]]" : nil,
          created_at: att.created_at
        }
      end
    end
  end
end
