require 'yaml'

class RailsCompliantYMLGenerator
  attr_accessor :h, :yaml_result, :cat_file

  def self.generate_result_file target_filename: 'en.yml', yml_contents:
    File.write(target_filename, yml_contents)
  end

  def initialize filename
    @cat_file = File.readlines(filename)
    @h = {}
    @pattern = /([^:\.' ][\<\/a-zA-Z0-9 \_\-\>]+)(?:|)/
  end

  def yaml_result
    @yaml_result ||= h.to_yaml
  end

  def perform!
    cat_file.each do |line|
      line = line.scan(pattern).flatten!
      line.each_with_index do |item, i|

        if i.zero?
          h[item] = Hash.new unless h.has_key?(item)
          next
        end

        parent = get_parent_accessed(i, line)

        parent[item] = line.last if i.eql?(line.length-2)
        parent[item] = Hash.new if !parent.nil? && parent[item].nil?
      end
    end

    self
  end

  private

  attr_reader :pattern

  def get_parent_accessed i, line
    string = i.downto(1).each_with_object([]) { |n, obj| obj << line[i-n] }

    h.dig *string
  end
end
