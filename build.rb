#!/usr/bin/env ruby

# This script generates GitHub Actions for the currently supported
# set of Snyk images. The Actions all have the same interface.
require "erb"
require "fileutils"

class ActionGenerator
  VARIANTS = File.readlines('variants').map(&:strip).reject(&:empty?).freeze

  def initialize(current_git_version_tag)
    @templates_dir = "_templates"
    @current_git_version_tag = current_git_version_tag
  end

  def generate_all
    generate_base_readme
    generate_variant_actions
    generate_root_action
    generate_test_workflows
  end

  private

  def variant_deprecated?(variant)
    variant.include?("DEPRECATED")
  end

  def clean_variant_name(variant)
    variant.gsub(/\s*DEPRECATED\s*/, "").strip
  end

  def active_variants
    VARIANTS.reject { |v| variant_deprecated?(v) }
  end

  def deprecated_variants
    VARIANTS.select { |v| variant_deprecated?(v) }.map { |v| clean_variant_name(v) }
  end

  def generate_base_readme
    puts "Generating base README.md"
    render_template("BASE.md.erb", "README.md") do |erb|
      erb.instance_variable_set(:@variants, active_variants)
      erb.instance_variable_set(:@deprecated_variants, deprecated_variants)
      erb.instance_variable_set(:@current_git_version_tag, @current_git_version_tag)
    end
  end

  def generate_variant_actions
    VARIANTS.each do |variant|
      puts "Generating Action for #{variant}"
      generate_variant_action(variant)
    end
  end

  def generate_variant_action(variant)
    is_deprecated = variant_deprecated?(variant)
    clean_variant = clean_variant_name(variant)
    
    dirname = clean_variant.downcase
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

    name, ident = clean_variant.split("-", 2)

    %w[action.yml README.md].each do |filename|
      template_name = "#{filename}.erb"
      output_path = File.join(dirname, filename)

      render_template(template_name, output_path) do |erb|
        erb.instance_variable_set(:@variant, clean_variant)
        erb.instance_variable_set(:@name, name)
        erb.instance_variable_set(:@ident, ident)
        erb.instance_variable_set(:@is_deprecated, is_deprecated)
        erb.instance_variable_set(:@current_git_version_tag, @current_git_version_tag)
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
      erb.instance_variable_set(:@current_git_version_tag, @current_git_version_tag)
    end
  end

  def generate_test_workflows
    workflows_dir = ".github/workflows"
    FileUtils.mkdir_p(workflows_dir) unless File.directory?(workflows_dir)

    puts "Generating matrix test workflow for active (non-deprecated) actions"
    
    template_name = "test-generated-actions.yml.erb"
    output_path = File.join(workflows_dir, "test-generated-actions.yml")
    
    render_template(template_name, output_path) do |erb|
      erb.instance_variable_set(:@variants, active_variants)
      erb.instance_variable_set(:@current_git_version_tag, @current_git_version_tag)
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
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "Error: current_git_version_tag argument is required"
    puts "Usage: #{$PROGRAM_NAME} <current_git_version_tag>"
    puts "Example: #{$PROGRAM_NAME} v1"
    exit 1
  end
  
  current_git_version_tag = ARGV[0]
  ActionGenerator.new(current_git_version_tag).generate_all
end
