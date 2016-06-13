Given(/^I want to download images from (\S+) with special tag and save them using (.*)$/) do |board, pattern|
  @tag = SPECIAL_MATRIX[board]

  filenames = pattern == "default pattern" ? "" : "-f #{pattern}"

  @cmd = "ruby danbooru.rb -l posts=#{POSTS_COUNT} #{filenames} -b #{board} #{@tag}"
end
