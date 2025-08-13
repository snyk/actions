#!/usr/bin/env ruby

# This script generates GitHub Actions for the currently supported
# set of Snyk images. The Actions all have the same interface.
require "erb"
require "fileutils"

class ActionGenerator
  VARIANTS = [
    "Golang",
    "Gradle",
    "Maven",
    "Node",
    "Python",
    "Ruby",
  ].freeze

  def initialize
    @templates_dir = "_templates"
  end

  def generate_all
    generate_base_readme
    generate_variant_actions
    generate_root_action
  end

  private

  def generate_base_readme
    puts "Generating base README.md"
    render_template("BASE.md.erb", "README.md") do |erb|
      erb.instance_variable_set(:@variants, VARIANTS)
    end
  end

  def generate_variant_actions
    VARIANTS.each do |variant|
      puts "Generating Action for #{variant}"
      generate_variant_action(variant)
    end
  end

  def generate_variant_action(variant)
    dirname = variant.downcase
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

    name, ident = variant.split("-", 2)

    %w[action.yml README.md].each do |filename|
      template_name = "#{filename}.erb"
      output_path = File.join(dirname, filename)

      render_template(template_name, output_path) do |erb|
        erb.instance_variable_set(:@variant, variant)
        erb.instance_variable_set(:@name, name)
        erb.instance_variable_set(:@ident, ident)
      end
    end
  end

  def generate_root_action
    puts "Generating root Action"
    # Generate root action.yml using the Node variant but marked as root
    render_template("action.yml.erb", "action.yml") do |erb|
      erb.instance_variable_set(:@variant, "Node")
      erb.instance_variable_set(:@name, "Node")
      erb.instance_variable_set(:@ident, nil)
      erb.instance_variable_set(:@is_root, true)
    end
  end

  def render_template(template_name, output_path)
    template_path = File.join(@templates_dir, template_name)
    template_content = File.read(template_path)

    erb = ERB.new(template_content)
    yield(erb) if block_given?

    result = erb.result(erb.instance_eval { binding })
    File.write(output_path, result)
  end
end

# Run the generator if this file is executed directly
ActionGenerator.new.generate_all if __FILE__ == $PROGRAM_NAME
