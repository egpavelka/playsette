class Track < ApplicationRecord
  include JsonUtil

### DISPLAY SCOPES
  default_scope -> { order(created_at: :desc) } # on user profile
  # (scope for ordering by likes) # on index - top
  scope :popularity, -> { order(likes: :desc) }
  # scope :audio, posted.where(playback: 'audio')
  # scope :video, posted.where(playback: 'video')

####################
# SETUP: PROPERTIES,
# RELATIONSHIPS
####################
  # Tracks belong to a user and will be deleted if the account is deactivated.
  belongs_to :user
  # Set up
  belongs_to :media, polymorphic: true, dependent: :destroy

####################
# INITIALIZE TRACK:
# USER, SOURCE, MEDIA
####################
  validates :user_id, presence: true
  validates :playback, inclusion: { in: %w(audio video) }
  validates :media_path, presence: true

####################
# AFTER MEDIA SOURCE:
# METADATA AND ARTWORK
####################

  # Metadata
  validates :title, length: { maximum: 255 }, presence: true, on: :update
  validates :album, length: { maximum: 255 }, allow_blank: true, on: :update
  validates :artist, length: { maximum: 255 }, presence: true, on: :update
  validates :year, length: { is: 4 }, allow_blank: true, on: :update

  # Album art managed by Paperclip; URL fetching with open-uri
  # has_attached_file :album_art,
  # styles: { medium: {geometry: '400x400>', convert_options: '-colorspace Gray'},
  # large: {geometry: '800x800>', convert_options: '-colorspace Gray'} },
  # url: '/public/assets/images/album_art/:id/:style/:basename.:extension',
  # path: ':rails_root/public/assets/images/album_art/:id/:style/:basename.:extension',
  # default_url: 'assets/album_art/aa_test.jpg',
  # content_type: { content_type: /\Aimage\/.*\z/ },
  # size: { in: 0..100.kilobytes }

  # Fetch from API response or URL input
  def art_from_url(url)
    self.album_art = URI.parse(url)
  end

####################
# FINALIZE SUBMISSION
# AND CLEANUP
####################
  def destroy_if_left_unpublished
    TracksCleanupJob.set(wait: 1.hour).perform_later(self)
  end

  def player_build_error
  end

  def missing_metadata_error
  end
####################
# SOCIAL ATTRIBUTES:
# LIKES AND COMMENTS
####################
  # has_and_belongs_to_many :likes, numericality: true
  # Display (on user profile, main index)

end
