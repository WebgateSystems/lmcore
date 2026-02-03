# frozen_string_literal: true

module Admin
  module Api
    module V1
      class UsersController < BaseController
        before_action :set_user, only: %i[show update destroy suspend activate change_role]

        def index
          @users = policy_scope(User, policy_scope_class: Admin::UserPolicy::Scope)
                   .includes(:price_plan, role_assignments: :role)
                   .order(sort_column => sort_direction)
                   .page(params[:page])
                   .per(params[:per_page] || 25)

          # Apply filters
          @users = @users.where(status: params[:status]) if params[:status].present?
          if params[:role_id].present?
            @users = @users.joins(:role_assignments)
                           .where(role_assignments: { role_id: params[:role_id], scope_type: nil })
                           .distinct
          end
          @users = @users.where("email ILIKE :q OR username ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q",
                                q: "%#{params[:q]}%") if params[:q].present?

          render_success(
            users: @users.map { |user| user_json(user) },
            meta: pagination_meta(@users)
          )
        end

        def show
          authorize @user, policy_class: Admin::UserPolicy

          render_success(user: user_json(@user, detailed: true))
        end

        def update
          authorize @user, policy_class: Admin::UserPolicy

          if @user.update(user_params)
            log_admin_action("update", @user)
            render_success(user: user_json(@user))
          else
            render_error(
              "Validation failed",
              status: :unprocessable_entity,
              errors: @user.errors.full_messages
            )
          end
        end

        def destroy
          authorize @user, policy_class: Admin::UserPolicy

          @user.soft_delete!
          log_admin_action("delete", @user)
          render_success(message: "User deleted successfully")
        end

        def suspend
          authorize @user, policy_class: Admin::UserPolicy

          @user.suspend!
          log_admin_action("suspend", @user)
          render_success(user: user_json(@user), message: "User suspended successfully")
        end

        def activate
          authorize @user, policy_class: Admin::UserPolicy

          @user.activate!
          log_admin_action("activate", @user)
          render_success(user: user_json(@user), message: "User activated successfully")
        end

        def change_role
          authorize @user, policy_class: Admin::UserPolicy

          new_role = Role.find(params[:role_id])

          begin
            @user.assign_role!(new_role, granted_by: current_user)
            log_admin_action("add_role", @user, role: new_role.name, scope: "global")
            render_success(user: user_json(@user), message: "Role '#{new_role.name}' assigned successfully")
          rescue ActiveRecord::RecordInvalid => e
            render_error("Failed to assign role: #{e.message}", status: :unprocessable_entity)
          end
        end

        private

        def set_user
          @user = User.find(params[:id])
        end

        def user_params
          permitted = %i[
            email username first_name last_name phone
            status locale timezone price_plan_id
          ]

          # Roles are managed through role_assignments (change_role action)

          params.require(:user).permit(permitted)
        end

        def user_json(user, detailed: false)
          data = {
            id: user.id,
            email: user.email,
            username: user.username,
            first_name: user.first_name,
            last_name: user.last_name,
            full_name: user.full_name,
            initials: user.initials,
            status: user.status,
            locale: user.locale,
            timezone: user.timezone,
            avatar_url: user.avatar&.url(:medium),
            roles: user.global_roles.map { |r| { id: r.id, name: r.name, slug: r.slug } },
            highest_role: user.highest_role ? { id: user.highest_role.id, name: user.highest_role.name, slug: user.highest_role.slug } : nil,
            price_plan: user.price_plan ? { id: user.price_plan.id, name: user.price_plan.name } : nil,
            created_at: user.created_at.iso8601,
            updated_at: user.updated_at.iso8601
          }

          if detailed
            data.merge!(
              phone: user.phone,
              bio: user.bio,
              confirmed_at: user.confirmed_at&.iso8601,
              last_sign_in_at: user.last_sign_in_at&.iso8601,
              last_sign_in_ip: user.last_sign_in_ip,
              sign_in_count: user.sign_in_count,
              vanity_domain: user.vanity_domain,
              vanity_domain_verified: user.vanity_domain_verified,
              disk_space_used_bytes: user.disk_space_used_bytes,
              posts_count: user.posts.count,
              comments_count: user.comments.count,
              followers_count: user.followers.count,
              following_count: user.following.count
            )
          end

          data
        end

        def sort_column
          User.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
        end

        def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
        end
      end
    end
  end
end
