#! /usr/bin/env ruby

#
# This script generates GitHub Actions for the currently supported
# set of Snyk images. The Actions all have the same interface.
#

require "erb"
require 'fileutils'


@variants = [
  "DotNet",
  "Golang",
  "Gradle",
  "Maven",
  "Node",
  "PHP",
  "Python",
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
