def clean_files
  Dir.rmdir("touhou")
end

# Clean all files before and after each scenario
Before do
  clean_files
end

After do
  clean_files
end
