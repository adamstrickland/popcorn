require "popcorn/api_tree"
require "popcorn/generator"

module Popcorn
  module Api
    def self.generate(src, dest, **options)
      Generator.new(apis(src), dest).tap do |g|
        g.generate!(options)
      end
    end

    def self.apis(src)
      ApiTree.new(src).apis
    end
  end
end
