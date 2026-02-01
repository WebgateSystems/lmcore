# frozen_string_literal: true

class ApiKey < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :name, presence: true
  validates :key_digest, presence: true, uniqueness: true
  validates :prefix, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at < ?", Time.current) }
  scope :valid, -> { active.where("expires_at IS NULL OR expires_at > ?", Time.current) }

  # Callbacks
  attr_accessor :raw_key

  before_validation :generate_key, on: :create

  # Class methods
  class << self
    def authenticate(key)
      return nil if key.blank?

      prefix = key[0..7]
      api_key = valid.find_by(prefix: prefix)
      return nil unless api_key

      api_key if api_key.authenticate(key)
    end
  end

  # Instance methods
  def authenticate(key)
    BCrypt::Password.new(key_digest) == key
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def regenerate!
    generate_key
    save!
    raw_key
  end

  def revoke!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def valid_key?
    active? && !expired?
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  def has_scope?(scope)
    scopes.include?(scope.to_s) || scopes.include?("*")
  end

  def add_scope(scope)
    self.scopes = (scopes + [ scope.to_s ]).uniq
  end

  def remove_scope(scope)
    self.scopes = scopes - [ scope.to_s ]
  end

  def masked_key
    "#{prefix}#{'*' * 24}"
  end

  private

  def generate_key
    self.raw_key = SecureRandom.urlsafe_base64(32)
    self.prefix = raw_key[0..7]
    self.key_digest = BCrypt::Password.create(raw_key)
  end
end
