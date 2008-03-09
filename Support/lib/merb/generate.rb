# Based on Ruby on Rails bundle
require 'merb/text_mate'
require 'merb/merb_path'
require 'merb/unobtrusive_logger'
require 'merb/inflector'   
class Generator
  @@list = []
  attr_accessor :name, :question, :default_answer

  def initialize(name, question, default_answer = "")
    @@list << self
    @name, @question, @default_answer = name, question, default_answer
  end

  def self.[](name, question, default_answer = "")
    g = new(name, question, default_answer)
  end

  def self.setup
    @@list = setup_generators
  end

  # Collect the names from each generator
  def self.names
    @@list.map { |g| g.name.capitalize }
  end

  def self.generators
    @@list
  end

  def self.setup_generators
    known_generator_names = known_generators.map { |gen| gen.name }
    new_generator_names = find_generator_names - known_generator_names
    known_generators + new_generator_names.map do |name|
      Generator[name, "Arguments for #{name} generator:", ""]
    end
  end

  # Runs the merb-gen command and extracts generator names from output
  def self.find_generator_names
    list = nil
    FileUtils.chdir(MerbPath.new.merb_root) do
      command = 'merb-gen | grep "^  [A-Z]" | sed -e "s/  //"'
      $logger.info "command: #{command}"
      output = `#{command}`
      $logger.info "merb-gen: #{output}"
      list = output.split(/[,\s]+/).reject {|f| f =~ /:/}
      $logger.info "generators: #{list.inspect}"
    end
    list
  end

  def self.known_generators
    [
      Generator["resource",   "Name of the resource:",          "post"],
      Generator["controller", "Name the new controller:",       "posts"],
      Generator["model",      "Name the new model:",            "Post"],
      Generator["resource_controller", "Name of resource controller:", "posts"],
      Generator["freezer",    "Name of help script:",           "frozen-merb"],
      Generator["migration",  "Name the new migration:",        "CreateUserTable"],
      Generator["part_controller", "Name of basic Merb Part controller:", "my_part_controller"],
    ]
  end
end
