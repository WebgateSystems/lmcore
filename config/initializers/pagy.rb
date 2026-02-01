# frozen_string_literal: true

require "pagy/extras/overflow"
require "pagy/extras/metadata"

Pagy::DEFAULT[:items] = 25
Pagy::DEFAULT[:size]  = 7
Pagy::DEFAULT[:overflow] = :last_page
