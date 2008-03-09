# Based on Ruby on Rails bundle
# Description:
#   Makes an intelligent decision on which file to go to based on the current line or current context.

require 'merb_bundle_tools'  
require 'merb/command_go_to_file'

CommandGoToFile.alternate(ARGV)
