Given(/^I want to download images from (\S+) pool and save them using (.*)$/) do |board, pattern|
  @posts_count = 6
  id = POOLS_MATRIX[board]["id"]
  @tag = POOLS_MATRIX[board]["name"]

  filenames = pattern == "default pattern" ? "" : "-f #{pattern}"

  @cmd = "ruby danbooru.rb -l posts=#{@posts_count} #{filenames} -b #{board} -P #{id}"
end

Then(/^I should see images in bbs file$/) do
  bbs_file = File.join(@dir, "files.bbs")
  bbs = File.open(bbs_file).read

  expect(bbs.split("\n").size).to eq @images_count
  @images.each do |image|
    expect(bbs).to match Regexp.new("^#{Regexp.escape(image)}.*\\n")
  end
end
