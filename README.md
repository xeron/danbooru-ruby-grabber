## Overview

danbooru-ruby-grabber is a danbooru downloader — simple script which downloads images from danbooru.donmai.us, konachan.com, e621.net, behoimi.org and yande.re. Support of any danbooru-powered site could be added easily.

## Usage

```
Usage: danbooru.rb [options] "tags"
    -b, --board BOARDNAME            Target board. Supported options: danbooru (default), konachan, e621, behoimi, yandere
    -P, --pool POOLID                Pool ID (tags will be ignored)
    -w, --wget                       Download using wget
    -c, --curl                       Download using curl
    -s, --storage DIR                Storage mode (all images in one dir and symlinks in tagged dirs)
    -f, --filename PATTERN           Filename pattern. Supported options: id (default), md5, tags, url (old default)
    -u, --user USERNAME              Username
    -p, --password PASSWORD          Password
    -h, --help                       Print a help message
```

## Notes

* To prevent duplicates files are stored using post id based filenames. You can change this behavior using `-f` option.

* Using `-f tags` could miss some files due to filesystems' filename length limitation.

* Always use `-u` and `-p` options with danbooru, because they block requests without login and password.

* Number of tags you can use at the same time could be limited by board (for example danbooru limits basic accounts by 2 tags)

* Images are stored in tag-named directory.

* Script creates file named `files.bbs` with all tags of each image.

## Installation

You need json and nokogiri gems to be installed. You can install them by this command:

`gem install json nokogiri`

Note: may be you need to use `sudo`.

## Bonus

Have fun.

Author: Xeron  
E-mail: xeron.oskom@gmail.com  
Homepage: http://blog.xeron.me
