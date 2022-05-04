# XettelkastenServer

`XettelkastenServer` provides a simple [`cowboy`](https://github.com/ninenines/cowboy) backed [Elixir](https://elixir-lang.org/) webserver to serve a directory of
interlinked markdown files, à la the [Zettelkasten Method](https://zettelkasten.de/posts/overview/)
of note taking.

To avoid over-frequent reading of your filesystem, `XettelkastenServer` loads all existing notes on server startup, and uses [`file_system`](https://github.com/falood/file_system) to watch for changes, additions, and deletions under the specified directory (see the Configuration section below). For this to work, you must have the necessary filesystem event monitor for your operating system installed:

* for Linux, `inotify`, which you can install via `apt-get install inotify-tools`
* for MacOS, `fsevents`, which comes installed in macOS by default

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xettelkasten_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xettelkasten_server, "~> 0.1.0"}
  ]
end
```

## Usage

### Configuration

`XettelkastenServer` requires two configuration variables to be set in your `config.exs` (or environment-specific config file)

```elixir
# the port your server will run on
config :xettelkasten_server, cowboy_port: 8080
# the directory where the server will look for markdown files
config :xettelkasten_server, notes_directory: "notes"
```

An optional configuration variable, `:auto_commit` is available as well. If set to `true` this will spin up a GenServer whose
role is to watch your set `notes_directory` and commit any changes every 10 minutes. This allows you to focus on writing your notes,
letting the server handle keeping your notes up to date in version control.

This feature is strongly opinionated: it expects the command `git push origin HEAD`
to succeed under your local git configuration. Therefore it is turned off by default.

```elixir
config :xettelkasten_server, auto_commit: true
```

Once these variables have been set, you can start your server by running

`> mix run --no-halt`

and, in your browser, navigate to `http://localhost:8080/`

## Header metadata

A Markdown note to be read by `XettelkastenServer` can have a metadata header in YAML format. This block must be at the very top of the file, and separated by the Markdown body by a line containing three dashes `---`.

Two keys are currently valid in this header, `title` and `tags`. Title should be a string, and tags a list.

For example

```
title: My Note
tags:
- tag_one
- tag with multiple words
---
Markdown body starts here
```

How the title and tags are used is explained in the following section.

## `XettelkastenServer`-flavored Markdown

In addition to all standard Markdown, `XettelkastenServer` provides some additional
parsing to make itself as useful to you as possible.

### Backlinks

Text between two sets of square braces `[[...]]` will be parsed as a backlink to another note
in your directory. The content between the two sets of braces should be a parseable
representation of the filesystem location of the linked note. To be parseable, the content
must

1. use slashes to denote nested directories
2. use spaces or underscores to represent underscores in the file name (spaces around slashes are ignored)

**NB** capitalization is ignored

For example, to link to a file located at `<root>/nested/deeply/my_note.md`, the
following strings would be valid backlink content

`[[nested/deeply/my_note]]`

`[[Nested / Deeply / My Note]]`


#### Custom Text

If you want the visible text of a backlink to be different than
the parseable representation of its path, you can add a second
field to the backlink text, separated by a pipe `|`. The
content before the pipe will be used to locate the linked note,
and the content after the pipe will be the text displayed in
the rendered HTML.

For example,

`[[my_note|A Fancy Note]]` would link to `<root>/my_note.md`,
but the link would be displayed with the text "My Fancy Note".

### Tags

Tags can be defined in two ways

1. in the YAML metadata header as described above
2. in the Markdown body prepended by a `#` mark

Tags defined in the body of the note cannot have multiple words, but can use
underscores for semantic clarity, (e.g. `#multi_part_tag`)

### Initial `<h1>` HTML Tag

To maintain uniformity of display between notes, `XettelkastenServer` ensures that the first element of every rendered note is an `<h1>` header tag. The content of this tag is decided by the first extant item in the list below

1. An `<h1>` header defined directly at the top of the note's Markdown (e.g. `# My Header`)
2. A value under the `title` key in the note's YAML metadata
3. A capitalized and formatted version of the filesystem path to the note

### Codeblocks

Code contained between backtick triplets will render as a
formatted code block. Adding a language name after the opening
backticks will correctly render syntax highlighting of the
codeblock using Prism.js

<pre>
```elixir
defmodule Foo do
  def bar, do: :ok
end
```
</pre>

will be rendered as

```elixir
defmodule Foo do
  def bar, do: :ok
end
```

## `XettelkastenServer` UI

When you first start your server and head to the root path `/`, you will see a
list of all markdown notes found under your watched directory, including all
nested notes.

When you click through to a note, you will see the body of the note rendered in the
main panel of the screen. In the left-hand (or top, for narrow screens) navigation bar,
you will see

* a link back to the note index
* a list of the tags present in your note
    * clicking on one of these tags will take you to an index view filtered by the given tag
* a list of all links *from* the current note (links that do not resolve to existing files will be styled with a strikethrough)
* a list of all other notes that link *to* the current note

