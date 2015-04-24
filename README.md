danbooru-ruby-grabber is a danbooru downloader — simple script which downloads images from danbooru.donmai.us, konachan.com, e621.net, behoimi.org and yande.re. Support of any danbooru-powered site could be added easily.

```
Usage: danbooru.rb [options] "tags"
    -b, --board BOARDNAME            Target board. Supported options: danbooru (default), konachan, e621, behoimi, yandere
    -P, --pool POOLID                Pool ID (tags will be ignored)
    -w, --wget                       Download using wget
    -c, --curl                       Download using curl
    -s, --storage DIR                Storage mode (all images in one dir and symlinks in tagged dirs)
    -u, --user USERNAME              Username
    -p, --password PASSWORD          Password
    -h, --help                       Print a help message
```

Please always use -u and -p options with danbooru, because they block requests without login and password.

You can use up to 2 tags with basic account. Images are stored in tag-named directory. Also script creates file named `files.bbs` with all tags of each image.

You need json and nokogiri gems to be installed. You can install them by this command:

`gem install json nokogiri`

Note: may be you need to use `sudo`.

Have fun.

Author: Xeron  
E-mail: xeron.oskom@gmail.com  
Homepage: http://blog.xeron.me
