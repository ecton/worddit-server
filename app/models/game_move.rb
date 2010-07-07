
class GameMove < Hash
  include CouchRest::CastedModel
  
  property :user_id
  property :date
  property :row
  property :column
  property :direction # right or down
  property :tiles, :cast_as => ['GameTile']

  def is_valid?(gameboard, ignore_dict=false)
    valid = true
    #valid = touching = false
    #current_row = self.row
    #current_col = self.column
    
    #touching = true unless gameboard.tile_at(current_row - 1, current_col).tile.nil? &&
    #                       gameboard.tile_at(current_row, current_col - 1).tile.nil?
    
    #self.tiles.each do |tile|
    #  if gameboard.tile_at(current_row, current_col).tile.nil?
    #    gameboard.rows[current_row][current_col].tile = tile
        
    #    if self.direction == "down"
    #      touching = true unless gameboard.tile_at(current_row, current_col - 1).tile.nil?
    #      current_row++
    #    else
    #      touching = true unless gameboard.tile_at(current_row - 1, current_col).tile.nil?
    #      current_col++
    #    end
    #  else
    #    touching = true
    #    current_row++ if direction == "down"
    #    current_col++ if direction == "right"
    #  end
    #end
    
    return valid
  end

  def score(gameboard)
    score = 1
    return score
  end
end
