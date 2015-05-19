Given(/^I want to download images from (\S+) and save them using (.*)$/) do |board, pattern|
  per_page = 3
  pages = 2
  @posts_count = per_page * pages
  @tag = TAGS
  limits = [
    "-l per_page=#{per_page} -l pages=#{pages}",
    "-l posts=#{@posts_count}"
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
