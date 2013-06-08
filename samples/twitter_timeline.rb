#!/usr/bin/env ruby
## equal style sample app
## % gem install twitter --version=3.7.0

$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
require 'rubygems'
require 'args_parser'
gem 'twitter', '< 4.0.0', '>= 3.7.0'
require 'twitter'

args = ArgsParser.parse ARGV, :style => :equal do
  arg :user, 'user', :alias => :u
  arg :favorite, 'show favorites', :alias => :fav
  arg :retweet, 'show retweets', :alias => :rt
  arg :help, 'show help', :alias => :h

  filter :user do |v|
    v.to_s.strip
  end

  validate :user, "invalid twitter screen_name" do |v|
    v =~ /^[a-zA-Z0-9_]+$/
  end
end

if args.has_option? :help or !args.has_param? :user
  STDERR.puts "Twitter Timeline\n=="
  STDERR.puts args.help
  STDERR.puts "e.g.  ruby #{$0} --user=ymrl"
  STDERR.puts "e.g.  ruby #{$0} --user=ymrl --fav"
  STDERR.puts "e.g.  ruby #{$0} --user=ymrl --fav --rt"
  exit 1
end

p args

Twitter::configure do
end

data = []
Twitter::user_timeline(args[:user]).each do |i|
  data.push(:id => i.id,
            :name => i.user.screen_name,
            :text => i.text,
            :date => i.created_at)
end

if args.has_option? :favorite
  Twitter::favorites(args[:user]).each do |i|
    data.push(:id => i.id,
              :name => i.user.screen_name,
              :text => i.text,
              :date => i.created_at)
  end
end

if args.has_option? :retweet
  Twitter::retweeted_by_user(args[:user]).each do |i|
    data.push(:id => i.id,
              :name => i.user.screen_name,
              :text => i.text,
              :date => i.created_at)
  end
end

data.uniq{|i|
  i[:id]
}.sort{|a,b|
  a[:date] <=> b[:date]
}.each{|i|
  puts "@#{i[:name]}\t#{i[:text]}"
}
