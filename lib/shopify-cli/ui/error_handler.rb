require 'cli/ui'

module ShopifyCli
  module UI
    module ErrorHandler
      def self.display_and_raise(failed_op:, cause_of_error:, help_suggestion:)
        $stderr.puts(CLI::UI.fmt("{{red:{{x}} Error}}"))
        full_msg = failed_op ? failed_op.dup : ""
        full_msg << " #{cause_of_error}" if cause_of_error
        full_msg << " #{help_suggestion}" if help_suggestion
        $stderr.puts(full_msg.strip)
        raise(ShopifyCli::AbortSilent)
      end
    end
  end
end
