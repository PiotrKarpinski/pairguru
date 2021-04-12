class MoviesController < ApplicationController
  before_action :authenticate_user!, only: [:send_info, :add_comment]

  def index
    @movies = Movie.all.decorate
  end

  def show
    @movie = Movie.find(params[:id])

  end

  def add_comment
    @user_comment = UserComment.new(content: params[:user_comment][:content], movie_id: params[:id], user_id: current_user.id)
    if @user_comment.save
    redirect_back(fallback_location: root_path, notice: "User comment created")
    else
      flash[:danger] = "Could not post comment: #{@user_comment.errors.full_messages}"
      redirect_back(fallback_location: root_path)

    end
    end

  def delete_comment
    @user_comment = UserComment.find_by(id: params[:id])
    if @user_comment.destroy
      redirect_back(fallback_location: root_path, notice: "User comment deleted")
    end
  end

  def send_info
    @movie = Movie.find(params[:id])
    MovieInfoMailer.send_info(current_user, @movie).deliver_now
    redirect_back(fallback_location: root_path, notice: "Email sent with movie info")
  end

  def export
    file_path = "tmp/movies.csv"
    MovieExporter.new.call(current_user, file_path)
    redirect_to root_path, notice: "Movies exported"
  end
end
