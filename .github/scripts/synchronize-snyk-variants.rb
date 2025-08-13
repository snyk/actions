#!/usr/bin/env ruby

if ARGV.empty? || ARGV[0].nil? || ARGV[0].strip.empty?
  puts "Error: Missing required argument"
  puts "Usage: #{$0} <path-to-snyk-images-repository>"
  puts ""
  puts "Example: #{$0} ../snyk-images"
  exit 1
end

SNYK_IMAGES_PATH = ARGV[0]

# Read file line by line and filter out lines with DEPRECATED as 3rd word
def read_snyk_files
  content = ""

  ['linux', 'alpine'].each do |file_name|
    file_path = File.join(SNYK_IMAGES_PATH, file_name)
    if File.exist?(file_path)
      lines_added = 0
      lines_skipped = 0

      File.readlines(file_path).each do |line|
        words = line.split
        # Skip lines where DEPRECATED is the 3rd word (index 2)
        if words.length >= 3 && words[2] == "DEPRECATED"
          lines_skipped += 1
        else
          content += line
          lines_added += 1
        end
      end

      puts "Read #{file_name} file: #{lines_added} lines added, #{lines_skipped} lines skipped (DEPRECATED)"
    else
      puts "Warning: #{file_path} not found"
    end
  end

  content
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
  snyk_content = read_snyk_files

  puts "\nLoading variants..."
  unless File.exist?('variants')
    puts "Error: variants file not found in the current directory"
    puts "Please ensure you are running this script from the repository root."
    exit 1
  end

  current_variants = File.readlines('variants').map(&:strip).reject(&:empty?)
  puts "Current variants count: #{current_variants.size}"

  variants_to_keep = []
  variants_to_remove = []

  puts "Current variants: #{current_variants.join(', ')}"

  current_variants.each do |variant|
    puts "Checking variant: #{variant}"
    if snyk_content.match?(/\b#{Regexp.escape(variant)}\b/i)
      variants_to_keep << variant
    else
      variants_to_remove << variant
    end
  end

  if variants_to_remove.empty?
    puts "\nNo variants need to be removed. All current variants exist in snyk-images."
    exit 0
  end

  puts "\nVariants to remove (not found or marked as DEPRECATED in snyk-images):"
  variants_to_remove.each { |v| puts "  - #{v}" }

  puts "\nVariants to keep (found in snyk-images):"
  variants_to_keep.each { |v| puts "  - #{v}" }

  puts "\nUpdating variants file..."
  File.write('variants', variants_to_keep.join("\n") + "\n")
  puts "Updated variants from #{current_variants.size} to #{variants_to_keep.size} entries"

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
