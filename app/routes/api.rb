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
      return ""
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
      return ""
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
      :status => game.players.find_all{|p| p.user_id == user.id}.first.status,
      :current_player => game.current_player_index,
      :players => game.players.collect{|p| {:id => p.user_id, :score => p.score}},
      :last_move_utc => game.moves.last.date
    }}.to_json
  end
  
  get "/api/user/friends" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    
    return user.friends.collect{|f| {:id => f.user_id, :status => f.status}}.to_json
  end
  
  get "/api/user/find/:id_or_email" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    found_user = User.get(params[:id_or_email])
    found_user = User.by_email(:key => params[:id_or_email].downcase).first if found_user.nil?
    halt 404 if found_user.nil?
    
    if !user.nil? && user.friends.any?{|f| f.user_id == found_user.id && f.status == 'active'}
      # These users are friends, reveal the entire profile
      return {
        :id => found_user.id,
        :email => found_user.email,
        :nickname => found_user.nickname,
        :avatar_url => found_user.avatar_url
      }.to_json
    else
      # These users aren't connected, only reveal public information
      return {
        :id => found_user.id,
        :nickname => found_user.nickname,
        :avatar_url => found_user.avatar_url
      }.to_json
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
  end
  
  get "/api/user/:id/acceptfriend" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_user = User.get(params[:id])
    halt 404 if found_user.nil?
    
    freq = user.friends.find_all{|f| f.user_id == found_user.id}.first
    if !freq.nil? && freq.status == "requested"
      freq.status = 'approved'
      found_user.friends.find_all{|f| f.user_id == user.id}.first.status = "active"
      user.save
      found_user.save
    end
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
    game.players << GamePlayer.new(:user_id => user.id, :status => "playing")
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
    
    greq = found_game.players.find_all{|p| p.user_id == user.id}.first
    halt 400, "Not invited to this game" if greq.nil?
    if greq.status == "invited"
      greq.status = 'playing'
      pending_players = found_game.players.find_all{|p| p.status == "invited"}.first
      if pending_players.nil?
        found_game.status = 'inprogress'
      end
      found_game.save
    end
  end
  
  get "/api/game/:id/reject" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_game = Game.get(params[:id])
    halt 404 if found_game.nil?
    
    greq = found_game.players.reject!{|p| p.user_id == user.id && p.status == "invited"}
    halt 400, "Not invited to this game" if greq.nil?
    found_game.save
    
    # TODO: What should we do if this rejection causes the player count to drop below 2?
    #       Should the game be deleted, marked as completed or perhaps a fourth status?
  end
  
  get "/api/game/:id/board" do
    
  end
  
  get "/api/game/:id/rack" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_game = Game.get(params[:id])
    halt 404 if found_game.nil?
    halt 400, "Game not in progress" if game.status != "inprogress"
    
    player = found_game.players.find_all{|p| p.user_id == user.id}.first
    return player.rack.collect{|tile| {
      :letter => tile.letter,
      :points => tile.points
    }}.to_json
  end
  
  get "/api/game/:id/history/:limit" do
    
  end
  
  post "/api/game/:id/play" do
    
  end
  
  post "/api/game/:id/swap" do
    
  end
  
  post "/api/game/:id/pass" do
    
  end
  
  post "/api/game/:id/resign" do
    
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
  end
end
