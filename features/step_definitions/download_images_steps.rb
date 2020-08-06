When(/^I run script to download images using (.*)$/) do |saver|
  @cmd += SAVER_MATRIX[saver]
  log(@cmd)

  output = `#{@cmd}`

  missed_count = output.split("\n").grep(/File url is unknown for .* fail/).size
  @images_count = POSTS_COUNT - missed_count
end

Then(/^I should see downloaded images by (.*)$/) do |source|
  fm = FileMagic.new
  @dir = File.join(BASE_DIR, sanitize_filename(@tags, pool: source == 'pool'))
  files = list_files(@dir)
  @images = files - ['files.bbs']

  expect(@images.size).to eq @images_count
  @images.each do |image|
    expect(fm.file(File.join(@dir, image))).to match(/image|Macromedia Flash|Zip archive data|WebM|MP4|MPEG/)
  end
end

Then(/^I should see images in bbs file$/) do
  bbs_file = File.join(@dir, 'files.bbs')
  bbs = File.open(bbs_file).read

  expect(bbs.split("\n").size).to eq @images_count
  @images.each do |image|
    expect(bbs).to match Regexp.new("^#{Regexp.escape(image)}.*\\n")
  end
end
