# MarkdownUsage

[![Build Status](https://secure.travis-ci.org/sshaw/markdown_usage.svg)](https://secure.travis-ci.org/sshaw/markdown_usage)

Output a colorized version of your program's usage using a Markdown document embedded in your script, from your project's README, or anywhere else.

`MarkdownUsage` uses [`TTY::Markdown`](https://github.com/piotrmurach/tty-markdown) to make
your program's usage look like this:

![MarkdownUsage output](usage.png)

If your program does not use Ruby or you want to minimize your dependencies use [the `markdown_usage` Script](#markdown_usage-command).

## Installation

[Ruby](https://www.ruby-lang.org/en/downloads/) is required.

MarkdownUsage can be installed via RubyGems:

    $ gem install markdown_usage

Or via Bundler. Add this line to your application's `Gemfile`:

```ruby
gem "markdown_usage"
```

And then execute:

    $ bundle

## Usage

When it's time to display your program's usage call `MarkdownUsage.print` or `MarkdownUsage()` with the [desired configuration options](#options).
By default it will look for the usage in [the invoking code's data section](http://ruby-doc.org/docs/keywords/1.9/Object.html#method-i-__END__),
output it to `stdout`, and call `exit 0`.

For more info see [Options](#options).

### Using `__END__`

Here's an example script:

```rb
#!/usr/bin/ruby

require "optparse"
require "markdown_usage"

OptionParser.new do |opts|
  opts.on "-h", "--help" do
    MarkdownUsage.print
  end

  opts.on "-o", "--do-something", "My great option" do |opt|
    # ...
  end
end.parse!

# The rest of your amazing program

__END__
**my_command** - command to do somethangz

## Usage

`my_command [options] file`

  * `-a`      This does foo
  * `-b``MAP` Mapping for something

## MAP

Map is a list of blah pairs

## More Info

- [Docs](http://example.com/docs)
- [Bugs](http://example.com/bugs)

```


If you're using this and releasing your script as a gem it must be installed via `gem install --no-wrappers my_gem`
Otherwise, the data section will not be available to due the wrapper script added by RubyGems.

In this case it's better to use a file for the usage

### Using a File

To extract the program's usage from the `Usage` section of your project's README:

```rb
MarkdownUsage.print(:source => "README", :sections => "Usage")
```

This will look for a file named `README.md` or `README.markdown` in your project's root directory.

Multiple sections can be extracted:

```rb
MarkdownUsage.print(:source => "README", :sections => %w[Usage Support])
```

To use a different file specify its path:

```rb
MarkdownUsage.print(:source => "path/to/README.md")
```

When specifying a path you must provide the appropriate extension.

### Options

`MarkdownUsage.print` and `MarkdownUsage()` accept a `Hash` of the following options:

#### `:exit`

Exit status to use after printing usage, defaults to `0`.

Set this to `false` to prevent `exit` from being called.

#### `:output`

File handle to output the usage on. Defaults to `$stdout`. The given handle must
have a `#puts` method.

The usage will *always* contain terminal escape codes.

#### `:sections`

Sections to extract from the `:source`. These must be the headings without the
leading or trailing heading format characters.

If the heading text has other formatting characters, they must be included (see [Examples](#examples)).

Can be a `String` or an `Array` of strings.

#### `:source`

Location of usage Markdown to print, defaults to your program's data (`__END__`) section.

To load a Markdown `README` from your project's root directory set this to `README`.

Relative paths will be loaded relative to your project's root directory.

#### `:raise_errors`

If `true` a `MarkdownUsage::Error` will be raised when `MarkdownUsage` encounters a problem.
If `false` a warning is sent to `stderr` instead.

## `markdown_usage` Command

Embed or output a colorized version of your program's usage from a Markdown document.

### Usage

```
markdown_usage [-hv] [-s sections] [-o output] markdown_doc
```

`markdown_doc` is a file containing the Markdown to use.

- `-h` show this help menu
- `-o` `output`   where to output the colorized usage, defaults to `stdout`
- `-s` `sections` sections to extract from `markdown_doc`
- `-v` show the version

#### `output`

This can be a file or a script. If it's a script it will be added to the script's data section.
Existing data section content will be overwritten.

We assume `output` is a script if one of the following are true:

- It ends in `.rb` or `.pl` (these languages support data sections)
- It contains  *nix shebang on the first line for `ruby` or `perl` e.g., `#!/usr/bin/env ruby`

#### `sections`

These must be the headings without leading or trailing heading format characters.
If the heading text has other formatting characters, they must be included (see [Examples](#examples)).

Multiple sections can be separated by a comma.

### Examples

Output the section `Usage` from `README.md` to `USAGE`:

```
markdown_usage -s Usage README.md > USAGE
```

Output the sections `Usage` and `More Info` from `README.md` to `USAGE`:

```
markdown_usage -s 'Usage,More Info' README.md > USAGE
```

Add the following formatted section to the data section of `script.rb`:

```
markdown_usage -s '`markdown_usage` Command' -o script.rb README.md
```

## See Also

- [`TTY::Markdown`](https://github.com/piotrmurach/tty-markdown) - without this there would be no `MarkdownUsage`
- [tty_markdown](http://github.com/dapplebeforedawn/tty_markdown)
- Perl's [`Pod::Usage`](https://metacpan.org/pod/Pod::Usage) - the inspiration for `MarkdownUsage`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
