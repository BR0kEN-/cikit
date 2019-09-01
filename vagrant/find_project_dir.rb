def find_project_dir()
  root_finder = lambda do |path|
    return path if path.join("Vagrantfile").file?
    return nil if path.root? || !File.exist?(path)

    root_finder.call(path.parent)
  end

  root_finder.call(Pathname.pwd)
end
