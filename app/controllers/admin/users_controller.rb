# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy suspend activate change_role add_role remove_role impersonate]

    def index
      authorize User, policy_class: Admin::UserPolicy

      users = policy_scope(User, policy_scope_class: Admin::UserPolicy::Scope)
              .includes(:price_plan, role_assignments: :role)
              .order(sort_column => sort_direction)

      # Apply filters
      users = users.where(status: params[:status]) if params[:status].present?

      # Filter by role (using role_assignments)
      if params[:role_id].present?
        users = users.joins(:role_assignments)
                     .where(role_assignments: { role_id: params[:role_id], scope_type: nil })
                     .distinct
      end

      users = users.where("email ILIKE :q OR username ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q",
                          q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @users = pagy(users, items: params[:per_page] || 25)
      @roles = Role.all
    end

    def show
      authorize @user, policy_class: Admin::UserPolicy

      @posts = @user.posts.order(created_at: :desc).limit(10)
      @activity = AuditLog.where(user: @user).order(created_at: :desc).limit(20)

      # Load role assignments grouped by scope
      @global_roles = @user.role_assignments.global.active.includes(:role, :granted_by)
      @contextual_roles = @user.role_assignments.contextual.active.includes(:role, :granted_by, :scope)
      @available_roles = available_roles
    end

    def new
      @user = User.new
      authorize @user, policy_class: Admin::UserPolicy
      @roles = available_roles
      @price_plans = PricePlan.all
    end

    def create
      @user = User.new(user_params)
      authorize @user, policy_class: Admin::UserPolicy

      # Skip confirmation email when admin creates user - confirm immediately
      @user.skip_confirmation_notification!

      if @user.save
        # Confirm user if not already confirmed (admin-created users are auto-confirmed)
        @user.confirm unless @user.confirmed?
        log_action("create", @user)
        redirect_to admin_user_path(@user), notice: "User created successfully."
      else
        @roles = available_roles
        @price_plans = PricePlan.all
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @user, policy_class: Admin::UserPolicy
      @roles = available_roles
      @price_plans = PricePlan.all
    end

    def update
      authorize @user, policy_class: Admin::UserPolicy

      if @user.update(user_params)
        log_action("update", @user)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        @roles = available_roles
        @price_plans = PricePlan.all
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @user, policy_class: Admin::UserPolicy

      @user.soft_delete!
      log_action("delete", @user)
      redirect_to admin_users_path, notice: "User deleted successfully."
    end

    def suspend
      authorize @user, policy_class: Admin::UserPolicy

      @user.suspend!
      log_action("suspend", @user)
      redirect_to admin_user_path(@user), notice: "User has been suspended."
    end

    def activate
      authorize @user, policy_class: Admin::UserPolicy

      @user.activate!
      log_action("activate", @user)
      redirect_to admin_user_path(@user), notice: "User has been activated."
    end

    def change_role
      authorize @user, policy_class: Admin::UserPolicy

      # Legacy method - redirects to add_role for backwards compatibility
      new_role = Role.find(params[:role_id])

      begin
        @user.assign_role!(new_role, granted_by: current_user)
        log_action("add_role", @user, role: new_role.name, scope: "global")
        redirect_to admin_user_path(@user), notice: "Role '#{new_role.name}' assigned to user."
      rescue ActiveRecord::RecordInvalid => e
        redirect_to admin_user_path(@user), alert: "Failed to assign role: #{e.message}"
      end
    end

    def add_role
      authorize @user, policy_class: Admin::UserPolicy

      role = Role.find(params[:role_id])
      scope_user = params[:scope_user_id].present? ? User.find(params[:scope_user_id]) : nil

      # Validate role assignment permissions
      if role.slug == "super-admin" && !current_user.super_admin?
        redirect_to admin_user_path(@user), alert: "Only super admins can assign the super-admin role."
        return
      end

      begin
        @user.assign_role!(role, scope: scope_user, granted_by: current_user)
        scope_label = scope_user ? "on @#{scope_user.username}'s blog" : "global"
        log_action("add_role", @user, role: role.name, scope: scope_label)
        redirect_to admin_user_path(@user), notice: "Role '#{role.name}' (#{scope_label}) assigned successfully."
      rescue ActiveRecord::RecordInvalid => e
        redirect_to admin_user_path(@user), alert: "Failed to assign role: #{e.message}"
      end
    end

    def remove_role
      authorize @user, policy_class: Admin::UserPolicy

      assignment = @user.role_assignments.find(params[:role_assignment_id])
      role_name = assignment.role.name
      scope_label = assignment.global? ? "global" : "on blog"

      # Prevent removing own super-admin role
      if assignment.role.slug == "super-admin" && @user == current_user
        redirect_to admin_user_path(@user), alert: "You cannot remove your own super-admin role."
        return
      end

      assignment.destroy!
      log_action("remove_role", @user, role: role_name, scope: scope_label)
      redirect_to admin_user_path(@user), notice: "Role '#{role_name}' removed successfully."
    end

    def impersonate
      authorize @user, policy_class: Admin::UserPolicy

      # Store original admin user
      session[:admin_user_id] = current_user.id
      log_action("impersonate", @user)

      # Sign in as the target user
      sign_in(@user, bypass: true)
      redirect_to root_path, notice: "You are now logged in as #{@user.full_name}. Click 'Stop Impersonating' to return."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted = %i[
        email username first_name last_name phone
        status locale timezone price_plan_id
        bio_i18n vanity_domain
      ]

      # Roles are now managed through role_assignments (add_role/remove_role actions)

      # Admins can set password when creating users or if super_admin
      if current_user.admin? && params[:user][:password].present?
        permitted += %i[password password_confirmation]
      end

      params.require(:user).permit(permitted)
    end

    def available_roles
      if current_user.super_admin?
        Role.all
      else
        Role.where.not(slug: "super-admin")
      end
    end

    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def log_action(action, user, details = {})
      AuditLog.create!(
        user: current_user,
        action: action,
        auditable: user,
        metadata: details.merge(
          target_email: user.email
        ),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_id: request.request_id
      )
    end
  end
end
