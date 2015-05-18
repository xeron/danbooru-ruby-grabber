Given(/^I want to download images from (.*) and save them using (.*)$/) do |board, pattern|
  @fm = FileMagic.new

  @board = board
  @tag = "touhou"
  @per_page = 3
  @pages = 2
  @posts = @per_page * @pages
  @bbs_file = File.join(@tag, "files.bbs")

  limits = [
    "-l per_page=#{@per_page} -l pages=#{@pages}",
    "-l posts=#{@posts}"
  ]
  filenames = pattern == "default pattern" ? "" : " -f #{pattern}"
  @cmd = "ruby danbooru.rb #{limits.sample}#{filenames} -b #{@board} #{@tag}"
end

When(/^I run script to download images using (.*)$/) do |saver|
  @cmd += case saver
  when "default saver" then ""
  when "curl" then " -c"
  when "wget" then " -w"
  end
  puts @cmd

  output = `#{@cmd}`

  @missed_count = output.split("\n").grep("File url is unknown.").size
  @files = list_files(@tag)
  @images = @files - ["files.bbs"]
end

Then(/^I should see downloaded images$/) do
  @images_count = @posts - @missed_count

  expect(@images.size).to eq @images_count
  @images.each do |image|
    expect(@fm.file(File.join(@tag, image))).to match "image"
  end
end

Then(/^I should see images and tags in bbs file$/) do
  bbs = File.open(@bbs_file).read

  expect(bbs.split("\n").size).to eq @images_count
  expect(bbs).to match @tag
  @images.each do |image|
    expect(bbs).to match Regexp.new("^#{Regexp.escape(image)}.*#{@tag}.*\\n")
  end
end
