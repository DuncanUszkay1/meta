# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    class ScriptProjectAlreadyExistsError < StandardError
      def initialize(dir)
        super("#{dir} already exists")
      end
    end
  end
end
