# frozen_string_literal:true

module Hyrax::Migrator
  module ChecksumsProfiler
    INDENT = "  "
    DASH = "- "

    def print_checksums(content, export_path, short_pid)
      file = open_file(export_path, short_pid)
      file.puts "checksums:"
      file.print assemble_checksums(content)
      file.close
    end

    def assemble_checksums(content)
      str = "#{INDENT}MD5hex:\n"
      str += "#{INDENT}#{DASH}#{Digest::MD5.hexdigest content}\n"
      str
    end

    def open_file(export_path, short_pid)
      File.open(File.join(export_path, "#{short_pid}_checksums.yml"), 'w')
    end
  end
end
