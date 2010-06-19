require 'digest/sha1'

class User < CouchRest::ExtendedDocument
  use_database WORDDITDB
  
  timestamps!
  
  property :email
  property :email_verified
  property :nickname
  property :avatar_url
  property :password_hash
  property :auths, :cast_as => ['UserAuthentication']
  property :friends, :cast_as => ['UserFriend']
  
  set_callback :save, :before, :fix_keys
  
  view_by :email
  view_by :nickname
  
  view_by :auth_token, {
    :map => "function(doc) {
      if (doc['couchrest-type'] == 'User' && doc['auths']) {
        doc['auths'].forEach(function(auth){
          emit(auth['authentication_token'],null);
        });
      }
    }"
  }
  
  def fix_keys
    self.email = self.email.to_s.downcase
    self.nickname = self.nickname.to_s.downcase
  end
  
  def self.hash_password(password)
    Digest::SHA1.hexdigest('Ov4xEpLJcJ96MxTjX67u7CzDimZyucxWFzIPu1D1LDb1b' + password).to_s
  end

  def check_password(password)
    User.hash_password(password) == password_hash
  end
  
  def setup_auth_token(client_type, device_id)
    # lookup an existing auth or create a new one
    auths ||= []
    auth = auths.find_all{|a| a.client_type == client_type && a.device_id == device_id}.first
    if auth.nil?
      auth = UserAuthentication.new(:client_type => client_type, :device_id => device_id)
      auths << auth
    end
    
    auth.authentication_token = id + Digest::SHA1.hexdigest((0...8).map{65.+(rand(25)).chr}.join + client_type + device_id)
    auth.expire_date = Time.now + 30.days
    return auth.authentication_token
  end
end

class UserAuthentication < Hash
  include CouchRest::CastedModel
  
  property :client_type
  property :device_id
  property :authentication_token
  property :expire_date
end

class UserFriend < Hash
  include CouchRest::CastedModel
  
  property :user_id
  property :status # requested, pending, active
end

@entities << User
