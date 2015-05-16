def clean_files
  %w(touhou).each do |dir|
    Dir.rmdir(dir)
  end
end

# Clean all files before and after each scenario
Before do
  clean_files
end

After do
  clean_files
end
