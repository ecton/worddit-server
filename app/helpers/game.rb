class Main
  helpers do
    DEFAULT_TILES = [
	  {:letter => "*", :frequency => 2, :points => 0},
	  {:letter => "A", :frequency => 9, :points => 1},
	  {:letter => "B", :frequency => 2, :points => 3},
	  {:letter => "C", :frequency => 2, :points => 3},
	  {:letter => "D", :frequency => 4, :points => 2},
	  {:letter => "E", :frequency => 12, :points => 1},
	  {:letter => "F", :frequency => 2, :points => 4},
	  {:letter => "G", :frequency => 3, :points => 2},
	  {:letter => "H", :frequency => 2, :points => 4},
	  {:letter => "I", :frequency => 9, :points => 1},
	  {:letter => "J", :frequency => 1, :points => 8},
	  {:letter => "K", :frequency => 1, :points => 5},
	  {:letter => "L", :frequency => 4, :points => 1},
	  {:letter => "M", :frequency => 2, :points => 3},
	  {:letter => "N", :frequency => 6, :points => 1},
	  {:letter => "O", :frequency => 8, :points => 1},
	  {:letter => "P", :frequency => 2, :points => 3},
	  {:letter => "Q", :frequency => 1, :points => 10},
	  {:letter => "R", :frequency => 6, :points => 1},
	  {:letter => "S", :frequency => 4, :points => 1},
	  {:letter => "T", :frequency => 6, :points => 1},
	  {:letter => "U", :frequency => 4, :points => 1},
	  {:letter => "V", :frequency => 2, :points => 4},
	  {:letter => "W", :frequency => 2, :points => 4},
	  {:letter => "X", :frequency => 1, :points => 8},
	  {:letter => "Y", :frequency => 2, :points => 4},
	  {:letter => "Z", :frequency => 1, :points => 10},
    ]

	# Probably not right, I know.
	2xLetter = Proc.new {|tile| tile[:points] * 2 }
	3xLetter = Proc.new {|tile| tile[:points] * 3 }
	2xWord = Proc.new {|gamemove| }
	3xWord = Proc.new {|gamemove| }

    DEFAULT_BOARD_SPECIALS = [
      [3xWord  , nil     , 2xLetter, nil     , nil   , nil     , nil     , 3xWord  , nil     , nil     , nil   , nil     , 2xLetter, nil     , 3xWord]  , 
      [nil     , 2xWord  , nil     , nil     , nil   , 3xLetter, nil     , nil     , nil     , 3xLetter, nil   , nil     , nil     , 2xWord  , nil]     , 
      [nil     , nil     , 2xWord  , nil     , nil   , nil     , 3xLetter, nil     , 3xLetter, nil     , nil   , nil     , 2xWord  , nil     , nil]     , 
      [2xLetter, nil     , nil     , 2xWord  , nil   , nil     , nil     , 2xLetter, nil     , nil     , nil   , 2xWord  , nil     , nil     , 2xLetter], 
      [nil     , nil     , nil     , nil     , 2xWord, nil     , nil     , nil     , nil     , nil     , 2xWord, nil     , nil     , nil     , nil]     , 
      [nil     , 3xLetter, nil     , nil     , nil   , 3xLetter, nil     , nil     , nil     , 3xLetter, nil   , nil     , nil     , 3xLetter, nil]     , 
      [nil     , nil     , 2xLetter, nil     , nil   , nil     , 2xLetter, nil     , 2xLetter, nil     , nil   , nil     , 2xLetter, nil     , nil]     , 
      [3xWord  , nil     , nil     , 2xLetter, nil   , nil     , nil     , 2xWord  , nil     , nil     , nil   , 2xLetter, nil     , nil     , 3xWord]  , 
      [nil     , nil     , 2xLetter, nil     , nil   , nil     , 2xLetter, nil     , 2xLetter, nil     , nil   , nil     , 2xLetter, nil     , nil]     , 
      [nil     , 3xLetter, nil     , nil     , nil   , 3xLetter, nil     , nil     , nil     , 3xLetter, nil   , nil     , nil     , 3xLetter, nil]     , 
      [nil     , nil     , nil     , nil     , 2xWord, nil     , nil     , nil     , nil     , nil     , 2xWord, nil     , nil     , nil     , nil]     , 
      [2xLetter, nil     , nil     , 2xWord  , nil   , nil     , nil     , 2xLetter, nil     , nil     , nil   , 2xWord  , nil     , nil     , 2xLetter], 
      [nil     , nil     , 2xWord  , nil     , nil   , nil     , 2xLetter, nil     , 2xLetter, nil     , nil   , nil     , 2xWord  , nil     , nil]     , 
      [nil     , 2xWord  , nil     , nil     , nil   , 3xLetter, nil     , nil     , nil     , 3xLetter, nil   , nil     , nil     , 2xWord  , nil]     , 
      [3xWord  , nil     , 2xLetter, nil     , nil   , nil     , nil     , 3xWord  , nil     , nil     , nil   , nil     , 2xLetter, nil     , 3xWord]
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
    
  end
end
