# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    class ScriptProjectAlreadyExistsError < StandardError
      def initialize(dir)
        super("#{dir} already exists")
      end

      def cause_of_error
        'Directory with the same name as the script already exists. '\
      end

      def help_suggestion
        'Use different script name and try again.'
      end
    end
  end
end
