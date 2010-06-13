class Game < CouchRest::ExtendedDocument
  use_database WORDDITDB
  
  timestamps!
  
  property :current_player_index
  property :status # pending, inprogress, completed
  property :players, :cast_as => ['GamePlayer']
  property :tile_bag, :cast_as => ['GameTile']
  property :moves, :cast_as => ['GameMove']
  property :board, :cast_as => ['GameBoard']
  property :messages, :cast_as => ['GameMessage']
  
  view_by :user_id, {
    :map => "function(doc) {
      if (doc['couchrest-type'] == 'Game' && doc['players']) {
        doc['players'].forEach(function(player) {
          emit(player['user_id'], null);
        });
      }
    }"
  }
end

class GamePlayer < Hash
  include CouchRest::CastedModel
  
  property :user_id
  property :score
  property :status # invited, playing, declined
  property :rack, :cast_as => ['GameTile']
end

class GameTile < Hash
  include CouchRest::CastedModel
  
  property :letter
  property :points
end

class GameMove < Hash
  include CouchRest::CastedModel
  
  property :user_id
  property :date
  property :row
  property :column
  property :direction # right or down
  property :tiles, :cast_as => ['GameTile']
end

class GameBoard < Hash
  include CouchRest::CastedModel
  
  property :rows, :cast_as => ['GameBoardRow']
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

class GameMessage < Hash
  include CouchRest::CastedModel
  
  property :user_id
  property :date
  property :message
end

@entities << Game