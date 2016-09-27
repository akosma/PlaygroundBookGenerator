require 'fileutils'

BOOK = "Sample.playgroundbook"

task default: %w[clean book]

task :clean do
    FileUtils.rm_rf(BOOK) if File.exist?(BOOK)
end

task :book do
    ruby "generator.rb --in sample.md --out #{BOOK} --verbose"
end

task :test do
  ruby "test.rb"
end

