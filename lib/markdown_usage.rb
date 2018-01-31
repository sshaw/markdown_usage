require "tty/markdown"
require "markdown_usage/version"

module MarkdownUsage
  Error = Class.new(StandardError)

  HEADING = /\A(\#{1,6})/
  ALT_HEADING = /\A([-=]+)\s*\Z/
  ALT_HEADING_LEVELS = { "=" => 1, "-" => 2 }.freeze

  STACKTRACE = /\A(.+):\d+:in\s+`(.+)'/

  EXTENSIONS = %w[md markdown].freeze

  class << self
    #
    # Print the calling program's usage based on +options+.
    # See README for a list of +options+.
    #
    def print(options = nil)
      options ||= {}

      output = options[:output] || $stdout
      exitcode = options.include?(:exit) ? options[:exit] : 0
      raise_errors = options.include?(:raise_errors) ? options[:raise_errors] : true

      error("Usage document cannot be found", raise_errors) and return unless defined?(DATA) || options[:source]

      if !options[:source]
        lines = DATA.readlines
      else
        source = find_readme(options[:source], find_root_directory)
        error("Cannot find usage source: #{options[:source]}", raise_errors) and return unless source

        lines = File.readlines(source)
      end

      output.puts TTY::Markdown.parse(extract_usage(lines, options[:sections]))
      exit exitcode unless exitcode == false
    rescue => e
      error(e, raise_errors)
    end

    private

    def find_root_directory
      # caller[0] = MarkdownUsage.print
      # caller[1] = May be caller or MarkdownUsage(), skip the latter
      # caller[2] = May be caller
      root = "."
      return root unless caller[1] =~ STACKTRACE

      root = File.dirname($1)
      return root if $2 != "MarkdownUsage"

      root = File.dirname($1) if caller[2] =~ STACKTRACE
      root
    end

    def find_readme(source, caller_root)
      return source if File.exists?(source)

      roots = [ caller_root ]
      roots << File.dirname(roots[0]) if %w[bin exe].include?(File.basename(roots[0]))

      if source != "README"
        roots.map { |dir| File.join(dir, source) }.find { |path| File.exists?(path) }
      else
        roots.each do |dir|
          readme = EXTENSIONS.map { |ext| File.join(dir, "README.#{ext}") }.find { |path| File.exists?(path) }
          return readme if readme
        end

        nil
      end
    end

    def error(message, raise_errors = false)
      raise Error, message if raise_errors
      warn "MarkdownUsage warning: #{message}"
      true
    end

    def extract_usage(lines, sections)
      sections = Array(sections).map { |text| Regexp.quote(text) }
      return lines.join("") unless sections.any?

      usage = ""
      while lines.any?
        sections.each do |pat|
          next unless lines[0] =~ /#{HEADING}\s*#{pat}/ || lines[0] =~ /\A#{pat}/ && lines[1] =~ ALT_HEADING

          # TTY::Markdown (Kramdown) chooses the last char to denote heading level
          cur_level = lines[0][0] == "#" ? $1.size : ALT_HEADING_LEVELS[$1[-1]]

          usage << lines.shift

          while lines.any?
            next_level = if lines[0] =~ /#{HEADING}\s*\S/
                           $1.size
                         elsif lines[0] =~ /./ && lines[1] =~ ALT_HEADING
                           ALT_HEADING_LEVELS[$1[-1]]
                         end

            break if next_level && next_level <= cur_level
            usage << lines.shift
          end
        end

        lines.shift
      end

      usage
    end
  end
end

#
# Calls MarkdownUsage.print. See README for +options+.
#
def MarkdownUsage(options = nil)
  MarkdownUsage.print(options)
end
