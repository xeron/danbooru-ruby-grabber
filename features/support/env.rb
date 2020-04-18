require 'fileutils'
require 'filemagic'

TAGS_MATRIX = {
  'danbooru' => 'touhou older',
  'testbooru' => 'tagme highres',
  'konachan' => 'robotics;notes',
  'behoimi' => 'touhou',
  'yandere' => 'touhou'
}.freeze
POOLS_MATRIX = {
  'danbooru' => { 'id' => 364, 'name' => 'Nanoha/Fate doujin' },
  'testbooru' => { 'id' => 1, 'name' => 'Pool 1' },
  'konachan' => { 'id' => 4, 'name' => 'Clannad Wallpapers (Zoomlayer + Logo + Name)' },
  'behoimi' => { 'id' => 13, 'name' => 'Rumpalicious!' },
  'yandere' => { 'id' => 1184, 'name' => 'E☆2 Etsu Magazine vol. 22 2009-12' }
}.freeze
SPECIAL_MATRIX = {
  'danbooru' => 'user:randeel',
  'testbooru' => 'user:randeel',
  'konachan' => 'vote:3:opai',
  'behoimi' => 'user:darkgray',
  'yandere' => 'date:2016-05-14'
}.freeze
PER_PAGE = 3
PAGES = 2
POSTS_COUNT = PER_PAGE * PAGES

# Clean all files before and after each scenario
Before do
  clean_files
end

After do
  clean_files
end

def clean_files
  pools_dirs = POOLS_MATRIX.values.map { |v| v['name'] }
  (TAGS_MATRIX.values + pools_dirs + SPECIAL_MATRIX.values).each do |dir|
    actual_dir1 = sanitize_filename(dir, false)
    actual_dir2 = sanitize_filename(dir, true)
    FileUtils.rm_r(actual_dir1) if Dir.exist?(actual_dir1)
    FileUtils.rm_r(actual_dir2) if Dir.exist?(actual_dir2)
  end
end

def list_files(dir, pattern = '*')
  Dir.chdir(dir) do
    Dir[pattern]
  end
end

def sanitize_filename(filename, pool = false)
  result = filename.gsub(%r{[\?\*\/\\\:]}, '_')
  space_sub = pool ? '_' : '+'
  result.gsub(' ', space_sub)
end
