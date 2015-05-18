require 'fileutils'
require 'filemagic'

# Clean all files before and after each scenario
Before do
  clean_files
end

After do
  clean_files
end

def clean_files
  %w(touhou).each do |dir|
    FileUtils.rm_r(dir) if Dir.exists?(dir)
  end
end

def list_files(tag, pattern = "*")
  Dir.chdir(tag) do
    Dir[pattern]
  end
end
