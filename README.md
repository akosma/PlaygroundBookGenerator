# Swift Playgrounds for iPad Book Generator

This Ruby program parses a Markdown file and generates a Swift
Playgrounds for iPad book (file with the extension .playgroundbook.)

## How It Works

Check the file `sample.md` and `Sample.playgroundbook` files for
examples of input and output. The current version of this program simply
generates a book with a single chapter, separating the pages with
horizontal rulers (that is, the `---` marker in Markdown, which
translates as a `<HR>` tag in HTML.)

It parses the first `<H1>` elements and uses its value as the title of
the chapter.

You can test the output of this tool by dropping the file
`Sample.playgroundbook` in the iCloud/Playgrounds folder of the Finder.

Alternatively, the `Rakefile` included in this project shows how to use
the command line options.

## Requirements

It requires the kramdown and plist gems:

    gem install kramdown
    gem install plist

## License

See the LICENSE file.

