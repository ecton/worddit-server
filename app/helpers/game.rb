class Main
  helpers do
    DEFAULT_TILES = [
      {:letter => "A", :points => 1}
    ]
    DEFAULT_BOARD_SPECIALS = [
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    ]
    
    def create_game(custom_rules)
      game = Game.new
      
      game.status = "pending"
      game.tile_bag = DEFAULT_TILES.clone
      game.moves = []
      game.board = GameBoard.new(:rows => [])
      (1...15).each do |idx1|
        row = GameBoardRow.new(:columns => [])
        (1...15).each do |idx2|
          row.columns << GameBoardSquare.new(:special => GAME_BOARD_SPECIALS[idx1][idx2])
        end
        game.board.rows << row
      end
      
      return game
    end
    
    def is_valid_move(game, move)
      # game is a Game
      # move is a GameMove
      
    end
    
    def score_move(game, move)
      
    end
  end
end
