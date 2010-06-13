require 'digest/sha1'

class User < CouchRest::ExtendedDocument
  use_database WORDDITDB
  
  timestamps!
  
  property :email
  property :nickname
  property :avatar_url
  property :password_hash
  property :auths, :cast_as => ['UserAuthentication']
  
  set_callback :save, :before, :fix_keys
  
  view_by :email
  view_by :nickname
  
  def fix_keys
    email = email.downcase
    nickname = nickname.downcase
  end
  
  def self.hash_password(password)
    Digest::SHA1.hexdigest('Ov4xEpLJcJ96MxTjX67u7CzDimZyucxWFzIPu1D1LDb1b' + password).to_s
  end

  def check_password(password)
    hash_password(password) == password_hash
  end
end

class UserAuthentication < Hash
  include CouchRest::CastedModel
  
  property :client_type
  property :device_id
  property :authentication_token
  property :expire_date
end

@entities << User