# frozen_string_literal: true

require "zip"

module Admin
  class ThemesController < BaseController
    before_action :set_theme, only: %i[show edit update destroy]
    before_action :load_users, only: %i[new edit create update]

    def index
      authorize Theme, policy_class: Admin::ThemePolicy

      themes = policy_scope(Theme, policy_scope_class: Admin::ThemePolicy::Scope)
               .includes(:exclusive_users)
               .ordered
      themes = themes.where(status: params[:status]) if params[:status].present?
      themes = themes.where("name ILIKE :q OR slug ILIKE :q OR path ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @themes = pagy(themes, items: params[:per_page] || 25)
    end

    def show
      authorize @theme, policy_class: Admin::ThemePolicy
    end

    def new
      @theme = Theme.new(status: "active", is_system: true, is_premium: false, version: "1.0.0")
      authorize @theme, policy_class: Admin::ThemePolicy
    end

    def create
      @theme = Theme.new(theme_params)
      authorize @theme, policy_class: Admin::ThemePolicy

      ActiveRecord::Base.transaction do
        extract_theme_archive!(@theme, params.dig(:theme, :archive))
        @theme.save!
        enforce_single_default!(@theme)
        sync_exclusive_users!(@theme)
      end

      redirect_to admin_theme_path(@theme), notice: "Theme created successfully."
    rescue ActiveRecord::RecordInvalid, ArgumentError, Zip::Error => e
      @theme.errors.add(:base, e.message) if @theme.errors.empty?
      render :new, status: :unprocessable_content
    end

    def edit
      authorize @theme, policy_class: Admin::ThemePolicy
    end

    def update
      authorize @theme, policy_class: Admin::ThemePolicy

      ActiveRecord::Base.transaction do
        @theme.assign_attributes(theme_params)
        extract_theme_archive!(@theme, params.dig(:theme, :archive))
        @theme.save!
        enforce_single_default!(@theme)
        sync_exclusive_users!(@theme)
      end

      redirect_to admin_theme_path(@theme), notice: "Theme updated successfully."
    rescue ActiveRecord::RecordInvalid, ArgumentError, Zip::Error => e
      @theme.errors.add(:base, e.message) if @theme.errors.empty?
      render :edit, status: :unprocessable_content
    end

    def destroy
      authorize @theme, policy_class: Admin::ThemePolicy
      @theme.destroy!
      redirect_to admin_themes_path, notice: "Theme deleted successfully."
    end

    private

    def set_theme
      @theme = Theme.find(params[:id])
    end

    def load_users
      @users = User.active.order(:username, :email)
    end

    def theme_params
      params.require(:theme).permit(
        :name, :slug, :path, :description, :author, :version,
        :status, :is_system, :is_premium, :price_cents
      )
    end

    def sync_exclusive_users!(theme)
      user_ids = Array(params.dig(:theme, :exclusive_user_ids)).reject(&:blank?)
      users = User.active.where(id: user_ids)
      theme.exclusive_users = users
    end

    def enforce_single_default!(theme)
      return unless theme.default?

      Theme.where(status: "default").where.not(id: theme.id).update_all(status: "active")
    end

    def extract_theme_archive!(theme, archive)
      return if archive.blank?

      folder = sanitized_theme_path(theme.path.presence || theme.slug)
      theme.path = folder
      destination = Rails.root.join("themes", folder)
      destination.mkpath

      Zip::File.open(archive.path) do |zip_file|
        zip_file.each do |entry|
          next if entry.name.end_with?("/")

          relative_path = safe_zip_entry_path(entry.name)
          next if relative_path.blank?

          target_path = destination.join(relative_path).cleanpath
          unless target_path.to_s.start_with?(destination.cleanpath.to_s)
            raise ArgumentError, "Theme archive contains an unsafe path: #{entry.name}"
          end

          target_path.dirname.mkpath
          entry.extract(target_path) { true }
        end
      end

      validate_theme_folder!(destination)
    end

    def sanitized_theme_path(value)
      path = value.to_s.strip.downcase.gsub(/[^a-z0-9_-]+/, "-").gsub(/\A-+|-+\z/, "")
      raise ArgumentError, "Theme folder path is required." if path.blank?

      path
    end

    def safe_zip_entry_path(name)
      parts = Pathname.new(name).each_filename.to_a
      parts.shift if parts.size > 1 && parts.first !~ /\./
      path = parts.join("/")
      return "" if path.blank? || path.start_with?(".")

      path
    end

    def validate_theme_folder!(path)
      return if path.join("layouts/application.liquid").exist? && path.join("index.liquid").exist?

      raise ArgumentError, "Theme folder must contain index.liquid and layouts/application.liquid."
    end
  end
end
