class GameBoard < Hash
  include CouchRest::CastedModel
  
  property :rows, :cast_as => ['GameBoardRow']

  def tile_at(row, column)
    return @rows[row][column]
  end
end

class GameBoardRow < Hash
  include CouchRest::CastedModel
  
  property :columns, :cast_as => ['GameBoardSquare']
end

class GameBoardSquare < Hash
  include CouchRest::CastedModel

  property :tile, :cast_as => 'GameTile'
  property :special
end
