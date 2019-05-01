Given(/^I want to download images from (\S+) pool and save them using (.*)$/) do |board, pattern|
  id = POOLS_MATRIX[board]['id']
  @tags = POOLS_MATRIX[board]['name']

  filenames = pattern == 'default pattern' ? '' : "-f #{pattern}"

  @cmd = "ruby danbooru.rb -l posts=#{POSTS_COUNT} #{filenames} -b #{board} -P #{id}"
end
