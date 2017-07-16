# TODO move to separate files..

module Fizzy
  module LineEditor
    def self.enabled
      if Readline.available?
        Readline
      else
        Basic
      end
    end
  end
end

module Fizzy::LineEditor
  class Basic
    attr_reader :prompt, :options

    include Fizzy::IO

    def self.available?
      true
    end

    def initialize(prompt, options={})
      @prompt = prompt
      @options = options
    end

    def readline
      tell(prompt, newline: false)
      get_input
    end

    private

    def get_input
      if echo?
        $stdin.gets
      else
        $stdin.noecho(&:gets)
      end.chomp
    end

    def echo?
      options.fetch(:echo, true)
    end
  end
end

module Fizzy::LineEditor

  # Available options:
  # - add_to_history
  # - limited_to
  # - path
  class Readline < Basic

    include Fizzy::ANSIColors

    def self.available?
      Object.const_defined?(:Readline)
    end

    def readline
      if echo?
        ::Readline.completion_append_character = nil
        # Ruby 1.8.7 does not allow Readline.completion_proc= to receive nil.
        if complete = completion_proc
          ::Readline.completion_proc = complete
        end
        ::Readline.readline(colorize(prompt), add_to_history?)
      else
        super
      end
    end

    def add_to_history?
      options.fetch(:add_to_history, true)
    end
    private :add_to_history?

    def completion_proc
      if use_path_completion?
        proc { |text| PathCompletion.new(text).matches }
      elsif completion_options.any?
        proc do |text|
          completion_options.select { |option| option.to_s.start_with?(text) }
        end
      end
    end
    private :completion_proc

    def completion_options
      options.fetch(:limited_to, [])
    end
    private :completion_options

    def use_path_completion?
      options.fetch(:path, false)
    end
    private :use_path_completion?

    class PathCompletion
      attr_reader :text
      private :text

      def initialize(text)
        @text = text
      end

      def matches
        relative_matches
      end

      def relative_matches
        absolute_matches.map { |path| path.sub(base_path, "") }
      end
      private :relative_matches

      def absolute_matches
        Dir[glob_pattern].map do |path|
          if File.directory?(path)
            "#{path}/"
          else
            path
          end
        end
      end
      private :absolute_matches

      def glob_pattern
        "#{base_path}#{text}*"
      end
      private :glob_pattern

      def base_path
        "#{Dir.pwd}/"
      end
      private :base_path
    end
  end
end
