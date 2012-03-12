#!/usr/bin/ruby
# coding:utf-8
require 'open-uri'

puts "down.stsl.rb"
if ARGV.size != 1
  puts "USE: down.stsl.rb <файл конфигурации>"
  exit
end

@list = File.open(ARGV[0]).readlines

@list.each do |uri|
  @uri = uri.strip!
  if @uri[0]=='#'
    puts "stsl: skipped comment #{@uri}"
    next
  end
  puts "stsl: download page #{@uri}"
  @page = URI.parse(@uri).read  
  raise "stsl: Image mask not found" if not m=/<a rel="lightbox".*href="(\/files\/.*)\/(.*?)-[0-9]{4}\.jpg"/.match(@page)
  Dir.mkdir(@path['main']) if ! File.exists?( (@path = {'main' => m[1].sub(/^\//, '').gsub(/\//, '_')})['main'] )
  Dir.mkdir(@path['jpeg']) if ! File.exists?( @path['jpeg'] = "#{@path['main']}/jpeg")
  @urlmask = "%s/%s" % [ m[1], @filemask = "%s-%%04d.jpg" % m[2]]
  raise "stsl: Page count not found" if not m=/size: ([0-9]{1,4}), \/\/carousel_itemList.length,/.match(@page)
  @pagecount = Integer(m[1].strip)
  puts "stsl: page count #{@pagecount}"

  @jpegs = []
  @pagecount.times { |i| @jpegs << "#{@path['jpeg']}/#{@filemask}" % [i+1] }

  @pagecount.times do |p|
    if ! File.exists?(@cache = "%s/#{@filemask}" % [@path['jpeg'], p+1])
      cmd="wget --directory-prefix=#{@path['jpeg']} http://www.stsl.ru/#{@urlmask}" % [p+1]
      puts "stsl: down page: %s" % [@cache]
      `#{cmd}`
    else
      puts "stsl: skipping file: #{@cache}"
    end
  end
end

