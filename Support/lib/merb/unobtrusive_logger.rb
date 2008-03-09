# Based on Ruby on Rails bundle
require 'logger'

class UnobtrusiveLogger
  attr_accessor :filename, :logger
  def initialize(filename)
    @filename = filename
    @logger = nil
  end
  def method_missing(method, *args)
    @logger = Logger.new(@filename) unless @logger
    @logger.send(method, *args)
  end
end

$logger = UnobtrusiveLogger.new("/tmp/textmate_merb_bundle.log")
