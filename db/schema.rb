# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_02_210002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "key_digest", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "prefix", null: false
    t.jsonb "scopes", default: []
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["active"], name: "index_api_keys_on_active"
    t.index ["key_digest"], name: "index_api_keys_on_key_digest", unique: true
    t.index ["prefix"], name: "index_api_keys_on_prefix"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "auditable_id", null: false
    t.string "auditable_type", null: false
    t.jsonb "changes_data", default: {}
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}
    t.string "request_id"
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["request_id"], name: "index_audit_logs_on_request_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category_type", default: "general", null: false
    t.string "cover_image"
    t.datetime "created_at", null: false
    t.jsonb "description_i18n", default: {}
    t.jsonb "name_i18n", default: {}, null: false
    t.uuid "parent_id"
    t.integer "photos_count", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.integer "posts_count", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.integer "videos_count", default: 0, null: false
    t.index ["category_type"], name: "index_categories_on_category_type"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["position"], name: "index_categories_on_position"
    t.index ["user_id", "slug"], name: "index_categories_on_user_id_and_slug", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "approved_at"
    t.uuid "approved_by_id"
    t.uuid "commentable_id", null: false
    t.string "commentable_type", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "guest_email"
    t.string "guest_name"
    t.string "ip_address"
    t.uuid "parent_id"
    t.integer "reactions_count", default: 0, null: false
    t.integer "replies_count", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["approved_by_id"], name: "index_comments_on_approved_by_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["discarded_at"], name: "index_comments_on_discarded_at"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["status"], name: "index_comments_on_status"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "content_visibilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_level", default: "read", null: false
    t.datetime "created_at", null: false
    t.uuid "target_id", null: false
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.uuid "visible_id", null: false
    t.string "visible_type", null: false
    t.index ["target_type", "target_id"], name: "index_visibility_on_target"
    t.index ["visible_type", "visible_id", "target_type", "target_id"], name: "index_visibility_uniqueness", unique: true
    t.index ["visible_type", "visible_id"], name: "index_visibility_on_visible"
  end

  create_table "donations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.boolean "anonymous", default: false, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.string "donor_email"
    t.uuid "donor_id"
    t.string "donor_name"
    t.text "message"
    t.uuid "payment_id"
    t.uuid "recipient_id", null: false
    t.boolean "recurring", default: false, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["anonymous"], name: "index_donations_on_anonymous"
    t.index ["donor_id"], name: "index_donations_on_donor_id"
    t.index ["payment_id"], name: "index_donations_on_payment_id"
    t.index ["recipient_id"], name: "index_donations_on_recipient_id"
    t.index ["recurring"], name: "index_donations_on_recurring"
    t.index ["status"], name: "index_donations_on_status"
  end

  create_table "follows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "followed_id", null: false
    t.uuid "follower_id", null: false
    t.boolean "notify_posts", default: true, null: false
    t.boolean "notify_videos", default: true, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
    t.index ["status"], name: "index_follows_on_status"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.uuid "invitee_id"
    t.uuid "inviter_id", null: false
    t.text "message"
    t.string "role_type", default: "user"
    t.string "status", default: "pending", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_invitations_on_email"
    t.index ["expires_at"], name: "index_invitations_on_expires_at"
    t.index ["invitee_id"], name: "index_invitations_on_invitee_id"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["status"], name: "index_invitations_on_status"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "jwt_denylist", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti", unique: true
  end

  create_table "media_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "alt_text_i18n", default: {}
    t.uuid "attachable_id"
    t.string "attachable_type"
    t.string "attachment_type", null: false
    t.jsonb "caption_i18n", default: {}
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "file", null: false
    t.jsonb "file_data", default: {}
    t.integer "file_size_bytes", default: 0
    t.integer "position", default: 0, null: false
    t.jsonb "title_i18n", default: {}
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_media_attachments_on_attachable_type_and_attachable_id"
    t.index ["attachment_type"], name: "index_media_attachments_on_attachment_type"
    t.index ["position"], name: "index_media_attachments_on_position"
    t.index ["user_id"], name: "index_media_attachments_on_user_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}
    t.string "delivery_method"
    t.uuid "notifiable_id"
    t.string "notifiable_type"
    t.string "notification_type", null: false
    t.datetime "read_at"
    t.datetime "sent_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id", null: false
    t.jsonb "content_i18n", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "featured_image"
    t.jsonb "featured_image_data", default: {}
    t.integer "menu_position", default: 0
    t.jsonb "menu_title_i18n", default: {}
    t.jsonb "meta_description_i18n", default: {}
    t.string "page_type", default: "custom", null: false
    t.datetime "published_at"
    t.uuid "published_by_id"
    t.boolean "show_in_menu", default: false, null: false
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["author_id", "slug"], name: "index_pages_on_author_id_and_slug", unique: true
    t.index ["author_id"], name: "index_pages_on_author_id"
    t.index ["discarded_at"], name: "index_pages_on_discarded_at"
    t.index ["menu_position"], name: "index_pages_on_menu_position"
    t.index ["page_type"], name: "index_pages_on_page_type"
    t.index ["published_by_id"], name: "index_pages_on_published_by_id"
    t.index ["show_in_menu"], name: "index_pages_on_show_in_menu"
    t.index ["status"], name: "index_pages_on_status"
  end

  create_table "partners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "description_i18n", default: {}
    t.string "icon_class", default: "fa-brands fa-youtube"
    t.string "locale"
    t.text "logo_svg"
    t.string "logo_url"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["active"], name: "index_partners_on_active"
    t.index ["locale"], name: "index_partners_on_locale"
    t.index ["position"], name: "index_partners_on_position"
    t.index ["slug"], name: "index_partners_on_slug", unique: true
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.string "external_payment_id"
    t.text "failure_reason"
    t.integer "fee_cents", default: 0
    t.jsonb "metadata", default: {}
    t.integer "net_amount_cents", default: 0
    t.datetime "paid_at"
    t.string "payment_provider", null: false
    t.string "payment_type", null: false
    t.datetime "refunded_at"
    t.string "status", default: "pending", null: false
    t.uuid "subscription_id"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["external_payment_id"], name: "index_payments_on_external_payment_id"
    t.index ["paid_at"], name: "index_payments_on_paid_at"
    t.index ["payment_type"], name: "index_payments_on_payment_type"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["subscription_id"], name: "index_payments_on_subscription_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "photos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "alt_text_i18n", default: {}
    t.boolean "archived", default: false, null: false
    t.uuid "author_id", null: false
    t.uuid "category_id"
    t.integer "comments_count", default: 0, null: false
    t.boolean "comments_enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "description_i18n", default: {}
    t.datetime "discarded_at"
    t.jsonb "exif_data", default: {}
    t.boolean "featured", default: false, null: false
    t.string "image", null: false
    t.jsonb "image_data", default: {}
    t.jsonb "keywords_i18n", default: {}
    t.datetime "published_at"
    t.uuid "published_by_id"
    t.integer "reactions_count", default: 0, null: false
    t.datetime "scheduled_at"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["author_id", "slug"], name: "index_photos_on_author_id_and_slug", unique: true
    t.index ["author_id"], name: "index_photos_on_author_id"
    t.index ["category_id"], name: "index_photos_on_category_id"
    t.index ["discarded_at"], name: "index_photos_on_discarded_at"
    t.index ["featured"], name: "index_photos_on_featured"
    t.index ["published_at"], name: "index_photos_on_published_at"
    t.index ["published_by_id"], name: "index_photos_on_published_by_id"
    t.index ["status"], name: "index_photos_on_status"
  end

  create_table "posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.uuid "author_id", null: false
    t.uuid "category_id"
    t.integer "comments_count", default: 0, null: false
    t.boolean "comments_enabled", default: true, null: false
    t.jsonb "content_i18n", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.datetime "external_date"
    t.string "external_id"
    t.string "external_source"
    t.boolean "featured", default: false, null: false
    t.string "featured_image"
    t.jsonb "featured_image_data", default: {}
    t.jsonb "keywords_i18n", default: {}
    t.jsonb "lead_i18n", default: {}
    t.jsonb "meta_description_i18n", default: {}
    t.string "og_image"
    t.jsonb "og_image_data", default: {}
    t.datetime "published_at"
    t.uuid "published_by_id"
    t.integer "reactions_count", default: 0, null: false
    t.datetime "scheduled_at"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.jsonb "subtitle_i18n", default: {}
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["author_id", "slug"], name: "index_posts_on_author_id_and_slug", unique: true
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["discarded_at"], name: "index_posts_on_discarded_at"
    t.index ["external_source", "external_id"], name: "index_posts_on_external_source_and_external_id", unique: true, where: "(external_source IS NOT NULL)"
    t.index ["featured"], name: "index_posts_on_featured"
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["published_by_id"], name: "index_posts_on_published_by_id"
    t.index ["scheduled_at"], name: "index_posts_on_scheduled_at"
    t.index ["status"], name: "index_posts_on_status"
  end

  create_table "price_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "billing_period", default: "monthly", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.jsonb "description_i18n", default: {}
    t.integer "disk_space_mb", default: 40
    t.jsonb "features", default: {}
    t.string "name", null: false
    t.jsonb "name_i18n", default: {}
    t.integer "position", default: 0, null: false
    t.integer "posts_limit", default: 30
    t.integer "price_cents", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_price_plans_on_active"
    t.index ["position"], name: "index_price_plans_on_position"
    t.index ["slug"], name: "index_price_plans_on_slug", unique: true
  end

  create_table "reactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "reactable_id", null: false
    t.string "reactable_type", null: false
    t.string "reaction_type", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["reactable_type", "reactable_id"], name: "index_reactions_on_reactable_type_and_reactable_id"
    t.index ["reaction_type"], name: "index_reactions_on_reaction_type"
    t.index ["user_id", "reactable_type", "reactable_id"], name: "index_reactions_uniqueness", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "role_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.uuid "granted_by_id"
    t.uuid "role_id", null: false
    t.uuid "scope_id"
    t.string "scope_type"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["expires_at"], name: "index_role_assignments_on_expires_at"
    t.index ["granted_by_id"], name: "index_role_assignments_on_granted_by_id"
    t.index ["role_id"], name: "index_role_assignments_on_role_id"
    t.index ["scope_type", "scope_id"], name: "idx_role_assignments_scope"
    t.index ["user_id", "role_id", "scope_type", "scope_id"], name: "idx_role_assignments_unique", unique: true
    t.index ["user_id"], name: "index_role_assignments_on_user_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "description_i18n", default: {}
    t.string "name", null: false
    t.jsonb "name_i18n", default: {}
    t.jsonb "permissions", default: []
    t.integer "priority", default: 0, null: false
    t.string "slug", null: false
    t.boolean "system_role", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["priority"], name: "index_roles_on_priority"
    t.index ["slug"], name: "index_roles_on_slug", unique: true
    t.index ["system_role"], name: "index_roles_on_system_role"
  end

  create_table "site_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", default: "general"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.jsonb "value", default: {}
    t.string "value_type", default: "string"
    t.index ["category"], name: "index_site_settings_on_category"
    t.index ["user_id", "key"], name: "index_site_settings_on_user_id_and_key", unique: true
    t.index ["user_id"], name: "index_site_settings_on_user_id"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "auto_renew", default: true, null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "external_subscription_id"
    t.jsonb "metadata", default: {}
    t.string "payment_provider"
    t.uuid "price_plan_id", null: false
    t.datetime "started_at", null: false
    t.string "status", default: "active", null: false
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["expires_at"], name: "index_subscriptions_on_expires_at"
    t.index ["external_subscription_id"], name: "index_subscriptions_on_external_subscription_id"
    t.index ["price_plan_id"], name: "index_subscriptions_on_price_plan_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "tag_id", null: false
    t.uuid "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_taggings_uniqueness", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "taggings_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
    t.index ["slug"], name: "index_tags_on_slug", unique: true
    t.index ["taggings_count"], name: "index_tags_on_taggings_count"
  end

  create_table "themes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "author"
    t.jsonb "color_scheme", default: {}
    t.jsonb "config", default: {}
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR"
    t.text "description"
    t.boolean "is_premium", default: false, null: false
    t.boolean "is_system", default: false, null: false
    t.string "name", null: false
    t.string "path"
    t.string "preview_image"
    t.jsonb "preview_image_data", default: {}
    t.integer "price_cents", default: 0
    t.jsonb "screenshots", default: []
    t.string "slug", null: false
    t.string "status", default: "inactive", null: false
    t.jsonb "typography", default: {}
    t.datetime "updated_at", null: false
    t.string "version", default: "1.0.0"
    t.index ["is_premium"], name: "index_themes_on_is_premium"
    t.index ["is_system"], name: "index_themes_on_is_system"
    t.index ["slug"], name: "index_themes_on_slug", unique: true
    t.index ["status"], name: "index_themes_on_status"
  end

  create_table "user_group_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_group_id", null: false
    t.uuid "user_id", null: false
    t.index ["role"], name: "index_user_group_memberships_on_role"
    t.index ["user_group_id", "user_id"], name: "index_group_memberships_uniqueness", unique: true
    t.index ["user_group_id"], name: "index_user_group_memberships_on_user_group_id"
    t.index ["user_id"], name: "index_user_group_memberships_on_user_id"
  end

  create_table "user_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cover_image"
    t.datetime "created_at", null: false
    t.jsonb "description_i18n", default: {}
    t.integer "members_count", default: 0, null: false
    t.string "name", null: false
    t.uuid "owner_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "private", null: false
    t.index ["owner_id", "slug"], name: "index_user_groups_on_owner_id_and_slug", unique: true
    t.index ["owner_id"], name: "index_user_groups_on_owner_id"
    t.index ["visibility"], name: "index_user_groups_on_visibility"
  end

  create_table "user_themes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.jsonb "customizations", default: {}
    t.datetime "purchased_at"
    t.uuid "theme_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["theme_id"], name: "index_user_themes_on_theme_id"
    t.index ["user_id", "active"], name: "index_user_themes_on_user_id_and_active"
    t.index ["user_id", "theme_id"], name: "index_user_themes_on_user_id_and_theme_id", unique: true
    t.index ["user_id"], name: "index_user_themes_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar"
    t.jsonb "bio_i18n", default: {}
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.datetime "discarded_at"
    t.integer "disk_space_used_bytes", default: 0, null: false
    t.string "display_name"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "locale", default: "en"
    t.datetime "locked_at"
    t.jsonb "notification_preferences", default: {}
    t.string "phone"
    t.integer "posts_this_month", default: 0, null: false
    t.uuid "price_plan_id"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.jsonb "settings", default: {}
    t.integer "sign_in_count", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.datetime "subscription_expires_at"
    t.string "timezone", default: "UTC"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "vanity_domain"
    t.boolean "vanity_domain_verified", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true, where: "(phone IS NOT NULL)"
    t.index ["price_plan_id"], name: "index_users_on_price_plan_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true, where: "(username IS NOT NULL)"
    t.index ["vanity_domain"], name: "index_users_on_vanity_domain", unique: true, where: "(vanity_domain IS NOT NULL)"
  end

  create_table "videos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.uuid "author_id", null: false
    t.uuid "category_id"
    t.integer "comments_count", default: 0, null: false
    t.boolean "comments_enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "description_i18n", default: {}
    t.datetime "discarded_at"
    t.integer "duration_seconds"
    t.datetime "external_date"
    t.string "external_id"
    t.string "external_source"
    t.boolean "featured", default: false, null: false
    t.jsonb "keywords_i18n", default: {}
    t.jsonb "meta_description_i18n", default: {}
    t.string "og_image"
    t.jsonb "og_image_data", default: {}
    t.datetime "published_at"
    t.uuid "published_by_id"
    t.integer "reactions_count", default: 0, null: false
    t.datetime "scheduled_at"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.jsonb "subtitle_i18n", default: {}
    t.string "thumbnail"
    t.jsonb "thumbnail_data", default: {}
    t.jsonb "title_i18n", default: {}, null: false
    t.datetime "updated_at", null: false
    t.jsonb "video_data", default: {}
    t.string "video_external_id"
    t.string "video_file"
    t.string "video_provider"
    t.string "video_url"
    t.integer "views_count", default: 0, null: false
    t.index ["author_id", "slug"], name: "index_videos_on_author_id_and_slug", unique: true
    t.index ["author_id"], name: "index_videos_on_author_id"
    t.index ["category_id"], name: "index_videos_on_category_id"
    t.index ["discarded_at"], name: "index_videos_on_discarded_at"
    t.index ["featured"], name: "index_videos_on_featured"
    t.index ["published_at"], name: "index_videos_on_published_at"
    t.index ["published_by_id"], name: "index_videos_on_published_by_id"
    t.index ["status"], name: "index_videos_on_status"
    t.index ["video_provider"], name: "index_videos_on_video_provider"
  end

  add_foreign_key "api_keys", "users", on_delete: :cascade
  add_foreign_key "audit_logs", "users", on_delete: :nullify
  add_foreign_key "categories", "categories", column: "parent_id", on_delete: :nullify
  add_foreign_key "categories", "users", on_delete: :cascade
  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "users", column: "approved_by_id", on_delete: :nullify
  add_foreign_key "comments", "users", on_delete: :nullify
  add_foreign_key "donations", "payments", on_delete: :nullify
  add_foreign_key "donations", "users", column: "donor_id", on_delete: :nullify
  add_foreign_key "donations", "users", column: "recipient_id", on_delete: :cascade
  add_foreign_key "follows", "users", column: "followed_id", on_delete: :cascade
  add_foreign_key "follows", "users", column: "follower_id", on_delete: :cascade
  add_foreign_key "invitations", "users", column: "invitee_id", on_delete: :nullify
  add_foreign_key "invitations", "users", column: "inviter_id", on_delete: :cascade
  add_foreign_key "media_attachments", "users", on_delete: :cascade
  add_foreign_key "notifications", "users", column: "actor_id", on_delete: :nullify
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "pages", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "pages", "users", column: "published_by_id", on_delete: :nullify
  add_foreign_key "payments", "subscriptions", on_delete: :nullify
  add_foreign_key "payments", "users", on_delete: :cascade
  add_foreign_key "photos", "categories", on_delete: :nullify
  add_foreign_key "photos", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "photos", "users", column: "published_by_id", on_delete: :nullify
  add_foreign_key "posts", "categories", on_delete: :nullify
  add_foreign_key "posts", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "posts", "users", column: "published_by_id", on_delete: :nullify
  add_foreign_key "reactions", "users", on_delete: :cascade
  add_foreign_key "role_assignments", "roles", on_delete: :cascade
  add_foreign_key "role_assignments", "users", column: "granted_by_id", on_delete: :nullify
  add_foreign_key "role_assignments", "users", on_delete: :cascade
  add_foreign_key "site_settings", "users", on_delete: :cascade
  add_foreign_key "subscriptions", "price_plans"
  add_foreign_key "subscriptions", "users", on_delete: :cascade
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "user_group_memberships", "user_groups", on_delete: :cascade
  add_foreign_key "user_group_memberships", "users", on_delete: :cascade
  add_foreign_key "user_groups", "users", column: "owner_id", on_delete: :cascade
  add_foreign_key "user_themes", "themes", on_delete: :cascade
  add_foreign_key "user_themes", "users", on_delete: :cascade
  add_foreign_key "users", "price_plans"
  add_foreign_key "videos", "categories", on_delete: :nullify
  add_foreign_key "videos", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "videos", "users", column: "published_by_id", on_delete: :nullify
end
