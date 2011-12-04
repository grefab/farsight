module UrlFileHandler
  class Handler
    def url_to_path(url, prefix)
      # remove prefix
      path = url.sub(prefix, '')

      # remove trailing slash if present
      path = path.reverse.sub('/', '').reverse if path.end_with?('/')

      # decode, i.e. replace %20 by space and so on.
      path = URI.decode path

      path
    end

    def filter_base_names(filelist)
      filelist.map { |a| File.basename(a) }
    end

    def filer_filetypes(filelist)
      filelist.find_all { |f| File.extname(f) == '.mp4' }
    end

    def extract_directories_and_files(filelist)
      # find files and directories
      subdirectories = []
      files = []
      filelist.each do |f|
        subdirectories += [f] if File.directory?(f)
        files += [f] if File.file?(f)
      end

      # we are only interested in the base names
      subdirectories = filter_base_names subdirectories
      files = filter_base_names files

      # and only in mp4 files
      filtered_files = filer_filetypes files

      return subdirectories, filtered_files
    end

    def ensure_trailing_slash path
      path.end_with?('/') ? path : path + '/'
    end

    DEFINE_BASE_FS_PATH = '/Users/gregor/'

    def to_fs_path relativePath
      DEFINE_BASE_FS_PATH + relativePath
    end

    def find_files(relativePath)
      path = ensure_trailing_slash relativePath
      path = to_fs_path path

      all_files = Dir[path + '*']

      return all_files
    end

    def extract_fileinfo_from_path path
      all_files = find_files path
      subdirectories, files = extract_directories_and_files all_files
      basedir = ensure_trailing_slash path

      return basedir, subdirectories, files
    end
  end

  def self.extract_fileinfo_from_url(url, prefix)
    h = Handler.new
    h.extract_fileinfo_from_path(h.url_to_path(url, prefix))
  end

  def self.get_fs_path_from_url(url, prefix)
    h = Handler.new
    h.to_fs_path(h.url_to_path(url, prefix))
  end
end