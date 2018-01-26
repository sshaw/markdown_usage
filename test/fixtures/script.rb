require "markdown_usage"

options = {}

if ENV["MU_TEST_EXIT"]
  v = ENV["MU_TEST_EXIT"]
  options[:exit] = v =~ /\A\d+\z/ ? v.to_i : v == "true"
end

if ENV["MU_TEST_SECTIONS"]
  v = ENV["MU_TEST_SECTIONS"].split(",")
  options[:sections] = v.one? ? v[0] : v
end

options[:raise_error] = ENV["MU_TEST_ERROR"] == "true" if ENV["MU_TEST_ERROR"]
options[:source] = ENV["MU_TEST_SOURCE"] if ENV["MU_TEST_SOURCE"]

MarkdownUsage.print(options)
puts "no_exit"
__END__
# Section 1
1
