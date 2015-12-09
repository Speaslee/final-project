require 'ruby-processing'
require 'ruby-processing/runner'
class Visualizer < Processing::App
  require 'fileutils'
  require 'httparty'
  require 'color_namer'
  require 'fog'
  require 'fog/aws'
  require 'aws-sdk'
  require 'dotenv'
  require 'httparty'
  #require './encoder_job.rb'
  Dotenv.load
  load_library "minim"
  import "ddf.minim"
  import "ddf.minim.analysis"

  def self.run!
    Visualizer.new :title =>"Visualizer"

  end

  def upload
    s3 = Aws::S3::Resource.new(
    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
    region:'us-east-1'
    )
    @obj = s3.bucket('pantonely').object("#{@name}_#{@assigned_color}.mp4")
    @obj.upload_file("./#{@name}_#{@assigned_color}.mp4",{content_type:"movie/.mp4",  acl: 'public-read'})
  end

  def update_movie
    HTTParty.patch "http://pantonely.herokuapp.com/songs/show",
      body: {
        song: {movie:  @obj.public_url,
          id: "#{@id}",
        tag_list: "#{@assigned_color}"}
      }.to_json
  end

  def setup
    smooth
    size(700,500)
    background 10
    @new_song = ENV["FILEPATH"]
    @name = File.basename(ENV["NAME"], ".*")
    @id = ENV["IDENT"]
    setup_sound
    @color = []
  end

  def draw
    update_sound
    animate_sound
    # draw_beat
    saveFrame("/Users/sophiapeaslee/Desktop/Programs/finalproject/frames/line-######.jpg")
    mov_make
  end

  def mov_make
    if @input.isPlaying == false
      color_assignment
      puts "at colors"
      #EncodeJob.perform_async("/Users/sophiapeaslee/Desktop/Programs/finalproject/frames/line-%06d.jpg -i #{@new_song}", "#{@name}_#{@assigned_color}.mp4", :mp4)
        system "ffmpeg -framerate 60 -i /Users/sophiapeaslee/Desktop/Programs/finalproject/frames/line-%06d.jpg -i #{@new_song} -c:v libx264 -r 60 -pix_fmt yuv420p #{@name}_#{@assigned_color}.mp4"
        puts "made movie"
        FileUtils.rm_r Dir.glob("/Users/sophiapeaslee/Desktop/Programs/finalproject/frames/*.jpg")
       puts "frames were deleted"
       upload
       puts "upload"
       update_movie
       puts "updated_movie"
       FileUtils.rm_r ("/Users/sophiapeaslee/Desktop/Programs/finalproject/#{@name}_#{@assigned_color}.mp4")
       puts "deleted movie"
      exit
    end
  end

  def setup_sound
    @minim = Minim.new(self)
    @input = @minim.load_file(@new_song)
    #@input = @minim.load_file("/Users/sophiapeaslee/Desktop/Programs/finalproject/songs/groove.mp3")
    #@name = File.basename("/Users/sophiapeaslee/Desktop/Programs/finalproject/songs/groove.mp3", ".*")
    @input.play

    @fft = FFT.new(@input.left.size, 44100)
    @beat = BeatDetect.new(@input.bufferSize, @input.sampleRate)
    @beat.setSensitivity(300)
    @kickSize = @snareSize = @hatSize = 16
    # bl = BeatListener.new @beat, @input
    @freqs = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000]

    @current_ffts = Array.new(@freqs.size, 0.001)
    @previous_ffts = Array.new(@freqs.size, 0.001)
    @max_ffts = Array.new(@freqs.size, 0.001)
    @scaled_ffts = Array.new(@freqs.size, 0.001)
    @fft_smoothing = 0.8
  end

  def update_sound
    @fft.forward(@input.left)
    @previous_ffts = @current_ffts
    @freqs.each_with_index do |freq, i|
      new_fft = @fft.get_freq(freq)
      @max_ffts[i] = new_fft if new_fft > @max_ffts[i]
      @current_ffts[i] = ((1 - @fft_smoothing) * new_fft) + (@fft_smoothing * @previous_ffts[i])
      @scaled_ffts[i] = (@current_ffts[i]/@max_ffts[i])
    end

    @beat.detect(@input.left)

  end

  def animate_sound
    @size = @scaled_ffts[1]*height
    @size *= 4 if @beat.is_onset
    @x1 = @scaled_ffts[0]*width + width/2
    @y1 = @scaled_ffts[1]*height + height/2
    @red1 = @scaled_ffts[2]*255
    @green1 = @scaled_ffts[3]*255
    @blue1 = @scaled_ffts[4]*255

    fill @red1, @green1, @blue1
    @color.push(ColorNamer.name_from_rgb(@red1.to_i, @green1.to_i, @blue1.to_i).last)

    stroke @red1+20, @green1+20, @blue1+20

    ellipse(@xl, @yl, @size, @size)
    @x2  = width/2 - @scaled_ffts[5]*width

    @y2  = height/2 - @scaled_ffts[6]*height

    @red2    = @scaled_ffts[7]*255
    @green2  = @scaled_ffts[8]*255

    @blue2   = @scaled_ffts[9]*255

    fill @red2, @green2, @blue2
    @color.push(ColorNamer.name_from_rgb(@red2.to_i, @green2.to_i, @blue2.to_i).last)

    stroke @red2+20, @green2+20, @blue2+20
    ellipse(@x2, @y2, @size, @size)

  end

  # def draw_beat
  #   @kickSize *= 80 if @beat.kick?
  #   @snareSize *= 80 if @beat.snare?
  #   @hatSize *= 80 if @beat.hat?
  #   @kickSize = constrain(@kickSize * 0.95, 16, 80)
  #   @snareSize = constrain(@snareSize * 0.95, 16, 80)
  #   @hatSize = constrain(@hatSize * 0.95, 16, 80)
  #
  #   strokeWeight(5)
  #   stroke 255
  #   line(100, 500, 100, height - @kickSize)
  #   stroke 120, 90, 90
  #   line(200, 500, 200, height - @snareSize)
  #   stroke 180,90, 90
  #   line(300, 500, 300, height - @hatSize)
  #   @kickSize2  *= 80 if @beat.kick?
  #
  #   @snareSize2  *= 80 if @beat.snare?
  #
  #   @hatSize2   *= 80 if @beat.snare?
  #   @kickSize2 = constrain(@kickSize * 0.95, 16, 80)
  #   @snareSize2 = constrain(@snareSize * 0.95, 16, 80)
  #   @hatSize2 = constrain(@hatSize * 0.95, 16, 80)
  #   strokeWeight(5)
  #   stroke 255
  #   line(100, 500, 100, height - @kickSize2)
  #   stroke 120, 90, 90
  #   line(200, 500, 200, height - @snareSize2)
  #   stroke 180,90, 90
  #   line(300, 500, 300, height - @hatSize2)
  # end

  def color_assignment
    @assigned_color = @color.group_by(&:to_s).values.max_by(&:size).first
    puts @assigned_color
  end
end

class BeatListener
    include Java.ddf.minim.AudioListener
    def initialize beat, source
      @source = source
      @source.addListener(self)
      @beat = beat
    end

    def samples samps, sampsR = nil

      @beat.detect(samps)
    end
end


Visualizer.run!
