
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
    # In order to be valid, it only needs to touch another piece on the board.
    # However, a player could try to bluff with a word, so the dict doesn't
    #     necessarily need to be checked.
    return valid
  end

  def score(gameboard)
    score = 1
    # use_dict is available because the player may be bluffing.  
    # If that's the case, the hand needs to be scored regardless of
    #     if the hand consists of real words.
    return score
  end
end
