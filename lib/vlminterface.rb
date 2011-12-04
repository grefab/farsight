require "net/telnet"
require "digest/sha1"

class VlmRemote
  def cmd(cmdString)
    puts ">>> " + cmdString
    answer = @vlm.cmd(cmdString)
    puts "<<< " + answer

    answer
  end

  def open
    @vlm = Net::Telnet::new("Host" => "192.168.178.29",
                                 "Port" => "4212",
                                 "Timeout" => 30,
                                 "Prompt" => /[$%#>] \z/n)
    # log in as usual
    cmd("admin")

    cmd("del all")
  end

  def close
    @vlm.close
  end

  def create_vod(source_url)
    # our stream is called as the sha1 of the source url.
    vod_name = Digest::SHA1.hexdigest(source_url)

    # if it exists, delete it.
    delete_vod vod_name

    # actually create
    cmd("new " + vod_name + " vod")
    cmd("setup " + vod_name + " input " + source_url)
#    cmd("setup " + vod_name + " output #transcode{vcodec=mp4v,acodec=mpga,vb=64,ab=64,deinterlace}")
    cmd("setup " + vod_name + " output ##transcode{vcodec=mp4v,acodec=mp4a}:standard{access=http,mux=mp4}")

    vod_name
  end

  def delete_vod(vod_name)
    cmd("del " + vod_name)
  end

  def enable_vod(vod_name)
    cmd("setup " + vod_name + " enabled")
  end

end

h = VlmRemote.new
h.open
#vod_name = h.create_vod("http://192.168.178.42:4567/dl/Desktop/video.mp4")
vod_name = h.create_vod("http://192.168.178.42:4567/dl/Desktop/audio.mp3")
h.enable_vod vod_name
puts "rtsp://192.168.178.29:5554/" + vod_name

gets

h.delete_vod vod_name
h.close