class GameSessionsController < ApplicationController
  before_action :set_game_session, only: %i[ show destroy ]

  # GET /game_sessions or /game_sessions.json
  def index
    @game_sessions = current_user.game_sessions
  end

  # GET /game_sessions/1 or /game_sessions/1.json
  def show
  end

  # GET /game_sessions/new
  def new
    @game_session = GameSession.new
  end

  # POST /game_sessions or /game_sessions.json
  def create
    @game_session = GameSession.new
    @game_session.user = current_user
    @game_session.status = 'active'

    world_file = params.dig(:game_session, :world_file)
    
    # Parse uploaded world file and create World
    if world_file.present?
      begin
        world = create_world_from_file(params[:game_session][:world_file])
        @game_session.world = world
      rescue InvalidWorldFileError => e
        @game_session.errors.add(:world_file, e.message)
        return respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @game_session.errors, status: :unprocessable_entity }
        end
      end
    else
      @game_session.errors.add(:world_file, "must be uploaded")
      return respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game_session.errors, status: :unprocessable_entity }
      end
    end

    respond_to do |format|
      if @game_session.save
        format.html { redirect_to @game_session, notice: "Game session was successfully created." }
        format.json { render :show, status: :created, location: @game_session }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_sessions/1 or /game_sessions/1.json
  def destroy
    @game_session.destroy!

    respond_to do |format|
      format.html { redirect_to game_sessions_path, notice: "Game session was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_session
      @game_session = GameSession.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def game_session_params
      params.expect(game_session: [ :status ])
    end

    # Parse the uploaded file and create a World
    # Format:
    # Generation N:
    # rows cols
    # ........
    # ....*...
    # ...**...
    # ........
    def create_world_from_file(file)
      content = file.read
      lines = content.lines.map(&:chomp)
      
      raise InvalidWorldFileError, "File is empty or too short" if lines.length < 3
      
      generation_line = lines[0]
      generation_match = generation_line.match(/^Generation\s+(\d+):?$/i)
      raise InvalidWorldFileError, "Invalid format: first line must be 'Generation N:'" unless generation_match
      generation = generation_match[1].to_i
      
      dimensions = lines[1].split
      raise InvalidWorldFileError, "Invalid format: second line must be 'rows cols'" unless dimensions.length == 2
      
      rows = dimensions[0].to_i
      cols = dimensions[1].to_i
      raise InvalidWorldFileError, "Invalid dimensions: rows and cols must be positive" if rows <= 0 || cols <= 0
      
      raise InvalidWorldFileError, "Not enough lines for grid: expected #{rows} rows" if lines.length < rows + 2
      
      # Parse and validate the grid (. = dead/0, * = alive/1)
      matrix = []
      lines[2, rows].each_with_index do |line, index|
        # Validate line length
        raise InvalidWorldFileError, "Row #{index + 1} has invalid length: expected #{cols}, got #{line.length}" if line.length != cols
        
        # Validate characters
        raise InvalidWorldFileError, "Row #{index + 1} contains invalid characters (only '.' and '*' allowed)" unless line.match?(/^[.*]+$/)
        
        row = line.chars.map { |c| c == '*' ? 1 : 0 }
        matrix << row
      end
      
      # Create and return the World (save as binary with Marshal)
      World.create!(
        matrix: Marshal.dump(matrix),
        number_generation: generation
      )
    end
end

# Custom error class for invalid world files
class InvalidWorldFileError < StandardError; end
