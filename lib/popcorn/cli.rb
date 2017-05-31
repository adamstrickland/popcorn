require "thor"
require "popcorn/api"
require "colorize"
require "active_support/core_ext/hash/keys"

module Popcorn
  class Cli < Thor
    desc "generate SRC [DEST]", <<-EOT
    Generates an Open-API specification in DEST based on the files in SRC.

    Expects the following directory structure:

    ./
      apis/        # Defines sub-APIs
      definitions/ # Defines model definitions, referenced within the API
      paths/       # Defines the paths for the APIs
    EOT
    option :swagger, type: :boolean, aliases: [:s], default: false, desc: "Also generate a swagger.json"
    option :multi, type: :boolean, aliases: [:m, :multifile], default: true, desc: "Generate multi files; false implies only generate swagger.json"
    def generate(src, dest = ".")
      say "Popcorn is doin' some generatin'!"

      srcdir = File.expand_path(src)
      destdir = File.expand_path(dest)

      params = options.symbolize_keys
      params[:swagger] = true unless options[:multi]

      files = Popcorn::Api.generate(src, dest, **params)

      say "reading from #{srcdir.colorize(:cyan)} and generating into #{destdir.colorize(:yellow)}"
      say "generated #{files.count} files:"
      files.sort.each{ |a| say "  - #{a.to_s.colorize(:green)}" }
    end
  end
end
