# Based on Ruby on Rails bundle
bundle_lib = ENV['TM_BUNDLE_SUPPORT'] + '/lib'
$LOAD_PATH.unshift(bundle_lib) if ENV['TM_BUNDLE_SUPPORT'] and !$LOAD_PATH.include?(bundle_lib)

require 'merb/text_mate'
require 'merb/merb_path'
require 'merb/unobtrusive_logger'
require 'merb/inflector'   

def ruby(command)
  `/usr/bin/env ruby #{command}`
end

def exec(command)
  require 'open3' unless Object.const_defined?("Open3")
  stdin, stdout, stderr = Open3.popen3(command)
  stdout.read
end