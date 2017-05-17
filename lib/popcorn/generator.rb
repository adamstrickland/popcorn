require "mustache"

module Popcorn
  class Generator
    API_DIR = "apis".freeze

    attr_reader :destination, :apis

    def initialize(apis, dest)
      @apis = apis
      @destination = dest
    end

    def generate!(multi: true, swagger: false)
      _create_directories

      files = []

      files << _write_multi_files if multi

      files << _write_swagger_file if swagger || !multi

      files
    end

    def file_registers
      index_register.merge(api_registers)
    end

    def index_register
      {File.join(public_dir, "index.html") => index_file_content(template_context)}
    end

    def template_context
      {
        "apis" => _api_defs.map do |f, n, _|
          {
            "file" => f,
            "name" => n
          }
        end
      }
    end

    def api_registers
      Hash[*_api_defs.map do |f, _, c|
        [File.join(api_dir, f), c]
      end.flatten]
    end

    def paths
      [public_dir, api_dir]
    end

    def index_file_template_path
      File.expand_path(File.join(File.dirname(__FILE__), "templates", "index.html.tt"))
    end

    def index_file_template_content
      File.read(index_file_template_path)
    end

    def index_file_content(context = {})
      Mustache.render(index_file_template_content, context)
    end

    private

    def _api_defs
      apis.map do |a|
        [a.filename, a.title, a.content]
      end
    end

    def _create_directories
      paths.each do |p|
        FileUtils.mkdir_p(p)
        FileUtils.chmod_R("a=rwx", p)
      end
    end

    def _write_multi_files(registers = file_registers)
      registers.map do |path, content|
        _write_file(path, content)
      end
    end

    def _swagger_file_elements
      apis.map do |a|
        [a.title, a.paths, a.definitions]
      end
    end

    def _swagger_file_data
      _swagger_file_elements.reduce({"paths" => {}, "definitions" => {}}) do |mem, (_, p, d)|
        mem["paths"].merge!(p)
        mem["definitions"].merge!(d)
        mem
      end
    end

    def _swagger_file_titles
      _swagger_file_elements.map do |n, _, _|
        n
      end
    end

    def _swagger_file_info_block
      {
        "info" => {
          "name" => _swagger_file_titles.join(" ")
        }
      }
    end

    def _swagger_file_content
      _swagger_file_data.merge(_swagger_file_info_block)
    end

    def _write_swagger_file
      _write_file(File.join(public_dir, "swagger.json"), _swagger_file_content)
    end

    def _write_file(path, content)
      File.open(path, "w") do |io|
        io.write(content)
      end
      FileUtils.chmod("a-x", path)
      path
    end

    def destination_dir
      File.expand_path(destination)
    end

    def public_dir
      File.join(destination, ".")
    end

    def api_dir
      File.join(destination, API_DIR)
    end
  end
end
