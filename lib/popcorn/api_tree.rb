require "popcorn/api_def"

module Popcorn
  class ApiTree
    attr_reader :apis

    def initialize(srcdir)
      @srcdir = srcdir
      @apidir = File.join(srcdir, "/apis")
      @apis = Dir[File.expand_path(File.join(@apidir, "**/*.yml"))].map do |definition|
        ApiDef.new(srcdir, definition)
      end
    end
  end
end
