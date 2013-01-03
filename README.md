args_parser
===========

* Parse ARGV from command line with DSL.
* http://shokai.github.com/args_parser


Requirements
------------
* Ruby 1.8.7+
* Ruby 1.9.3+
* JRuby 1.6.7+


Install
-------

    % gem install args_parser


Synopsis
--------

    % ruby samples/download_webpage.rb -url http://example.com -o out.html


parse ARGV
```ruby
require 'rubygems'
require 'args_parser'

parser = ArgsParser.parse ARGV do
  arg :url, 'URL', :alias => :u
  arg :output, 'output file', :alias => :o, :default => 'out.html'
  arg :verbose, 'verbose mode'
  arg :help, 'show help', :alias => :h

  filter :url do |v|
    v.to_s.strip
  end

  validate :url, "invalid URL" do |v|
    v =~ /^https?:\/\/.+$/
  end
end

if parser.has_option? :help or !parser.has_param?(:url, :output)
  STDERR.puts parser.help
  exit 1
end

require 'open-uri'
puts 'download..' if parser[:verbose]
open(parser[:output], 'w+') do |f|
  f.write open(parser[:url]).read
end
puts "saved! => #{parser[:output]}"
```

equal style

    % ruby samples/twitter_timeline.rb --user=shokai --fav --rt

parse equal style ARGV
```ruby
parser = ArgsParser.parse ARGV, :style => :equal do
```

see more samples https://github.com/shokai/args_parser/tree/master/samples


Test
----

    % gem install bundler
    % bundle install
    % rake test


Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request