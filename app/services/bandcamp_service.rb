class BandcampService
  include DataGrabUtil
  attr_accessor :url, :base_page, :player_url, :data
  # Acceptable URL example
  # https://grabbingclouds.bandcamp.com/track/brewer-street

  def initialize(params)
    @url = params[:url]
    @data = call
  end

  def call
    @base_page = DataGrabUtil.read_page(@url)
    @player_url = xpath_meta_property('og:video')
    data = scrape_player
    data.merge(
      hint: {
        title_hint: xpath_meta_property('og:title'),
        description_hint: xpath_meta_property('og:description')
      },
      kind: xpath_meta_property('og:type')
    )
  end

  def set_metadata
    Hash[
      hint: @data[:hint],
      metadata: {
        title: @data[:tracks][0][:title],
        artist: @data[:artist],
        album: @data[:album_title],
        media_path: @data[:tracks][0][:file].values.last
      },
      year_params: [@data[:publish_date], '%d %b %Y'],
      album_art_params: @data[:album_art_lg]
    ]
  end

  # Verify
  def is_track?
    xpath_meta_property('og:type') == 'song'
  end

  def is_preview?
    !@data[:exclusive_show_anywhere].nil?
  end

  private

  def xpath_meta_property(property)
    @base_page.at_xpath("//meta[@property='#{property}']").attributes['content'].value
  end

  def scrape_player
    var_pattern = /var\splayerdata\s=\s(.*)\;\s*var/i
    track = DataGrabUtil.read_page(@player_url)
    scripts = track.xpath('//head//script')
    content_script = scripts.last.children[0].content.strip
    player_data = content_script.match(var_pattern)[1]
    player_data.gsub!('null', 'nil')
    eval(player_data)
  end
end
