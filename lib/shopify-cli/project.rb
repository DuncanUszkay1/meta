# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Project
    include SmartProperties

    class << self
      def current
        at(Dir.pwd)
      end

      def current_context
        return :top_level if Project.at_top_level?

        project_type_context = Project.current.config['project_type']
        return project_type_context if project_type_context

        ShopifyCli::UI::ErrorHandler.display_and_raise(error_messages)
      end

      def at(dir)
        proj_dir = directory(dir)
        ShopifyCli::UI::ErrorHandler.display_and_raise(error_messages) unless proj_dir
        @at ||= Hash.new { |h, k| h[k] = new(directory: k) }
        @at[proj_dir]
      end

      # Returns the directory of the project you are current in
      # Traverses up directory hierarchy until it finds a `.shopify-cli.yml`, then returns the directory is it in
      #
      # #### Example Usage
      # `directory`, e.g. `~/src/Shopify/dev`
      #
      def directory(dir)
        @dir ||= Hash.new { |h, k| h[k] = __directory(k) }
        @dir[dir]
      end

      def error_messages(failed_op_message = nil)
        {
          failed_op: failed_op_message,
          cause_of_error: "Your .shopify-cli.yml file is not correct.",
          help_suggestion: "See https://help.shopify.com/en/",
        }
      end

      def write(ctx, project_type, identifiers = {})
        require 'yaml' # takes 20ms, so deferred as late as possible.
        content = {
          'project_type' => project_type,
        }.merge(identifiers)
        ctx.write('.shopify-cli.yml', YAML.dump(content))
      end

      def at_top_level?
        !directory(Dir.pwd)
      end

      private

      def __directory(curr)
        loop do
          return nil if curr == '/'
          file = File.join(curr, '.shopify-cli.yml')
          return curr if File.exist?(file)
          curr = File.dirname(curr)
        end
      end
    end

    property :directory

    def app_type
      ShopifyCli::AppTypeRegistry[app_type_id]
    end

    def app_type_id
      config['app_type'].to_sym
    end

    def env
      @env ||= Helpers::EnvFile.read(directory)
    end

    def config
      @config ||= begin
        config = load_yaml_file('.shopify-cli.yml')
        ShopifyCli::UI::ErrorHandler.display(error_messages) unless config.is_a?(Hash)
        config
      end
    end

    private

    def load_yaml_file(relative_path)
      f = File.join(directory, relative_path)
      require 'yaml' # takes 20ms, so deferred as late as possible.
      begin
        YAML.load_file(f)
      rescue Psych::SyntaxError
        ShopifyCli::UI::ErrorHandler.display_and_raise(self.class.error_messages)
      # rescue Errno::EACCES => e
      # TODO
      #   Dev::Helpers::EaccesHandler.diagnose_and_raise(f, e, mode: :read)
      rescue Errno::ENOENT
        ShopifyCli::UI::ErrorHandler.display_and_raise(self.class.error_messages)
      end
    end
  end
end
