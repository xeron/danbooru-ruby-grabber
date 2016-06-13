Given(/^I want to download images from (\S+) with special tag and save them using (.*)$/) do |board, pattern|
  @tag = SPECIAL_MATRIX[board]
  limits = [
    "-l per_page=#{PER_PAGE} -l pages=#{PAGES}",
    "-l posts=#{POSTS_COUNT}"
  ]
  filenames = pattern == "default pattern" ? "" : "-f #{pattern}"

  @cmd = "ruby danbooru.rb #{limits.sample} #{filenames} -b #{board} #{@tag}"
end
