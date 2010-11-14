require 'digest/sha1'

class Inkan
  attr_accessor :credit, :comment, :comment_suffix
  
  def self.legitimate?(file)
    legit = false
    
    File.open(file) do |file|
      first_line = file.gets
      legit = !first_line[/\s#{sha(file.read)}\s*\n$/].nil?
    end
    
    legit
  end
  
  def self.seal(file)
    inkan = new(file)
    yield inkan
    inkan.seal
  end
  
  def self.sha(content)
    Digest::SHA1.hexdigest(content)
  end
  
  def initialize(file)
    @file = file
    
    # Set Defaults
    @credit         = 'Generated by Inkan'
    @comment        = '#'
    @comment_suffix = ''
  end
  
  def print(string)
    file_content << string
  end
  
  def puts(string)
    file_content << string << "\n"
  end
  
  def seal
    File.open(@file, 'w') do |f|
      f.puts "#{comment} #{credit}. #{sha} #{comment_suffix}"
      f.print file_content
    end
  end
  
  private
  
  def sha
    self.class.sha(file_content)
  end
  
  def file_content
    @file_content ||= ''
  end
end
