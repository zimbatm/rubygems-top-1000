#!/usr/bin/env ruby
#
#

require 'fileutils'
require 'set'
require 'pathname'

skip = Set.new
File.open('./skip.csv').each_line do |line|
  next if line.start_with? "#"
  pkg = line.chomp.sub(',', '-')
  skip.add pkg
end

File.open('./rubygems-1000.csv').each_line do |line|
  name, version = line.chomp.split(',')
  pkg = "#{name}-#{version}"
  nix_dir = Pathname.new("nix/#{pkg}")
  nix = nix_dir / "default.nix"

  puts "=" * 70
  puts "#{name} #{version}"
  puts

  if skip.include? pkg
    puts "Skipping"
    next
  end

  if (nix_dir / "result").exist?
    puts "All good"
    next
  end

  sha256 =
    `nix-prefetch-url http://rubygems.org/gems/#{pkg}.gem`.chomp

  nix_dir.mkpath

  nix.write(<<-NIX)
{ pkgs ? import <nixpkgs> {} }:

pkgs.buildRubyGem rec {
  ruby = pkgs.ruby_2_1;
  gemName = "#{name}";
  version = "#{version}";
  sha256 = "#{sha256}";
}
  NIX

  Dir.chdir(nix_dir) do
    unless system("nix-build") 
      exit 1
    end
  end
end
