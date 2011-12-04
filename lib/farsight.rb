require 'rubygems'
require 'sinatra'
require 'haml'
require 'uuidtools'
require 'uri'

# my own modules
require 'handledata'

set :server, :thin


# PRODUCTION! :)
#set :environment, :production

# we need sessions and work on every interface
enable :sessions
set :bind, '0.0.0.0'

#configure cookie
use Rack::Session::Cookie, :expire_after => 2592000

# this is locked
#use Rack::Auth::Basic do |username, password|
#  username == 'admin' && password == 'secret'
#end

def loggedin?
  not session[:userid].nil?
end

def login
  generated_uuid = UUIDTools::UUID.random_create
  session[:userid] = generated_uuid
  puts 'Got new uuid: ' + generated_uuid + ', session id is: ' + session[:userid]
end

def ensure_login
  if not loggedin? then
    login
  else
    puts "request from " + session[:userid]
  end
end

before do
  # we want our session prepared everytime
  ensure_login
end

def url_to_path(prefix)
  # remove prefix
  path = request.path_info.sub(prefix, '')

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

def to_fs_path relativePath
  '/Users/gregor/' + relativePath
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

def extract_fileinfo_from_url(prefix)
  extract_fileinfo_from_path(url_to_path(prefix))
end


#
# ROUTES
#

# entry point
get '/' do
  redirect to('/browse/')
end

# browse files
get '/browse/*' do
  basedir, directories, files = extract_fileinfo_from_url('/browse')

  haml :index, :locals => {:basedir => basedir, :directories => directories, :files => files}
end

# watch files
get '/watch/*' do
  basedir, directories, files = extract_fileinfo_from_url('/watch')

  haml :watch, :locals => {:basedir => basedir, :directories => directories, :files => files}
end

get '/dl/*' do
  send_file(to_fs_path(url_to_path('/dl')))
end

# playground
get '/streem' do
  stream do |out|
    out << "It's gonna be legen -\n"
    sleep 0.5
    out << " (wait for it) \n"
    sleep 1
    out << "- dary!\n"
  end
end

get '/xxx' do
  send_file('/Users/gregor/Desktop/video.avi')
end

