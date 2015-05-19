Given(/^I want to download images from (.*) and save them using (.*)$/) do |board, pattern|
  board = board
  per_page = 3
  pages = 2
  @posts_count = per_page * pages
  @tag = "touhou"

  limits = [
    "-l per_page=#{per_page} -l pages=#{pages}",
    "-l posts=#{@posts_count}"
  ]
  filenames = pattern == "default pattern" ? "" : "-f #{pattern}"

  @cmd = "ruby danbooru.rb #{limits.sample} #{filenames} -b #{board} #{@tag}"
end

When(/^I run script to download images using (.*)$/) do |saver|
  @cmd += case saver
  when "default saver" then ""
  when "curl" then " -c"
  when "wget" then " -w"
  end
  puts @cmd

  output = `#{@cmd}`

  missed_count = output.split("\n").grep("File url is unknown.").size
  @images_count = @posts_count - missed_count
end

Then(/^I should see downloaded images$/) do
  fm = FileMagic.new
  files = list_files(@tag)
  @images = files - ["files.bbs"]

  expect(@images.size).to eq @images_count
  @images.each do |image|
    expect(fm.file(File.join(@tag, image))).to match /image|Macromedia Flash/
  end
end

Then(/^I should see images and tags in bbs file$/) do
  bbs_file = File.join(@tag, "files.bbs")
  bbs = File.open(bbs_file).read

  expect(bbs.split("\n").size).to eq @images_count
  @images.each do |image|
    expect(bbs).to match Regexp.new("^#{Regexp.escape(image)}.*#{@tag}.*\\n")
  end
end
