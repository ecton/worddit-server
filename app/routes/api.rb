class Main
  before do
    if request.content_type == 'text/javascript'
      obj = JSON.parse(request.body.read)
      obj.each_pair do |key, value|
        params[key.to_sym] = value
      end
    end
  end
    
  post "/api/user/login" do
    if params[:email] && params[:password] && params[:client_type] && params[:device_id]
      user = User.by_email(:key => params[:email].downcase).first
      halt 404, "User not found" if user.nil?
      halt 404, "User not found" unless user.check_password(params[:password])
      
      token = user.setup_auth_token(params[:client_type], params[:device_id])
      user.save
      response.set_cookie('auth', {
        :httponly => true,
        :path => '/',
        :expires => Time.now + 1.day,
        :value => token
      })
      return
    else
      halt 400, "Required fields are missing"
    end
  end
  
  post "/api/user/add" do
    unless params[:email].nil? || params[:password].nil? || params[:client_type].nil? || params[:device_id].nil?
      user = User.by_email(:key => params[:email].downcase).first
      halt 409, "Email already exists" unless user.nil?
      
      # Create the new account
      user = User.new()
      # From http://tfletcher.com/lib/rfc822.rb
      EmailAddress = begin
        qtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]'
        dtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]'
        atom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-' +
          '\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+'
        quoted_pair = '\\x5c[\\x00-\\x7f]'
        domain_literal = "\\x5b(?:#{dtext}|#{quoted_pair})*\\x5d"
        quoted_string = "\\x22(?:#{qtext}|#{quoted_pair})*\\x22"
        domain_ref = atom
        sub_domain = "(?:#{domain_ref}|#{domain_literal})"
        word = "(?:#{atom}|#{quoted_string})"
        domain = "#{sub_domain}(?:\\x2e#{sub_domain})*"
        local_part = "#{word}(?:\\x2e#{word})*"
        addr_spec = "#{local_part}\\x40#{domain}"
        pattern = Regexp.new("\\A#{addr_spec}\\z",nil,'n')
      end
      halt 400, "Email not valid" unless params[:email].downcase.match(EmailAddress)
      user.email = params[:email].downcase
      user.password_hash = User.hash_password(params[:password])
      user.friends = []
      user.save
      
      token = user.setup_auth_token(params[:client_type], params[:device_id])
      response.set_cookie('auth', {
        :httponly => true,
        :path => '/',
        :expires => Time.now + 30.days,
        :value => token
      })
      user.save
      status 201
      return
    else
      halt 400, "Required fields are missing"
    end
  end
  
  post "/api/user/setprofile" do
    # TODO
  end
  
  post "/api/user/setavatar" do
    # TODO
  end
  
  get "/api/user/games" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    
    games = Game.by_user_id(:key => user.id)
    return games.collect{|game| {
      :id => game.id,
      :game_status => game.status,
      :player_status => game.players.find_all{|p| p.user_id == user.id}.first.status,
      :current_player => game.current_player_index,
      :players => game.players.collect{|p| {:id => p.user_id, :score => p.score}},
      :last_move_utc => game.moves.last.nil? ? nil : game.moves.last.date
    }}.to_json
  end
  
  get "/api/user/friends" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    
    json = user.friends.sort.collect{|f| {:friend => f, :user => User.get(f.user_id)}}.collect{|f|
      # Todo: email shouldn't be handed out if the friendship isn't accepted
      {:id => f[:friend].user_id, :email => f[:user].email, :nickname => f[:user].nickname, :avatar => f[:user].avatar_url, :status => f[:friend].status}
    }.to_json
    puts json
    return json
  end
  
  get "/api/user/find/:id_or_email" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    found_user = User.get(params[:id_or_email])
    found_user = User.by_email(:key => params[:id_or_email].downcase).first if found_user.nil?
    halt 404 if found_user.nil?
    
    if !user.nil? && user.friends.any?{|f| f.user_id == found_user.id && f.status == 'active'}
      # These users are friends, reveal the entire profile
      result = {
        :id => found_user.id,
        :email => found_user.email,
        :nickname => found_user.nickname,
        :avatar_url => found_user.avatar_url,
        :status => 'active'
      }
      
      p result
      return result.to_json
    else
      # These users aren't connected, only reveal public information
      result = {
        :id => found_user.id,
        :email => found_user.email,
        :nickname => found_user.nickname,
        :avatar_url => found_user.avatar_url
      }
      
      status = user.friends.find_all{|f| f.user_id == found_user.id}.first
      result[:status] = status unless status.nil?
      p result
      return result.to_json
    end
  end
  
  get "/api/user/:id/befriend" do
    p request.cookies
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_user = User.get(params[:id])
    halt 404 if found_user.nil?
    halt 400 if found_user.id == user.id
    
    # Check for an existing friendship request
    freq = user.friends.find_all{|f| f.user_id == found_user.id}.first
    if freq.nil?
      # Create the pending link
      user.friends << UserFriend.new(:user_id => found_user.id, :status => "pending")
      found_user.friends << UserFriend.new(:user_id => user.id, :status => "requested")
      user.save
      found_user.save
    elsif freq.status == "requested"
      # If this is a pending relationship, we can approve it
      freq.status = "active"
      found_user.friends.find_all{|f| f.user_id == user.id}.first.status = "active"
      user.save
      found_user.save
    end # otherwise, the request was already made and is either approved, 
        # or needs to be approved by the other person
    
    return
  end
  
  get "/api/user/:id/defriend" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_user = User.get(params[:id])
    halt 404 if found_user.nil?
    
    user.friends.reject!{|f| f.user_id == found_user.id}
    found_user.friends.reject!{|f| f.user_id == user.id}
    user.save
    found_user.save
    
    return
  end
  
  get "/api/user/:id/acceptfriend" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_user = User.get(params[:id])
    halt 404 if found_user.nil?
    
    freq = user.friends.find_all{|f| f.user_id == found_user.id}.first
    if !freq.nil? && freq.status == "requested"
      freq.status = 'active'
      found_user.friends.find_all{|f| f.user_id == user.id}.first.status = "active"
      user.save
      found_user.save
    end
    
    return
  end
  
  post "/api/game/new" do
    p params
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    halt 400, "Invitations are required" if params[:invitations].nil?
    invitations = params[:invitations].split(",")
    halt 400, "Must have at least one invitation" if invitations.size == 0
    halt 400, "Only 4 people per game" if invitations.size > 3
    game = create_game(params[:rules].to_s.split(','))
    game.players = []
    game.players << GamePlayer.new(:user_id => user.id, :status => "playing", :score => 0)
    invitations.each do |user_id|
      game.players << GamePlayer.new(:user_id => user_id, :status => "invited")
    end
    game.save
    status 201
    return game.id
  end

  post "/api/game/request" do
    # TODO
  end
  
  get "/api/game/:id/accept" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_game = Game.get(params[:id])
    halt 404 if found_game.nil?
    
    preq = found_game.players.find_all{|p| p.user_id == user.id}.first
    halt 400, "Not invited to this game" if preq.nil?
    if preq.status == "invited"
      preq.status = 'playing'
      preq.score = 0
      found_game.start! unless found_game.players.any?{|p| p.status == "invited"}
      found_game.save
    end
    
    return
  end
  
  get "/api/game/:id/reject" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_game = Game.get(params[:id])
    halt 404 if found_game.nil?
    
    preq = found_game.players.reject!{|p| p.user_id == user.id && p.status == "invited"}
    halt 400, "Not invited to this game" if preq.nil?
    found_game.save
    
    return
    
    # TODO: What should we do if this rejection causes the player count to drop below 2?
    #       Should the game be deleted, marked as completed or perhaps a fourth status?
  end
  
  get "/api/game/:id/board" do
    # TODO
  end
  
  get "/api/game/:id/rack" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_game = Game.get(params[:id])
    halt 404 if found_game.nil?
    halt 400, "Game not in progress" if found_game.status != "inprogress"
    
    player = found_game.players.find_all{|p| p.user_id == user.id}.first
    halt 400, "Not playing in this game" if player.nil?
    
    return player.rack.to_json
  end
  
  get "/api/game/:id/history/:limit" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    
    game = Game.get(params[:id])
    halt 404 if game.nil?
    
    halt 403 unless game.players.any?{|p| p.user_id == user.id}
    
    date = Time.parse(params[:limit]) unless params[:limit] == 'all'
    moves = game.moves
    moves = moves.reject{|m| m.date < date} unless date.nil?
    return moves.to_json
  end
  
  post "/api/game/:id/play" do
    unless params[:row].nil? || params[:column].nil? || params[:direction].nil? || params[:tiles].nil?
      user = User.by_auth_token(:key => request.cookies['auth']).first
      halt 403 if user.nil?
      found_game = Game.get(params[:id])
      halt 404 if found_game.nil?
      halt 400, "Game not in progress" if found_game.status != "inprogress"
      
      player = found_game.players.find_all{|p| p.user_id == user.id}.first
      halt 400, "Not playing in this game" if player.nil?
      halt 400, "Invalid move: not your turn" if found_game.players[found_game.current_player_index].user_id != player.user_id
      
      move = GameMove.new()
      move.user_id = user.id
      move.date = Time.now
      move.row = params[:row]
      move.column = params[:column]
      move.direction = params[:direction]
      move.tiles ||= []
      passed_rack = JSON.parse(params[:tiles])
      passed_rack.each do |tile|
        halt 400, "Invalid move: not your tile" if player.rack.index(tile).nil?
        move.tiles << player.rack.delete_at(player.rack.index(tile))
      end
      
      unless move.is_valid?(found_game)
        move.tiles.each do |tile|
          player.rack << move.tiles.delete_at(move.tiles.index(tile))
        end
        halt 400, "Invalid move"
      end
      
      move.tiles.length.times do
        player.rack << found_game.tile_bag.delete_at(rand(found_game.tile_bag.length)) unless found_game.tile_bag.empty?
      end # Consider moving found_game.tile_bag.empty? check outside of loop to short-circuit the loop.
      
      player.score += move.score(found_game)
      found_game.moves ||= []
      found_game.moves << move
      # Need some sort of delay/hook/interrupt/whatever to allow for challenges before player is advanced.
      found_game.current_player_index = (found_game.current_player_index + 1) % found_game.players.length
      found_game.save
      
      return {
        :points => player.score,
        :primary_word => "YAHTZEE", # TODO: Replace with actual primary word.
        :tiles => player.rack
      }.to_json
    else
      halt 400, "Required fields are missing"
    end
  end
  
  post "/api/game/:id/swap" do
    unless params[:tiles].nil?
      user = User.by_auth_token(:key => request.cookies['auth']).first
      halt 403 if user.nil?
      found_game = Game.get(params[:id])
      halt 404 if found_game.nil?
      halt 400, "Game not in progress" if found_game.status != "inprogress"
    
      player = found_game.players.find_all{|p| p.user_id == user.id}.first
      halt 400, "Not playing in this game" if player.nil?
      halt 400, "Invalid move: not your turn" if found_game.players[found_game.current_player_index].user_id != player.user_id
      passed_rack = JSON.parse(params[:tiles])
      passed_rack.each do |tile|
        halt 400, "Invalid move: not your tile" if player.rack.index(tile).nil?
        found_game.tile_bag << player.rack.delete_at(player.rack.index(tile))
        player.rack << found_game.tile_bag.delete_at(rand(found_game.tile_bag.length)) unless found_game.tile_bag.empty?
      end
      
      found_game.current_player_index = (found_game.current_player_index + 1) % found_game.players.length
      found_game.save
      
      return player.rack.to_json
    else
      halt 400, "Required fields are missing"
    end
  end
  
  post "/api/game/:id/pass" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_game = Game.get(params[:id])
    halt 404 if found_game.nil?
    halt 400, "Game not in progress" if found_game.status != "inprogress"
  
    player = found_game.players.find_all{|p| p.user_id == user.id}.first
    halt 400, "Not playing in this game" if player.nil?
    halt 400, "Invalid move: not your turn" if found_game.players[found_game.current_player_index].user_id != player.user_id
    
    found_game.current_player_index = (found_game.current_player_index + 1) % found_game.players.length
    found_game.save
    
    return
  end
  
  post "/api/game/:id/resign" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_game = Game.get(params[:id])
    halt 404 if found_game.nil?
    halt 400, "Game not in progress" if found_game.status != "inprogress"
  
    player = found_game.players.find_all{|p| p.user_id == user.id}.first
    halt 400, "Not playing in this game" if player.nil?
    found_game.tile_bag += player.rack
    if found_game.players[found_game.current_player_index].user_id == player.user_id
      found_game.current_player_index = (found_game.current_player_index + 1) % found_game.players.length
    end
    found_game.players.delete_at(found_game.players.index(player))
    found_game.save
    
    return
    
    # TODO: What should we do if this player resigning brings the count below 2?
  end
  
  get "/api/game/:id/chat/history/:limit" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    
    game = Game.get(params[:id])
    halt 404 if game.nil?
    
    halt 403 unless game.players.any?{|p| p.user_id == user.id}
    
    date = Time.parse(params[:limit]) unless params[:limit] == 'all'
    messages = game.messages
    messages = messages.reject{|m| m.date < date} unless date.nil?
    return messages.to_json
  end
  
  post "/api/game/:id/chat/send" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    game = Game.get(params[:id])
    halt 404 if game.nil?
    
    halt 403 unless game.players.any?{|p| p.user_id == user.id}
    
    message = GameMessage.new()
    message.user_id = user.id
    message.date = Time.now
    message.message = params[:message]
    game.messages ||= []
    game.messages << message
    game.save
    
    return
  end
end
