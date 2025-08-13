#!/usr/bin/env ruby

require 'set'

# Path to snyk-images repository passed as argument
SNYK_IMAGES_PATH = ARGV[0] || '../snyk-images'

# Extract image names from snyk-images alpine and linux files
def extract_snyk_images
  images = Set.new
  
  ['alpine', 'linux'].each do |file_type|
    file_path = File.join(SNYK_IMAGES_PATH, file_type)
    if File.exist?(file_path)
      File.readlines(file_path).each do |line|
        # Skip empty lines and comments
        next if line.strip.empty? || line.strip.start_with?('#')
        
        # The files might contain full image names like "snyk/snyk:golang"
        # or just tags like "golang", "python-3.11", etc.
        # Extract the tag part after the colon if present
        image_line = line.strip
        
        if image_line.include?(':')
          # Format: snyk/snyk:tag or similar
          image_name = image_line.split(':').last
        else
          # Just the tag name
          image_name = image_line
        end
        
        # Convert to the format used in VARIANTS (capitalize first letter)
        formatted_name = format_variant_name(image_name)
        images.add(formatted_name) if formatted_name
      end
    else
      puts "Warning: #{file_path} not found"
    end
  end
  
  images
end

# Convert snyk-images format to VARIANTS format
def format_variant_name(image_name)
  return nil if image_name.empty?
  
  # Handle special cases
  case image_name.downcase
  when 'cocoapods'
    'CocoaPods'
  when 'dotnet'
    'dotNET'
  when /^elixir-(.+)$/
    "elixir-#{$1}"
  when 'golang'
    'Golang'
  when /^gradle$/
    'Gradle'
  when /^gradle-(.+)$/
    "Gradle-#{$1}"
  when /^maven$/
    'Maven'
  when /^maven-(.+)$/
    "Maven-#{$1.gsub('-', '-')}"
  when 'node'
    'Node'
  when 'php'
    'PHP'
  when /^python$/
    'Python'
  when /^python-(.+)$/
    "Python-#{$1}"
  when 'ruby'
    'Ruby'
  when 'scala'
    'Scala'
  when /^sbt(.+)-scala(.+)$/i
    "SBT#{$1}-Scala#{$2}"
  else
    # Default: capitalize first letter
    image_name.split('-').map(&:capitalize).join('-')
  end
end

# Read current VARIANTS from build.rb
def read_current_variants
  build_rb_content = File.read('build.rb')
  
  # Extract VARIANTS array
  if build_rb_content =~ /VARIANTS\s*=\s*\[(.*?)\]\.freeze/m
    variants_string = $1
    # Extract each variant, handling multi-line array
    variants_string.scan(/"([^"]+)"/).flatten
  else
    raise "Could not find VARIANTS array in build.rb"
  end
end

# Update build.rb with new VARIANTS list
def update_build_rb(new_variants)
  build_rb_content = File.read('build.rb')
  
  # Format the new VARIANTS array
  formatted_variants = new_variants.map { |v| "    \"#{v}\"" }.join(",\n")
  new_variants_block = "VARIANTS = [\n#{formatted_variants},\n  ].freeze"
  
  # Replace the VARIANTS block
  updated_content = build_rb_content.gsub(
    /VARIANTS\s*=\s*\[.*?\]\.freeze/m,
    new_variants_block
  )
  
  File.write('build.rb', updated_content)
end

# Main execution
begin
  puts "Extracting images from snyk-images repository..."
  snyk_images = extract_snyk_images
  puts "Found #{snyk_images.size} images in snyk-images"
  
  puts "\nReading current VARIANTS from build.rb..."
  current_variants = read_current_variants
  puts "Current VARIANTS count: #{current_variants.size}"
  
  # Find variants to remove (those not in snyk_images)
  variants_to_remove = current_variants.reject do |variant|
    # Check if this variant exists in snyk_images
    # We need to be flexible with matching due to potential formatting differences
    snyk_images.any? { |img| img.downcase == variant.downcase }
  end
  
  if variants_to_remove.empty?
    puts "\nNo variants need to be removed. All current VARIANTS exist in snyk-images."
  else
    puts "\nVariants to remove:"
    variants_to_remove.each { |v| puts "  - #{v}" }
    
    # Create new variants list without the removed ones
    new_variants = current_variants - variants_to_remove
    
    puts "\nUpdating build.rb..."
    update_build_rb(new_variants)
    puts "Updated VARIANTS count: #{new_variants.size}"
  end
  
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
  exit 1
end
