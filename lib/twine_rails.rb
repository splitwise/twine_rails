require 'rubygems'
require 'twine'
require 'twine_rails/version'

module TwineRails
  module Formatters
    class Rails < Twine::Formatters::Abstract
      def format_name
        'rails'
      end

      def extension
        '.yml'
      end

      def default_file_name
        'localize.yml'
      end

      def read(io, lang)
        begin
          require 'safe_yaml'
        rescue LoadError
          raise Twine::Error.new "You must run 'gem install safe_yaml' in order to read or write Rails YAML files."
        end

        yaml = SafeYAML.load(io)
        yaml[lang].each do |key, value|
          # Handle newlines and literal percentage signs for other platforms
          escaped_value = value.gsub("\n","\\n").gsub(/%(?!([0-9]+\$)?(@|d|l|i))/, '%%')

          set_translation_for_key(key, lang, escaped_value)
        end
      end

      def format_file(lang)
        "\"#{lang}\":#{super}\n"
      end

      def key_value_pattern
        "  \"%{key}\": \"%{value}\""
      end

      def format_value(value)
        escape_quotes(value).gsub('%%', '%')
      end
    end
  end
end

Twine::Formatters.register_formatter TwineRails::Formatters::Rails
