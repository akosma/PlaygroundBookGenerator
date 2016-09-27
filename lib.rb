# Parse command line arguments and returns an OpenStruct
def parse_arguments
    opts = OpenStruct.new
    OptionParser.new do |opt|
        opt.on('-i', '--in FILENAME', 'Input in Markdown format') { |o| opts.input = o }
        opt.on('-o', '--out FILENAME', 'Output in Playgroundbook format') { |o| opts.output = o }
        opt.on('-v', '--verbose', 'Toggle verbose mode') { |o| opts.verbose = o }
    end.parse!

    opts
end

# Validate command line arguments
# If this method returns false, the program should exit
def validate_options(opts)
    if opts.input == nil
        return false, "Input file missing; `generator -h` for help"
    end

    if !File.exist?(opts.input)
        return false, "Wrong input file"
    end

    if opts.output == nil
        opts.output = "Book.playgroundbook"
        puts "Output filename not provided, using #{opts.output}" if opts.verbose
    end

    if !opts.output.end_with?(".playgroundbook")
        opts.output = "#{opts.output}.playgroundbook"
        puts "Using #{opts.output} as output filename" if opts.verbose
    end

    if File.exist?(opts.output)
        return false, "File #{opts.output} already exists. Exiting."
    end

    if opts.chapter == nil
        opts.chapter = "Chapter.playgroundchapter"
        puts "Using #{opts.chapter} as chapter name" if opts.verbose
    end

    return true, nil
end

# Parse the input file and split it using the HR tags
def read_input(opts, separator = :hr)
    text = File.read(opts.input)
    puts "Reading #{opts.input} as input" if opts.verbose
    source = Kramdown::Document.new(text)

    pages = []
    current_page = Kramdown::Document.new('')
    puts "Parsing #{opts.input}" if opts.verbose
    source.root.children.each do |element|
        if element.type == separator
            pages << current_page
            current_page = Kramdown::Document.new('')
        else
            current_page.root.children << element
        end
    end

    pages << current_page
    puts "Found #{pages.count} slides on #{opts.input}" if opts.verbose
    pages
end

# Create the basic folder structure
def create_structure(opts)
    puts "Creating folder structure" if opts.verbose
    FileUtils.mkdir("#{opts.output}")
    FileUtils.mkdir("#{opts.output}/Contents")
    FileUtils.mkdir("#{opts.output}/Contents/Chapters")
    FileUtils.mkdir("#{opts.output}/Contents/Resources")
    FileUtils.mkdir("#{opts.output}/Contents/Chapters/#{opts.chapter}")
    FileUtils.mkdir("#{opts.output}/Contents/Chapters/#{opts.chapter}/Pages")
    FileUtils.mkdir("#{opts.output}/Contents/Chapters/#{opts.chapter}/Sources")
end

# Create the main manifest files
def create_book_manifest(opts)
    identifier = "com.akosma.#{opts.output}"
    book_manifest = {
        'Version' => '1.0',
        'ContentIdentifier' => identifier,
        'ContentVersion' => '1',
        'DeploymentTarget' => 'ios10.0',
        'Name' => opts.output,
        'ImageReference' => 'icon.png',
        'Chapters' => [ opts.chapter ]
    }
    book_manifest
end

def save_book_manifest(opts, book_manifest)
    book_manifest_path = "#{opts.output}/Contents/Manifest.plist"
    File.write(book_manifest_path, book_manifest.to_plist)
    book_manifest_path
end

# Create the chapter manifest
def create_chapter_manifest(opts)
    chapter_manifest = {
        'Name' => 'Chapter',
        'Pages' => []
    }
    chapter_manifest
end

# Create a slide manifest
def create_slide_manifest(opts, title)
    slide_manifest = {
        'Name' => title,
        'LiveViewMode' => 'HiddenByDefault',
        'LiveViewEdgeToEdge' => false
    }
    slide_manifest
end

def create_slides(opts, pages, chapter_manifest)
    pages.each_with_index do |page, index|
        title = "Page #{index}"

        page_path = "#{opts.output}/Contents/Chapters/#{opts.chapter}/Pages/#{title}.playgroundpage"
        FileUtils.mkdir(page_path)

        slide_manifest = create_slide_manifest(opts, title)
        File.write("#{page_path}/Manifest.plist", slide_manifest.to_plist)

        # This is the command that makes the magic:
        # wrap the markdown code inside a special Swift comment prefixed with a colon
        File.write("#{page_path}/Contents.swift", "/*:\n#{page.to_kramdown}\n*/")

        # Add the new slide to the chapter manifest
        chapter_manifest['Pages'] << "#{title}.playgroundpage"
    end
    File.write("#{opts.output}/Contents/Chapters/#{opts.chapter}/Manifest.plist", chapter_manifest.to_plist)
end

