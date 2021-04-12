class UsersController < ApplicationController
  def index
    @genres = Genre.all.decorate
  end

  def top_commenters
    @top_commenters = User.joins(:user_comments).group(:user_id).order("count(user_comments.movie_id) DESC")
  end
end
