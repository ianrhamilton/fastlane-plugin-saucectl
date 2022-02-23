require "open3"
require "json"

# utility class for helper functions
module FileUtils
  CLASS_NAME_REGEX = /(Spec|Specs|Test|Tests)/.freeze
  FILE_TYPE_REGEX = /(.swift|.kt|.java)/.freeze

  def read_file(name)
    raise "File not found: #{name}" unless File.exist?(name)

    File.read(name).split
  end

  def search_retrieve_test_classes(path)
    Find.find(path).select do |f|
      File.file?(f) if File.basename(f) =~ CLASS_NAME_REGEX
    end
  end

  def find(class_name, regex)
    syscall("find '#{class_name}' -type f -exec grep -h -C2 '#{regex}' {} +")
  end

  def syscall(*cmd)
    Open3.capture3(*cmd)
  end

  def system(*cmd)
    Open3.popen2e(*cmd) do |stdin, stdout_stderr, wait_thread|
      Thread.new do
        stdout_stderr.each { |out| UI.message(out) }
      end
      stdin.close
      wait_thread.value
    end
  end
end
