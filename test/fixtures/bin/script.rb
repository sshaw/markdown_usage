require "markdown_usage"
source   = ENV["MU_TEST_SOURCE"] || "README"
sections = ENV["MU_TEST_SECTIONS"]
MarkdownUsage.print(:source => source, :sections => sections)
