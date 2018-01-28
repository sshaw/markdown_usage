require "minitest/autorun"
require "climate_control"
require "markdown_usage"
require "tty/markdown"
require "io/grab"

class TestMarkdownUsage < Minitest::Test
  def setup
    @root = File.dirname(__FILE__)
  end

  def test_usage_extraxted_from___END___by_default
    assert_equal TTY::Markdown.parse("# 1\n1\nFoo\n"), ruby(fixture("script.rb"))
  end

  def test_exits_0_by_default
    ruby fixture("script.rb")
    assert_equal $?.exitstatus, 0
  end

  def test_exits_using_the_given_exit_value
    ruby fixture("script.rb"), "MU_TEST_EXIT" => "5"
    assert_equal 5, $?.exitstatus
  end

  def test_does_not_exit_when_exit_is_false
    assert_match /no_exit\Z/, ruby(fixture("script.rb"), "MU_TEST_EXIT" => "false")
  end

  def test_raise_error_true_by_default
    error = assert_raises(MarkdownUsage::Error) { MarkdownUsage.print(:source => fixture("__foo__")) }
    assert_match /usage source/, error.message
  end

  def test_outputs_errors_to_stderr_when_raise_error_false
    output = $stderr.grab { MarkdownUsage.print(:source => fixture("__foo__"), :raise_errors => false) }
    assert_match /\bMarkdownUsage warning:/, output
  end

  def test_usage_extracted_form_source
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README1.md"))
    assert_equal TTY::Markdown.parse_file(fixture("README1.md")), output
  end

  def test_single_section_extracted_form_source
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README1.md"), "MU_TEST_SECTIONS" => "1,3")
    assert_equal TTY::Markdown.parse("# 1\n1\n## 1.2\n1.2\n# 3\n3\n"), output
  end

  def test_usage_extracted_form_README_source
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => "README")
    assert_equal TTY::Markdown.parse("# Foo"), output
  end

  def test_usage_extracted_form_README_in_project_root
    assert_equal TTY::Markdown.parse("## 1.2\n1.2\n"), ruby(fixture("bin/script.rb"))
  end

  def test_multiple_sections_extracted_form_source
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README1.md"), "MU_TEST_SECTIONS" => "3")
    assert_equal TTY::Markdown.parse("# 3\n3\n"), output
  end

  def test_extracts_level1_sections
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README2.md"), "MU_TEST_SECTIONS" => "1")
    assert_equal TTY::Markdown.parse("1\n=\nA\n"), output
  end

  def test_extracts_level2_sections
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README2.md"), "MU_TEST_SECTIONS" => "2")
    assert_equal TTY::Markdown.parse("2\n--\nB\n\n"), output
  end

  def test_extracts_level3_sections
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README2.md"), "MU_TEST_SECTIONS" => "3")
    assert_equal TTY::Markdown.parse("### 3\nC\n\n"), output
  end

  def test_extracts_level4_sections
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README2.md"), "MU_TEST_SECTIONS" => "4")
    assert_equal TTY::Markdown.parse("#### 4 ####\nD\n\n"), output
  end

  def test_extracts_level5_sections
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README2.md"), "MU_TEST_SECTIONS" => "5")
    assert_equal TTY::Markdown.parse("##### 5\nE\n\n"), output
  end

  def test_extracts_level6_sections
    output = ruby(fixture("script.rb"), "MU_TEST_SOURCE" => fixture("README2.md"), "MU_TEST_SECTIONS" => "6")
    assert_equal TTY::Markdown.parse("###### 6 ######\nF\n\n"), output
  end

  def fixture(basename)
    File.join(@root, "fixtures/#{basename}")
  end

  def ruby(script, env = {}, swallow = nil)
    ClimateControl.modify env do
      # TODO: really safe to assume $:[0] has what we want?
      cmd = sprintf("%s -I %s %s", RbConfig::CONFIG["RUBY_INSTALL_NAME"], $:[0], script)
      cmd << sprintf("%s>%s", swallow, File::NULL) if swallow

      `#{cmd}`
    end
  end
end
