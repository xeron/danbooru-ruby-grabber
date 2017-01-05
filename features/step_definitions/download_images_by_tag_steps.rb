Given(/^I want to download images from (\S+) and save them using (.*)$/) do |board, pattern|
  @tag = TAGS_MATRIX[board]
  limits = [
    "-l per_page=#{PER_PAGE} -l pages=#{PAGES}",
    "-l posts=#{POSTS_COUNT}"
  ]
  filenames = pattern == "default pattern" ? "" : "-f #{pattern}"

  @cmd = "ruby danbooru.rb #{limits.sample} #{filenames} -b #{board} #{@tag}"
end

Then(/^I should see images and tags in bbs file$/) do
  bbs_file = File.join(@dir, "files.bbs")
  bbs = File.open(bbs_file).read

  expect(bbs.split("\n").size).to eq @images_count
  @images.each do |image|
    expect(bbs).to match Regexp.new("^#{Regexp.escape(image)}.*#{@tag}.*\\n")
  end
end
