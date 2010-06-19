require 'net/http'
namespace :api do
  desc "Create a new user"
  task :user_add, [:email_address, :password, :client_type, :device_id] do |task, args|
    res = Net::HTTP.post_form(URI.parse("http://localhost:4567/api/user/add"),
      {
        "email" => args.email_address,
        "password" => args.password,
        "client_type" => args.client_type,
        "device_id" => args.device_id
      }
    )
    case res
    when Net::HTTPSuccess
      jar = CGI::Cookie::parse(res['Set-Cookie'])
      puts jar['auth'].value
    else
      p res
    end
  end
end
