#!/usr/bin/env ruby

# Based on Ruby on Rails bundle
# Description:
#   Creates a partial from the selected text (asks for the partial name)
#   and replaces the text with a "partial [partial_name]" erb fragment.

require 'merb_bundle_tools'

current_file = MerbPath.new

# Make sure we're in a view file
unless current_file.file_type == :view
  TextMate.message("The 'create partial from selection' action works within view files only.")
  TextMate.exit_discard
end

# If text is selected, create a partial out of it
if TextMate.selected_text
  partial_name =
    TextMate.input(
      "Name of the new partial: (omit the _ and .html.erb)",
      "partial", :title => "Create a partial from the selected text")

  if partial_name
    path = current_file.dirname
    partial = File.join(path, "_#{partial_name}.html.erb")

    # Create the partial file
    if File.exist?(partial)
      unless TextMate.message_ok_cancel("The partial file already exists.", "Do you want to overwrite it?")
        TextMate.exit_discard
      end
    end

    file = File.open(partial, "w") { |f| f.write(TextMate.selected_text) }
    TextMate.refresh_project_drawer

    # Return the new render :partial line
    expr = "partial '#{partial_name}'"
    print ENV['MERB_TEMPLATE_START_RUBY_EXPR'] + expr + ENV['MERB_TEMPLATE_END_RUBY_EXPR'] + "\n"
  else
    TextMate.exit_discard
  end
else
  # Otherwise, toggle inline partials if they exist

  text = ""
  partial_block_re =
    /<!--\s*\[\[\s*Partial\s'(.+?)'\sBegin\s*\]\]\s*-->\n(.+)<!--\s*\[\[\s*Partial\s'\1'\sEnd\s*\]\]\s*-->\n/m

  # Inline partials exist?
  if current_file.buffer =~ partial_block_re
    text = current_file.buffer.text
    while text =~ partial_block_re
      partial_name, partial_text = $1, $2
      File.open(partial_name, "w") { |f| f.write $2 }
      text.sub! partial_block_re, ''
    end
  else
  # See if there are any render :partial statements to expand
    current_file.buffer.lines.each_with_index do |line, i|
      text << line
      if line =~ /partial[\s\(].*['"](.+?)['"]/
        partial_name = $1
        modules = current_file.modules + [current_file.controller_name]

        # Check for absolute path to partial file
        if partial_name.include?('/')
          pieces = partial_name.split('/')
          partial_name = pieces.pop
          modules = pieces
        end

        partial = File.join(current_file.merb_root, 'app', 'views', modules, "_#{partial_name}.html.erb")

        text << "<!-- [[ Partial '#{partial}' Begin ]] -->\n"
        text << IO.read(partial).gsub("\r\n", "\n")
        text << "<!-- [[ Partial '#{partial}' End ]] -->\n"
      end
    end
  end
  print text
  TextMate.exit_replace_document
end