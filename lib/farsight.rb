require 'rubygems'
require 'sinatra'
require 'haml'
require 'uuidtools'
require 'uri'

require 'urlfilehandler'

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


#
# ROUTES
#

# entry point
get '/' do
  redirect to('/browse/')
end

# browse files
get '/browse/*' do
  basedir, directories, files = UrlFileHandler.extract_fileinfo_from_url(request.path_info, '/browse')

  haml :index, :locals => {:basedir => basedir, :directories => directories, :files => files}
end

# watch files
get '/watch/*' do
  basedir, directories, files = UrlFileHandler.extract_fileinfo_from_url(request.path_info, '/watch')

  haml :watch, :locals => {:basedir => basedir, :directories => directories, :files => files}
end

get '/dl/*' do
  send_file(UrlFileHandler.get_fs_path_from_url(request.path_info, '/dl'))
end

# playground
get '/barney' do
  stream do |out|
    out << "It's gonna be legen -\n"
    sleep 0.5
    out << " (wait for it) \n"
    sleep 1
    out << "- dary!\n"
  end
end
