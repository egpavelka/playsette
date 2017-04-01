class Video < ApplicationRecord
  has_one :media_source, as: :media
  has_one :track, through: :media_sources

  attr_accessor :media_source

  VALID_VIMEO_FORMAT = /^[https?:\/\/vimeo\.com\/]+([^#\&\?\/]*)/i
  # https://vimeo.com/209507887

  VALID_YOUTUBE_FORMAT = /\A.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/i
  # https://www.youtube.com/watch?v=8KkW8Ul7Q1I
  # https://youtu.be/8KkW8Ul7Q1I?t=1m
  # First match group will be 'watch?v=' or '&v='
  # Second match group will be video ID

  # validates :source_path, presence: true, format: VALID_YT_FORMAT

  def assign_api
    if VALID_YT_FORMAT.match?(source_path)
      api = 'youtube'
      video_id(source_path)
    # elsif VALID_VIMEO_FORMAT.math?(source_path)
    #   api = 'vimeo'
    #   ...extracted query params...
    else
      errors.add(:video, "Please provide a valid YouTube or Vimeo video link.")

  end


end

class YouTube < Video
  def video_id
    source_path.match.(VALID_YT_FORMAT).captures[1]
  end
end

class Vimeo < Video
end
