require "popcorn/api_tree"
require "popcorn/generator"

module Popcorn
  module Api
    def self.generate(src, dest, **options)
      generator = Generator.new(apis(src), dest)
      (generator.generate!(options) || []).flatten
    end

    def self.apis(src)
      ApiTree.new(src).apis
    end
  end
end
