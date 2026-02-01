# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Use UUID as primary key for all models
  self.implicit_order_column = :created_at

  # Include common concerns
  include Auditable
  include Translatable

  # Pagination defaults
  class << self
    def default_per_page
      25
    end
  end
end
