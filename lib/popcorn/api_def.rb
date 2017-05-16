require "yaml"
require "active_support/core_ext/hash/except"

module Popcorn
  class ApiDef
    attr_reader :definition,
                :info,
                :paths,
                :definitions,
                :filename

    def initialize(srcroot, definition)
      @srcroot = srcroot
      @defloc = definition
      content = File.read(@defloc)
      @representation = YAML.load(content)
      @filename = File.basename(@defloc)
    end

    def content
      YAML.dump(definition)
    end

    def path_files
      _pathify("paths", @representation["paths"]["include"])
    end

    def definition_files
      _pathify("definitions", @representation["definitions"]["include"])
    end

    def info
      @representation["info"]
    end

    def title
      info["title"]
    end

    def paths
      @representation["paths"].except("include").merge(ApiDef.parse(path_files))
    end

    def definitions
      @representation["definitions"].except("include").merge(ApiDef.parse(definition_files))
    end

    def definition
      @representation.merge({"paths" => paths, "definitions" => definitions})
    end

    def files
      [@defloc, path_files, definition_files].flatten.compact
    end

    def to_s
      definition.to_s
    end

    def self.parse(files)
      return {} if files.nil?

      files.map do |f|
        content = File.read(f)
        YAML.load(content)
      end.inject(&:merge)
    end

    private

    def _pathify(context, files)
      return nil if files.nil?
      files.map do |file|
        File.join(@srcroot, context, file)
      end
    end
  end
end
