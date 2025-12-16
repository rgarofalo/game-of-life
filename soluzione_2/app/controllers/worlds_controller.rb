class WorldsController < ApplicationController
  before_action :set_world, only: %i[ update ]
  before_action :set_game_session, only: %i[ update ]

  # PATCH/PUT /worlds/1
  # Only allows advancing to next generation
  def update
    next_gen_matrix = next_generation(@world.grid)
    
    if @world.grid == next_gen_matrix
      @game_session.status = 'completed'
      @game_session.save
    end

    @world.matrix = Marshal.dump(next_gen_matrix)
    @world.number_generation += 1

    respond_to do |format|
      if @world.save
        format.html { redirect_to @game_session, notice: "Advanced to generation #{@world.number_generation}.", status: :see_other }
        format.json { render json: @world, status: :ok }
      else
        format.html { redirect_to @game_session, alert: "Error advancing generation.", status: :see_other }
        format.json { render json: @world.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_world
      @world = World.find(params.expect(:id))
    end

    def set_game_session
      @game_session = @world.game_sessions.where(user: current_user).first
    end

    def next_generation(current_world)
      require 'matrix'
      current_world = Matrix[*current_world]
   
      next_generation_world = current_world.clone
    
      current_world.each_with_index do |valore, idx_r, idx_c|

          if idx_r -1 <0 
              r_i = idx_r
              n_r = 2
          elsif idx_r+1 > current_world.row_count
              r_i = idx_r -1
              n_r = 2
          else
              r_i = idx_r -1
              n_r = 3
          end

          if idx_c -1 <0 
              c_i = idx_c
              n_c = 2
          elsif idx_c+1 > current_world.column_count
              c_i = idx_c -1
              n_c = 2
          else
              c_i = idx_c -1
              n_c = 3
          end


          mat = current_world.minor(r_i, n_r, c_i, n_c )
          celle_vive = mat.sum - valore


          # puts " Celle Vive intorno a (#{idx_r},#{idx_c}): #{celle_vive}"

          if valore == 1 && (celle_vive <2 || celle_vive >3)
              next_generation_world[idx_r,idx_c] = 0
          elsif valore == 1 && (celle_vive == 2 || celle_vive ==3)
              next_generation_world[idx_r,idx_c] = 1
          elsif valore==0 && celle_vive == 3
              next_generation_world[idx_r, idx_c] = 1
          end
      end
      
      return next_generation_world.to_a
    end
end
