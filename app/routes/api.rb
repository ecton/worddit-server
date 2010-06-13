class Main
  post "/api/user/login" do
    if params[:email] && params[:password] && params[:client_type] && params[:device_id]
      user = User.by_email(:key => params[:email].downcase).first
      halt 404, "User not found" if user.nil?
      halt 404, "User not found" unless user.check_password(params[:password])
      
      token = user.setup_auth_token(params[:client_type], params[:device_id])
      set_cookie('auth', {
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
    if params[:email] && params[:password] && params[:client_type] && params[:device_id]
      user = User.by_email(:key => params[:email].downcase).first
      halt 409, "Email already exists" unless user.nil?
      
      # Create the new account
      user = User.new()
      user.email = params[:email]
      user.password_hash = User.hash_password(params[:password])
      user.friends = []
      
      token = user.setup_auth_token(params[:client_type], params[:device_id])
      set_cookie('auth', {
        :httponly => true,
        :path => '/',
        :expires => Time.now + 30.days,
        :value => token
      })
      return ""
    else
      halt 400, "Required fields are missing"
    end
  end
  
  post "/user/setprofile" do
    # TODO
  end
  
  post "/user/setavatar" do
    # TODO
  end
  
  get "/user/games" do
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
  
  get "/user/friends" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    
    return user.friends.collect{|f| {:id => f.user_id, :status => f.status}}.to_json
  end
  
  get "/user/find/:id_or_email" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    found_user = User.get(params[:id_or_email])
    found_user = User.by_email(params[:id_or_email].downcase).first if found_user.nil?
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
  
  get "/user/:id/befriend" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_user = User.get(params[:id])
    halt 404 if found_user.nil?
    
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
  
  get "/user/:id/defriend" do
    user = User.by_auth_token(:key => request.cookies['auth']).first
    halt 403 if user.nil?
    found_user = User.get(params[:id])
    halt 404 if found_user.nil?
    
    user.friends.reject!{|f| f.user_id == found_user.id}
    found_user.friends.reject!{|f| f.user_id == user.id}
    user.save
    found_user.save
  end
  
  get "/user/:id/acceptfriend" do
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
  
  post "/game/new" do
    
  end
  
  get "/game/:id/accept" do
    
  end
  
  get "/game/:id/reject" do
    
  end
  
  get "/game/:id/board" do
    
  end
  
  get "/game/:id/rack" do
    
  end
  
  get "/game/:id/history/:limit" do
    
  end
  
  post "/game/:id/play" do
    
  end
  
  post "/game/:id/swap" do
    
  end
  
  post "/game/:id/pass" do
    
  end
  
  post "/game/:id/resign" do
    
  end
  
  get "/game/:id/chat/history/:limit" do
    
  end
  
  post "/game/:id/chat/send" do
    
  end
end