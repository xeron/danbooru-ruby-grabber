When(/^I run script to download images using (.*)$/) do |saver|
  @cmd += case saver
  when "default saver" then ""
  when "curl" then " -c"
  when "wget" then " -w"
  end
  puts @cmd

  output = `#{@cmd}`

  missed_count = output.split("\n").grep("File url is unknown.").size
  @images_count = POSTS_COUNT - missed_count
end

Then(/^I should see downloaded images$/) do
  fm = FileMagic.new
  @dir = sanitize_filename(@tag)
  files = list_files(@dir)
  @images = files - ["files.bbs"]

  expect(@images.size).to eq @images_count
  @images.each do |image|
    expect(fm.file(File.join(@dir, image))).to match /image|Macromedia Flash|Zip archive data/
  end
end
