require 'fileutils'
require 'filemagic'

TAGS = "touhou"
POOLS_MATRIX = {
  "danbooru" => {"id" => 364, "name" => "Nanoha/Fate doujin"},
  "konachan" => {"id" => 4, "name" => "Clannad Wallpapers (Zoomlayer + Logo + Name)"},
  "e621" => {"id" => 5412, "name" => "MLP: Still Images & Complete Animation Loops"},
  "behoimi" => {"id" => 13, "name" => "Rumpalicious!"},
  "yandere" => {"id" => 1184, "name" => "E☆2 Etsu Magazine vol. 22 2009-12"}
}

# Clean all files before and after each scenario
Before do
  clean_files
end

After do
  clean_files
end

def clean_files
  pools_dirs = POOLS_MATRIX.map { |k,v| v["name"] }
  ([TAGS] + pools_dirs).each do |dir|
    actual_dir = sanitize_filename(dir)
    FileUtils.rm_r(actual_dir) if Dir.exists?(actual_dir)
  end
end

def list_files(dir, pattern = "*")
  Dir.chdir(dir) do
    Dir[pattern]
  end
end

def sanitize_filename(filename)
  filename.gsub(/[\?\*\/\\]/, "_").gsub(" ", "_")
end
