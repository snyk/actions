#!/usr/bin/env ruby

if ARGV.empty? || ARGV[0].nil? || ARGV[0].strip.empty?
  puts "Error: Missing required argument"
  puts "Usage: #{$0} <path-to-snyk-images-repository>"
  puts ""
  puts "Example: #{$0} ../snyk-images"
  exit 1
end

SNYK_IMAGES_PATH = ARGV[0]

# Read file line by line and track deprecated variants
def read_snyk_files
  content = ""
  deprecated_variants = []

  ['linux', 'alpine'].each do |file_name|
    file_path = File.join(SNYK_IMAGES_PATH, file_name)
    if File.exist?(file_path)
      lines_added = 0
      deprecated_count = 0

      File.readlines(file_path).each do |line|
        words = line.split
        # Check if DEPRECATED appears in the line (typically as 3rd word)
        if words.include?("DEPRECATED") && words.length >= 2
          deprecated_count += 1
          # The variant name is the SECOND word (the tag)
          variant_name = words[1].downcase if words[1]
          deprecated_variants << variant_name if variant_name
        end
        content += line
        lines_added += 1
      end

      puts "Read #{file_name} file: #{lines_added} lines added, #{deprecated_count} marked as DEPRECATED"
    else
      puts "Warning: #{file_path} not found"
    end
  end

  [content, deprecated_variants]
end

begin
  unless File.directory?(SNYK_IMAGES_PATH)
    puts "Error: The snyk-images repository was not found at: #{SNYK_IMAGES_PATH}"
    puts ""
    puts "Please ensure you have cloned the snyk-images repository before running this script."
    puts "You can clone it by running:"
    puts "  git clone https://github.com/snyk/snyk-images.git #{SNYK_IMAGES_PATH}"
    puts ""
    puts "Or if running from the workflow, the checkout step should handle this automatically."
    exit 1
  end

  missing_files = []
  ['linux', 'alpine'].each do |file_name|
    file_path = File.join(SNYK_IMAGES_PATH, file_name)
    missing_files << file_name unless File.exist?(file_path)
  end

  unless missing_files.empty?
    puts "Error: Required files not found in snyk-images repository:"
    missing_files.each { |f| puts "  - #{f}" }
    puts ""
    puts "Please ensure you have a valid snyk-images repository at: #{SNYK_IMAGES_PATH}"
    exit 1
  end

  puts "Reading snyk-images files from #{SNYK_IMAGES_PATH}..."
  snyk_content, deprecated_in_snyk = read_snyk_files
  
  # Debug: Show what deprecated variants were found
  if deprecated_in_snyk.any?
    puts "\nDeprecated variants found in snyk-images:"
    deprecated_in_snyk.sort.each { |v| puts "  - #{v}" }
  end

  puts "\nLoading variants..."
  unless File.exist?('variants')
    puts "Error: variants file not found in the current directory"
    puts "Please ensure you are running this script from the repository root."
    exit 1
  end

  current_variants = File.readlines('variants').map(&:strip).reject(&:empty?)
  puts "Current variants count: #{current_variants.size}"

  variants_to_keep = []
  variants_to_deprecate = []

  puts "Current variants: #{current_variants.join(', ')}"

  current_variants.each do |variant|
    # Clean variant name (remove existing DEPRECATED marker if present)
    clean_variant = variant.gsub(/\s*DEPRECATED\s*/, "").strip
    
    puts "Checking variant: #{clean_variant}"
    
    # Mark as deprecated if either:
    # 1. It's marked as DEPRECATED in snyk-images
    # 2. It's not found in snyk-images at all
    found_in_snyk = snyk_content.match?(/\b#{Regexp.escape(clean_variant)}\b/i)
    is_deprecated_in_snyk = deprecated_in_snyk.include?(clean_variant.downcase)
    
    if found_in_snyk
      puts "  → Found in snyk-images, deprecated: #{is_deprecated_in_snyk}"
      # Check if it's deprecated in snyk-images (case-insensitive)
      if is_deprecated_in_snyk
        # Mark as deprecated (unless already marked)
        if variant.include?("DEPRECATED")
          variants_to_keep << variant
        else
          variants_to_deprecate << clean_variant
          variants_to_keep << "#{clean_variant} DEPRECATED"
        end
      else
        # Keep as active variant
        variants_to_keep << clean_variant
      end
    else
      # Not found in snyk-images at all, mark as deprecated
      if variant.include?("DEPRECATED")
        variants_to_keep << variant
      else
        variants_to_deprecate << clean_variant
        variants_to_keep << "#{clean_variant} DEPRECATED"
      end
    end
  end

  if variants_to_deprecate.empty?
    puts "\nNo changes needed. All variants are up to date."
    exit 0
  end

  puts "\nVariants to mark as DEPRECATED:"
  variants_to_deprecate.each { |v| puts "  - #{v}" }

  puts "\nUpdated variants list:"
  variants_to_keep.each { |v| puts "  - #{v}" }

  puts "\nUpdating variants file..."
  File.write('variants', variants_to_keep.join("\n") + "\n")
  puts "Updated variants: #{variants_to_deprecate.size} marked as deprecated"

  puts "\nRunning build.rb to regenerate actions..."
  system("ruby build.rb")

  if $?.success?
    puts "Successfully regenerated actions"
  else
    puts "Error: Failed to run build.rb"
    exit 1
  end

rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
  exit 1
end
