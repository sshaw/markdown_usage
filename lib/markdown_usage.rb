require "tty/markdown"
require "markdown_usage/version"

module MarkdownUsage
  Error = Class.new(StandardError)

  class << self
    def print(options = nil)
      options ||= {}

      output = options[:output] || $stdout
      exitcode = options.include?(:exit) ? options[:exit] : 0
      raise_errors = options.include?(:raise_errors) ? options[:raise_errors] : true

      error("Usage document cannot be found", raise_errors) and return unless defined?(DATA) || options[:source]

      root = find_root_directory

      if !options[:source]
        lines = DATA.readlines
      else
        source = options[:source] == "README" ?
                   %w[md markdown].map { |ext| File.join(root, "README.#{ext}") }.find { |path| File.exists?(path) } :
                   File.exists?(options[:source]) ? options[:source] : File.join(root, options[:source])

        error("Cannot find usage source: #{options[:source]}", raise_errors) and return unless source && File.exists?(source)
        lines = File.readlines(source)
      end

      output.puts TTY::Markdown.parse(extract_usage(lines, options[:sections]))
      exit exitcode unless exitcode == false
    rescue => e
      error(e, raise_errors)
    end

    private

    def error(message, raise_errors = false)
      raise Error, message if raise_errors
      warn "MarkdownUsage warning: #{message}"
      true
    end

    def find_root_directory
      caller[2] =~ /\A(.+):\d+:in\s+`/ ? File.dirname($1) : "."
    end

    def extract_usage(lines, sections)
      sections = Array(sections).map { |text| Regexp.quote(text) }
      return lines.join("") unless sections.any?

      usage = ""
      while lines.any?
        lead = nil

        sections.each do |pat|
          next unless lines[0] =~ %r|\A(\#{1,6}\s*)#{pat}|
          lead = $1

          while lines.any?
            # Possible to use flip-flop without assigning to this?
            $_ = lines[0]
            if %r|\A#{lead}#{pat}| ... %r|\A#{lead}(?!#{pat})|
              break if lines[0] =~ %r|\A#{lead}(?!#{pat})|
              usage << lines.shift
            end
          end
        end

        lines.shift
      end

      usage
    end
  end
end

def MarkdownUsage(options = nil)
  MarkdownUsage.print(options)
end
