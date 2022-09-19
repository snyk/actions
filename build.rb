#! /usr/bin/env ruby

#
# This script generates GitHub Actions for the currently supported
# set of Snyk images. The Actions all have the same interface.
#

require "erb"
require 'fileutils'


@variants = [
  "CocoaPods",
  "dotNET",
  "Golang",
  "Gradle",
  "Gradle-jdk11",
  "Gradle-jdk12",
  "Gradle-jdk14",
  "Gradle-jdk16",
  "Gradle-jdk17",
  "Maven",
  "Maven-3-jdk-11",
  "Node",
  "PHP",
  "Python",
  "Python-3.6",
  "Python-3.7",
  "Python-3.8",
  "Ruby",
  "Scala",
]

templatename = File.join("_templates", "BASE.md.erb")
renderer = ERB.new(File.read(templatename))
File.open("README.md", "w") { |file| file.puts renderer.result() }

@variants.each do | variant |
  puts "Generating Action for #{variant}"

  dirname = variant.downcase
  unless File.directory?(dirname)
    FileUtils.mkdir_p(dirname)
  end
  @variant = variant
  @name, @ident = variant.split("-", 2)
  [
    "action.yml",
    "README.md",
  ].each do | name |
    templatename = File.join("_templates", "#{name}.erb")
    renderer = ERB.new(File.read(templatename))
    filename = File.join(dirname, name)
    File.open(filename, "w") { |file|
        file.puts renderer.result()
    }
  end
end

#
# Currently in order to submit Actions to the marketplace you need to have a file
# called action.yml in the root of your directory
#
#puts "Generating root Action"
#FileUtils.cp("node/action.yml", ".")
