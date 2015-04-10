module Qa::Authorities::LocalSubauthority

  # Path to sub-authority files is either the full path to a directory or
  # the path to a directory relative to the Rails application
  def subauthorities_path
    if AUTHORITIES_CONFIG[:local_path].starts_with?(File::Separator)
      AUTHORITIES_CONFIG[:local_path]
    else
      File.join(Rails.root, AUTHORITIES_CONFIG[:local_path])
    end
  end

  # Local sub-authorities are any YAML files in the subauthorities_path
  def names
    unless Dir.exists? subauthorities_path
      raise Qa::ConfigDirectoryNotFound, "There's no directory at #{subauthorities_path}. You must create it in order to use local authorities"
    end
    Dir.entries(subauthorities_path).map { |f| File.basename(f, ".yml") if f.match(/yml$/) }.compact
  end

end
