class HomeController < ApplicationController
  def index
    @game_sessions = current_user.game_sessions
  end
end
