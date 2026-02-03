# frozen_string_literal: true

module AdminHelpers
  def sign_in_admin
    @admin_user = create(:user, :admin)
    sign_in @admin_user
    @admin_user
  end

  def sign_in_super_admin
    @super_admin_user = create(:user, :super_admin)
    sign_in @super_admin_user
    @super_admin_user
  end

  def sign_in_moderator
    @moderator_user = create(:user, :moderator)
    sign_in @moderator_user
    @moderator_user
  end

  def sign_in_regular_user
    @regular_user = create(:user)
    sign_in @regular_user
    @regular_user
  end
end

RSpec.configure do |config|
  config.include AdminHelpers, type: :request
end
