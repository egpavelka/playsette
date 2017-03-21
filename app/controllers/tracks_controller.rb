class TracksController < ApplicationController
  # before_action :logged_in_user, only: [:create, :destroy]

  def new
    @track = Track.new
    # @track.media = params[:kind].new
  end

  def create
    @track = current_user.tracks.build(track_params)
    # @track.build_media_source(media: @track.kind.constantize.new)
    # if @track.save
    #   # @track.media = params[:kind].safe_constantize.new
    #   flash[:success] = "Track posted successfully."
    #   redirect_to root_path
    # else
    #   flash[:danger] = "Submission had errors."
    #   render 'new'
    # end
  end

  def show
    @track = Track.find(params[:id]).media_source.media
  end

  def index
    @tracks = Track.paginate(page: params[:page])
  end

  def destroy
    track = Track.find(params[:id])
    track.destroy
    flash[:success] = "Track deleted."
    submitter = User.find(params[:user_id])
    redirect_to submitter_path
  end


  private

    def track_params
      params.require(:track).permit(:kind, :status, :title, :artist, :album, :year, media_source_attributes: media_params)
    end

    def media_params
      unless params[:id].nil?
        Track.find(params[:id]).kind.constantize.column_names
      end
    end

end
