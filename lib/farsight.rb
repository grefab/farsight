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


def handle_path path
  path = URI.decode path 
  
  # begins with a slash, ends with a slash!
  basedir = path.end_with?('/') ? path : path + '/'
  all_files = Dir[basedir + '*']

  # find files and directories
  directories = []
  files = []
  all_files.each do |f|
    directories += [f] if File.directory?(f)
    files += [f] if File.file?(f)
  end

  # we are only interested in the base names
  directories = directories.map { |a| File.basename(a) }
  files = files.map { |a| File.basename(a) }

  # and only in mp4 files
  filtered_files = files.find_all { |f| File.extname(f) == '.mp4' }
  
  # return triple
  return basedir, directories, filtered_files
end

before do
  # we want our session prepared everytime
  ensure_login
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
  path = request.path_info.sub('/browse', '')
  basedir, directories, files = handle_path(path)
 
  haml :index, :locals => {:basedir => basedir, :directories => directories, :files => files}
end

# watch files
get '/watch/*' do
  path = request.path_info.sub('/watch', '')
  basedir, directories, files = handle_path(path)
 
  haml :watch, :locals => {:basedir => basedir, :directories => directories, :files => files}
end

get '/dl/*' do
  path = request.path_info.sub('/dl', '')
  path = path.reverse.sub('/', '').reverse if path.end_with?('/')
  path = URI.decode path 

  send_file(path)
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

