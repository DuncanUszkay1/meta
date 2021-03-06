# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve < ShopifyCli::AppTypeCommand
      app_type :node, :ServeNode, 'serve/node'
      app_type :rails, :ServeRails, 'serve/rails'
      available_in_contexts 'serve', [:app]

      include ShopifyCli::Helpers::OS
      prerequisite_task :ensure_env
      options do |parser, flags|
        parser.on('--host=HOST') do |h|
          flags[:host] = h.gsub('"', '')
        end
      end

      def setup
        project = Project.current
        url = options.flags[:host] || Tasks::Tunnel.call(@ctx)
        update_env(url)
        ShopifyCli::Tasks::UpdateDashboardURLS.call(@ctx, url: url)
        if mac? && project.env.shop
          @ctx.puts("{{*}} Press {{yellow: Control-T}} to open this project in {{green:#{project.env.shop}}} ")
          on_siginfo do
            open = Open.new(@ctx)
            open.call
          end
        end
      end

      def self.help
        "  Start your app on a local server and create a" \
        " public HTTP ngrok tunnel to it.\n" \
        "    Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}"
      end

      def self.extended_help
        "  {{bold:Options:}}\n" \
        "    {{cyan:--host=HOST}}: Must be HTTPS url. Bypass running tunnel and use custom host."
      end

      def update_env(url)
        Project.current.env.update(@ctx, :host, url)
      end

      def on_siginfo
        fork do
          begin
            r, w = IO.pipe
            @signal = false
            trap('SIGINFO') do
              @signal = true
              w.write(0)
            end
            while r.read(1)
              next unless @signal
              @signal = false
              yield
            end
          rescue Interrupt
            exit(0)
          end
        end
      end
    end
  end
end
