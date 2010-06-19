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

    DOUBLE_LETTER = "2L"
    TRIPLE_LETTER = "3L"
    DOUBLE_WORD   = "2W"
    TRIPLE_WORD   = "3W"
    START         = "start"

    DEFAULT_BOARD_SPECIALS = [
      # 0             1               2               3               4             5               6               7               8               9               10            11              12              13              14
      [TRIPLE_WORD  , nil           , DOUBLE_LETTER , nil           , nil         , nil           , nil           , TRIPLE_WORD   , nil           , nil           , nil         , nil           , DOUBLE_LETTER , nil           , TRIPLE_WORD]  , 
      [nil          , DOUBLE_WORD   , nil           , nil           , nil         , TRIPLE_LETTER , nil           , nil           , nil           , TRIPLE_LETTER , nil         , nil           , nil           , DOUBLE_WORD   , nil]     , 
      [nil          , nil           , DOUBLE_WORD   , nil           , nil         , nil           , TRIPLE_LETTER , nil           , TRIPLE_LETTER , nil           , nil         , nil           , DOUBLE_WORD   , nil           , nil]     , 
      [DOUBLE_LETTER, nil           , nil           , DOUBLE_WORD   , nil         , nil           , nil           , DOUBLE_LETTER , nil           , nil           , nil         , DOUBLE_WORD   , nil           , nil           , DOUBLE_LETTER], 
      [nil          , nil           , nil           , nil           , DOUBLE_WORD , nil           , nil           , nil           , nil           , nil           , DOUBLE_WORD , nil           , nil           , nil           , nil]     ,                        
      [nil          , TRIPLE_LETTER , nil           , nil           , nil         , TRIPLE_LETTER , nil           , nil           , nil           , TRIPLE_LETTER , nil         , nil           , nil           , TRIPLE_LETTER , nil]     ,              
      [nil          , nil           , DOUBLE_LETTER, nil            , nil         , nil           , DOUBLE_LETTER , nil           , DOUBLE_LETTER , nil           , nil         , nil           , DOUBLE_LETTER , nil           , nil]     ,              
      [TRIPLE_WORD  , nil           , nil           , DOUBLE_LETTER , nil         , nil           , nil           , DOUBLE_WORD   , nil           , nil           , nil         , DOUBLE_LETTER , nil           , nil           , TRIPLE_WORD]  , 
      [nil          , nil           , DOUBLE_LETTER , nil           , nil         , nil           , DOUBLE_LETTER , nil           , DOUBLE_LETTER , nil           , nil         , nil           , DOUBLE_LETTER , nil           , nil]     , 
      [nil          , TRIPLE_LETTER , nil           , nil           , nil         , TRIPLE_LETTER , nil           , nil           , nil           , TRIPLE_LETTER , nil         , nil           , nil           , TRIPLE_LETTER , nil]     , 
      [nil          , nil           , nil           , nil           , DOUBLE_WORD , nil           , nil           , nil           , nil           , nil           , DOUBLE_WORD , nil           , nil           , nil           , nil]     , 
      [DOUBLE_LETTER, nil           , nil           , DOUBLE_WORD   , nil         , nil           , nil           , DOUBLE_LETTER , nil           , nil           , nil         , DOUBLE_WORD   , nil           , nil           , DOUBLE_LETTER], 
      [nil          , nil           , DOUBLE_WORD   , nil           , nil         , nil           , DOUBLE_LETTER , nil           , DOUBLE_LETTER , nil           , nil         , nil           , DOUBLE_WORD   , nil           , nil]     , 
      [nil          , DOUBLE_WORD   , nil           , nil           , nil         , TRIPLE_LETTER , nil           , nil           , nil           , TRIPLE_LETTER , nil         , nil           , nil           , DOUBLE_WORD   , nil]     , 
      [TRIPLE_WORD  , nil           , DOUBLE_LETTER , nil           , nil         , nil           , nil           , TRIPLE_WORD   , nil           , nil           , nil         , nil           , DOUBLE_LETTER , nil           , TRIPLE_WORD]
    ]                                                                           
    
    def create_game(custom_rules)
      game = Game.new
      
      game.status = "pending"
      game.tile_bag = []
      DEFAULT_TILES.each do |tile|
        tile[:frequency].times do
          game.tile_bag << GameTile.new(:letter => tile[:letter], :points => tile[:points])
        end
      end
      game.moves = []
      game.board = GameBoard.new(:rows => [])
      (1...15).each do |idx1|
        row = GameBoardRow.new(:columns => [])
        (1...15).each do |idx2|
          row.columns << GameBoardSquare.new(:special => DEFAULT_BOARD_SPECIALS[idx1][idx2])
        end
        game.board.rows << row
      end
      
      return game
    end
    
  end
end
