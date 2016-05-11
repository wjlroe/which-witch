#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require_relative '../lib/forensics_api'

if ARGV[0] && ARGV[0] != ''
  email = ARGV[0].strip
  api = ForensicsApi.new(email)
  puts api.search
  puts "Guessed the location of the kittens as: #{api.guess_coordinates}"
else
  puts 'Please provide an email address as the first argument'
end
