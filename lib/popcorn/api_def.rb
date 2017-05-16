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
      @representation = ApiDef.yamlize(@defloc)
      @filename = File.basename(@defloc)
    end

    def content
      YAML.dump(definition)
    end

    def path_files
      _pathify("paths", _paths["include"])
    end

    def definition_files
      _pathify("definitions", _definitions["include"])
    end

    def info
      @representation["info"]
    end

    def title
      info["title"]
    end

    def _paths
      @representation["paths"] || {}
    end

    def paths
      _paths.except("include").merge(ApiDef.parse(path_files))
    end

    def _definitions
      @representation["definitions"] || {}
    end

    def definitions
      _definitions.except("include").merge(ApiDef.parse(definition_files))
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

      yamlized_files = files.map do |f|
        yamlize(f)
      end

      raise "Invalid YAML file" unless yamlized_files.all?

      yamlized_files.inject(&:merge)
    end

    def self.yamlize(file)
      raise "Non-existent file at #{file}" unless File.exist?(file)
      YAML.load(File.read(file))
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
