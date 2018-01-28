# MarkdownUsage

[![Build Status](https://secure.travis-ci.org/sshaw/markdown_usage.svg)](https://secure.travis-ci.org/sshaw/markdown_usage)

Output a colorized version of your program's usage using a Markdown document embedded in your script, from your project's README, or anywhere else.

`MarkdownUsage` uses [`TTY::Markdown`](https://github.com/piotrmurach/tty-markdown) to make
your program's usage look like this:

![MarkdownUsage output](usage.png)

If your program does not use Ruby or you want to minimize your dependencies use [the `markdown_usage` Script](#markdown_usage-script).

## Installation

Add this line to your application's Gemfile:

**Note: gem is not yet published**

```ruby
gem "markdown_usage"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install markdown_usage

## Usage

When it's time to display your program's usage call `MarkdownUsage.print` or `MarkdownUsage()` with the [desired configuration options](#options).
By default it will look for the usage in [the invoking code's `__END__` section](http://ruby-doc.org/docs/keywords/1.9/Object.html#method-i-__END__),
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

### Using a File

To extract the program's usage from the `Usage` section of your project's README:

```rb
MarkdownUsage.print(:source => "README", :sections => "Usage")
```

This will look for a file name `README.md` or `README.markdown` in your project's root directory.

Multiple sections can be extracted:

```rb
MarkdownUsage.print(:source => "README", :sections => %w[Usage Support])
```

If your project is released as a gem, be sure to add the README to the gem's list of files:

```rb
s.extra_rdoc_files = %w[README.md]
s.files = Dir["lib/**/*.rb"] + s.test_files + s.extra_rdoc_files
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

Sections to extract from the `:source`. These must be the headings without the leading format
characters.

Can be a `String` or an `Array` of strings.

#### `:source`

Location of usage Markdown to print, defaults to your programs's  `__END__` section.

To load a Markdown `README` from your project's root directory set this to `README`.

Relative paths will be loaded relative to your project's root directory.

#### `:raise_errors`

If `true` a `MarkdownUsage::Error` will be raised when `MarkdownUsage` encounters a problem.
If `false` a warning is sent to `stderr` instead.

## `markdown_usage` Script

**markdown_usage** - embed or output a colorized version of your program's usage from a Markdown document

### Usage

```
markdown_usage [-h] [-s sections] [-o output] markdown_doc
```

`markdown_doc` is the Markdown to use.

- `-h` show this help menu
- `-o` `output`   where to output the colorized usage, defaults to `stdout`
- `-s` `sections` sections to extract from `markdown_doc`

#### `output`

This can be a file or a script. If it's a script it will be added to the script's data section.
Existing data section context will be overwritten.

We assume `output` is a script if one of the following are true:

- It ends in `.rb` or `.pl` (these languages support data sections)
- It is executable
- It contains  *nix shebang on the first line (e.g., `#!/bin/env ruby`)

#### `sections`

These must be the headings without the leading format characters. Multiple sections can be separated by a comma.

## See Also

- [`TTY::Markdown`](https://github.com/piotrmurach/tty-markdown) - without this there would be no `MarkdownUsage`
- Perl's [`Pod::Usage`](https://metacpan.org/pod/Pod::Usage) - the inspiration for `MarkdownUsage`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
