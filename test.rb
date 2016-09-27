require 'test/unit'
require './lib'
require 'ostruct'
require 'fileutils'
require 'kramdown'
require 'plist'

class TestAdd < Test::Unit::TestCase
    DEFAULT_OUTPUT_FILENAME = "Book.playgroundbook"
    DEFAULT_CHAPTER_NAME = "Chapter.playgroundchapter"
    TEST_BOOK = "Test.playgroundbook"
    SOURCE = "sample.md"
    BOOK = "Sample.playgroundbook"
    PAGES_COUNT = 6

    def cleanup
        FileUtils.rm_rf(BOOK) if File.exist?(BOOK)
        FileUtils.rm(TEST_BOOK) if File.exist?(TEST_BOOK)
    end

    def setup
        cleanup
        FileUtils.touch(TEST_BOOK)
    end

    def teardown
        cleanup
    end

    def test_input_option_cannot_be_nil
        opts = OpenStruct.new
        valid, error_message = validate_options(opts)
    	assert !valid
        assert_not_nil error_message
    end

    def test_input_option_file_must_exist
        opts = OpenStruct.new
        opts.input = 'non_existent_file.txt'
        valid, error_message = validate_options(opts)
        assert !valid
        assert_not_nil error_message
    end

    def test_default_output_filename_if_not_provided
        opts = OpenStruct.new
        opts.input = SOURCE
        opts.output = nil
        valid, error_message = validate_options(opts)
        assert valid
        assert_nil error_message
        assert_equal opts.output, DEFAULT_OUTPUT_FILENAME
    end

    def test_correct_output_extension_if_needed
        opts = OpenStruct.new
        opts.input = SOURCE
        opts.output = 'whatever'
        valid, error_message = validate_options(opts)
        assert valid
        assert_nil error_message
        assert opts.output.end_with? ".playgroundbook"
    end

    def test_default_chapter_name_if_not_provided
        opts = OpenStruct.new
        opts.input = SOURCE
        opts.output = BOOK
        valid, error_message = validate_options(opts)
        assert valid
        assert_nil error_message
        assert_equal opts.chapter, DEFAULT_CHAPTER_NAME
    end

    def test_cannot_overwrite_existing_output_file
        opts = OpenStruct.new
        opts.input = SOURCE
        opts.output = TEST_BOOK
        valid, error_message = validate_options(opts)
        assert !valid
        assert_not_nil error_message
    end

    def test_read_and_parse_input
        opts = OpenStruct.new
        opts.input = SOURCE
        opts.output = BOOK
        valid, error_message = validate_options(opts)
        assert valid
        assert_nil error_message

        pages = read_input(opts)
        assert_equal pages.count, PAGES_COUNT
    end

    def test_create_book
        opts = OpenStruct.new
        opts.input = SOURCE
        opts.output = BOOK
        valid, error_message = validate_options(opts)
        assert valid
        assert_nil error_message

        pages = read_input(opts)
        assert_equal pages.count, PAGES_COUNT

        create_structure(opts)

        book_manifest = create_book_manifest(opts)
        book_manifest_path = save_book_manifest(opts, book_manifest)

        chapter_manifest = create_chapter_manifest(opts)
        create_slides(opts, pages, chapter_manifest)

        assert File.exist?(book_manifest_path)
        assert_equal chapter_manifest['Pages'].count, PAGES_COUNT
    end
end

