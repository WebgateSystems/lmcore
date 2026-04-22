# frozen_string_literal: true

module Dashboard
  class GalleryPhotosController < BaseController
    before_action :set_album
    before_action :set_photo, only: %i[update destroy make_cover move]

    def create
      authorize @album, policy_class: Dashboard::AlbumPolicy
      files = Array(params.dig(:photos, :images)).compact
      return redirect_back(fallback_location: edit_dashboard_gallery_path(@album.slug), alert: t("dashboard.gallery.photos.empty_upload")) if files.empty?

      created = []
      errors = []
      files.each do |file|
        basename = File.basename(file.original_filename.to_s, ".*")
        photo = @album.photos.build(
          image: file,
          author: current_user,
          title: basename,
          slug: normalized_file_slug(basename),
          status: normalized_photo_status,
          published_at: @album.published_at,
          published_by: @album.published_by,
          category: @album.category
        )
        photo.position = next_position
        if save_photo_with_slug_fallback(photo)
          created << photo
        else
          errors << {
            file: file.respond_to?(:original_filename) ? file.original_filename : nil,
            errors: photo.errors.full_messages
          }
        end
      end

      @album.update!(cover_photo: created.first) if @album.cover_photo.blank? && created.first.present?

      respond_to do |format|
        format.html do
          if created.any?
            notice = if errors.any?
              t("dashboard.gallery.photos.partial_upload", created: created.size, failed: errors.size)
            else
              t("dashboard.gallery.photos.uploaded", count: created.size)
            end
            redirect_to edit_dashboard_gallery_path(@album.slug), notice: notice
          else
            redirect_to edit_dashboard_gallery_path(@album.slug), alert: errors.flat_map { |row| row[:errors] }.join(", ")
          end
        end
        format.json do
          status = created.any? ? :created : :unprocessable_entity
          render json: { created: created.map { |p| serialize_photo(p) }, errors: errors }, status: status
        end
      end
    end

    def update
      authorize @album, policy_class: Dashboard::AlbumPolicy
      if @photo.update(photo_params)
        respond_to do |format|
          format.html { redirect_to edit_dashboard_gallery_path(@album.slug), notice: t("dashboard.gallery.photos.photo_updated") }
          format.json { render json: { photo: serialize_photo(@photo) } }
        end
      else
        respond_to do |format|
          format.html { redirect_to edit_dashboard_gallery_path(@album.slug), alert: @photo.errors.full_messages.to_sentence }
          format.json { render json: { errors: @photo.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @album, policy_class: Dashboard::AlbumPolicy
      @photo.destroy!
      if @album.cover_photo_id == @photo.id
        @album.update!(cover_photo: @album.photos.first)
      end

      respond_to do |format|
        format.html { redirect_to edit_dashboard_gallery_path(@album.slug), notice: t("dashboard.gallery.photos.photo_deleted") }
        format.json { render json: { ok: true } }
      end
    end

    def make_cover
      authorize @album, policy_class: Dashboard::AlbumPolicy
      @album.update!(cover_photo: @photo)
      respond_to do |format|
        format.html { redirect_to edit_dashboard_gallery_path(@album.slug), notice: t("dashboard.gallery.photos.cover_set") }
        format.json { render json: { cover_photo_id: @photo.id } }
      end
    end

    def move
      authorize @album, policy_class: Dashboard::AlbumPolicy
      direction = params[:direction].to_s
      offset = direction == "up" ? -1 : 1
      ordered = @album.photos.order(position: :asc, created_at: :asc).to_a
      index = ordered.index { |row| row.id == @photo.id }

      if index
        swap_index = index + offset
        if swap_index >= 0 && swap_index < ordered.length
          other = ordered[swap_index]
          Photo.transaction do
            current_position = @photo.position
            @photo.update_column(:position, other.position)
            other.update_column(:position, current_position)
          end
        end
      end

      redirect_to edit_dashboard_gallery_path(@album.slug)
    end

    def reorder
      authorize @album, policy_class: Dashboard::AlbumPolicy
      ids = Array(params[:photo_ids]).map(&:to_s)
      photos_by_id = @album.photos.where(id: ids).index_by { |photo| photo.id.to_s }

      ids.each_with_index do |id, index|
        photo = photos_by_id[id]
        next unless photo

        photo.update_column(:position, index)
      end

      render json: { ok: true }
    end

    private

    def set_album
      @album = Album.find_by!(author: current_user, slug: params[:gallery_slug] || params[:gallery_id])
    end

    def set_photo
      @photo = @album.photos.find(params[:id])
    end

    def photo_params
      params.require(:photo).permit(:title, :slug, :description, :alt_text, :position)
    end

    def serialize_photo(photo)
      {
        id: photo.id,
        title: photo.title,
        slug: photo.slug,
        image_url: photo.image&.url,
        thumb_url: photo.image&.thumb&.url || photo.image&.url,
        position: photo.position
      }
    end

    def next_position
      @album.photos.maximum(:position).to_i + 1
    end

    def save_photo_with_slug_fallback(photo)
      return true if photo.save

      # Retry once for the two common uploader failures:
      # 1) slug collision (same filename uploaded earlier)
      # 2) slug format invalid (filename with underscores or symbols)
      slug_taken = photo.errors.added?(:slug, :taken)
      slug_invalid = photo.errors.of_kind?(:slug, :invalid) || photo.errors[:slug].any?
      return false unless slug_taken || slug_invalid

      # If the generated slug collides (common when filenames repeat),
      # force a unique suffix and retry once.
      base = normalized_file_slug(photo.slug.to_s).presence || "photo"
      photo.slug = "#{base}-#{SecureRandom.hex(3)}"
      photo.save
    end

    def normalized_photo_status
      return "published" if @album.status == "published"
      return "scheduled" if @album.status == "scheduled"

      "draft"
    end

    def normalized_file_slug(raw)
      source = raw.to_s.strip
      source = source.tr("_", "-")
      normalized = source.parameterize(separator: "-")
      normalized.presence || "photo"
    end
  end
end
