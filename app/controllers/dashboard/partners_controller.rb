# frozen_string_literal: true

module Dashboard
  class PartnersController < BaseController
    before_action :set_partner, only: %i[edit update destroy]

    def index
      authorize Partner, policy_class: Dashboard::PartnerPolicy
      @partners = policy_scope(Partner, policy_scope_class: Dashboard::PartnerPolicy::Scope)
                  .for_user(dashboard_blog_user).ordered
    end

    def new
      @partner = Partner.new
      authorize @partner, policy_class: Dashboard::PartnerPolicy
    end

    def create
      @partner = Partner.new(partner_params)
      @partner.user = dashboard_blog_user
      @partner.position ||= (Partner.for_user(dashboard_blog_user).maximum(:position) || 0) + 1
      authorize @partner, policy_class: Dashboard::PartnerPolicy

      if @partner.save
        redirect_to dashboard_partners_path, notice: t("dashboard.flash.partners.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @partner, policy_class: Dashboard::PartnerPolicy
    end

    def update
      authorize @partner, policy_class: Dashboard::PartnerPolicy
      if @partner.update(partner_params)
        redirect_to dashboard_partners_path, notice: t("dashboard.flash.partners.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @partner, policy_class: Dashboard::PartnerPolicy
      @partner.destroy
      redirect_to dashboard_partners_path, notice: t("dashboard.flash.partners.deleted")
    end

    def reorder
      authorize Partner, policy_class: Dashboard::PartnerPolicy
      partner_ids = params[:partner_ids]
      return head :bad_request unless partner_ids.is_a?(Array)

      uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
      return head :bad_request unless partner_ids.all? { |id| uuid_regex.match?(id) }

      user_partner_ids = Partner.for_user(dashboard_blog_user).pluck(:id)
      return head :bad_request unless partner_ids.all? { |id| user_partner_ids.include?(id) }

      partner_ids.each_with_index do |id, index|
        Partner.where(id: id, user: dashboard_blog_user).update_all(position: index + 1) # rubocop:disable Rails/SkipsModelValidations
      end

      head :ok
    end

    private

    def set_partner
      @partner = Partner.for_user(dashboard_blog_user).find(params[:id])
    end

    def partner_params
      params.require(:partner).permit(:name, :slug, :url, :logo_svg, :logo_url, :icon_class,
                                      :description, :active)
    end
  end
end
