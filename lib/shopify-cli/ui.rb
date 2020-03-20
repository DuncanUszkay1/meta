# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module UI
    autoload :ErrorHandler, 'shopify-cli/ui/error_handler'
    autoload :StrictSpinner, 'shopify-cli/ui/strict_spinner'
  end
end
