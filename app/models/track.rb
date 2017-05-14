class Track < ApplicationRecord
  require 'open-uri'
  # USER
  belongs_to :user
  # STATUS
  # validates :status, inclusion: { in: %w(new pending active flagged broken) }

  # SUBMISSION
  validates :kind, inclusion: { in: %w(Embedded Upload Video) }
  # validates :submission_source, presence: true

  # MEDIA
  has_many :media_sources
  has_many :uploads, through: :media_sources, source: :media, source_type: 'Upload'
  has_many :embeddeds, through: :media_sources, source: :media, source_type: 'Embedded'
  has_many :videos, through: :media_sources, source: :media, source_type: 'Video'

  # METADATA
  validates :title, presence: true
  validates :album, presence: true
  validates :artist, presence: true
  validates :year, length: { is: 4 }

  #ALBUM ART
  has_attached_file :album_art,
  styles: { medium: {geometry: '300x300>', convert_options: '-colorspace Gray'},
  large: {geometry: '800x800>', convert_options: '-colorspace Gray'} },
  url: "/assets/images/album_art/:id/:style/:basename.:extension",
  path: ":rails_root/public/assets/images/album_art/:id/:style/:basename.:extension",
  default_url: 'assets/album_arts/aa_test.jpg'

  validates_attachment_content_type :album_art, content_type: /\Aimage\/.*\z/

  #
  def art_from_url(url)
    self.album_art = URI.parse(url).open
  end

  # LIKES
  has_and_belongs_to_many :likes #, numericality: true
  # Display (on user profile, main index)
  default_scope -> { order(created_at: :desc) } # on user profile
  # (scope for ordering by likes) # on index - top

  def source_path_key
    self.media_sources[:source_path]
  end

  def source_path_key= value
    self.media_sources[:source_path] = value
  end

end
