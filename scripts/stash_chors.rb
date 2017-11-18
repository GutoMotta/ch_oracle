require 'fileutils'

@directories_to_stash = %w(chords chromagrams experiments figs templates)

def already_stashed?
  @directories_to_stash.map { |dir| File.directory?("old_#{dir}") }.any?
end

def stash
  @directories_to_stash.each do |dir|
    if File.directory?(dir)
      puts "#{dir} => old_#{dir}"
      File.rename(dir, "old_#{dir}")
    end
  end
end

def existing_directories
  @directories_to_stash.select do |dir|
    File.directory?(dir) && File.directory?("old_#{dir}")
  end
end

def pop
  @directories_to_stash.each do |dir|
    if File.directory?("old_#{dir}")
      puts "old_#{dir} => #{dir}"
      FileUtils.remove_dir dir
      File.rename("old_#{dir}", dir)
    end
  end
end


case ARGV[0]
when nil
  if already_stashed?
    raise 'There are stashed directories that would be overwritten.'
  end

  stash
when 'pop'
  if existing_directories.any?
    puts "This is a destructive action and will delete these directories:\n\n"
    puts existing_directories.join(', ')
    puts "\nContinue? (anything other than 'y' will stop this script)"

    if STDIN.gets.strip != 'y'
      puts 'Operation cancelled.'
      exit
    end
  end
  puts
  pop
end
