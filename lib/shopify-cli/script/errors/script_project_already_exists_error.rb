# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    class ScriptProjectAlreadyExistsError < StandardError
      def initialize(dir)
        super("#{dir} already exists")
      end

      def cause_of_error
        'A directory with this script name already exists. '\
        'To create the script, a directory with the same name as the script needs to be created.'
      end

      def help_suggestion
        'Use a different script name and try again.'
      end
    end
  end
end
