# Based on Ruby on Rails bundle

require 'merb_bundle_tools'
require 'fileutils'

require File.dirname(__FILE__) + "/../lib/merb/generate"

# Look for (created) files and return an array of them
def files_from_generator_output(output, type = 'create')
  output.to_a.map { |line| line.scan(/#{type}\s+([^\s]+)$/).flatten.first }.compact.select { |f| File.exist?(f) and !File.directory?(f) }
end

Generator.setup

if choice = TextMate.choose("Generate:", Generator.names.map { |name| Inflector.humanize name }, :title => "Rails Generator")
  arguments =
    TextMate.input(
      Generator.generators[choice].question,
      Generator.generators[choice].default_answer,
      :title => "#{Inflector.humanize Generator.generators[choice].name} Generator")
  if arguments
    options = ""

    case choice
    when 0
      options = TextMate.input("Name the new controller for the scaffold:", "", :title => "Scaffold Controller Name")
      options = "'#{options}'"
    when 1
      options = TextMate.input("List any actions you would like created for the controller:",
        "index new create edit update destroy", :title => "Controller Actions")
    end

    merb_root = MerbPath.new.merb_root
    # add the --svn option, if needed
    if merb_root and File.exist?(File.join(merb_root, ".svn"))
      options << " --svn"
    end

    FileUtils.cd merb_root
    command = "merb-gen #{Generator.generators[choice].name} #{arguments} #{options}"
    $logger.debug "Command: #{command}"

    output = exec command
    $logger.debug "Output: #{output}"
    TextMate.refresh_project_drawer
    files = files_from_generator_output(output)
    files.each { |f| TextMate.open(File.join(merb_root, f)) }
    TextMate.textbox("Done generating #{Generator.generators[choice].name}", output, :title => "Done")
  end
end
