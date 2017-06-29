#!/usr/bin/env ruby

times = Hash.new(0)
count = Hash.new(0)

REGEX = /\((\d+)\): JSC_EXEC_TIME: (\d+\.\d+)/
ARGV.each do |filename|
  f = File.open(filename)
  pid = File.basename(filename)
  while a = f.gets
    matches = a.match(REGEX)
    next unless matches
    time = matches[2].to_f
    times[pid] += time
    count[pid] += 1
  end
  f.close
end

times.each do |k,v|
  puts "#{k}=#{v/count[k]} avg from #{count[k]} runs"
end

unless count.values.empty?
  puts "overall=#{times.values.inject(:+)/count.values.inject(:+)} avg from #{count.values.inject(:+)} runs"
end
