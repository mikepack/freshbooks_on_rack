require 'rack/response'
require 'ruby-freshbooks'

class FBOnRack
  def call(env)
    c = FreshBooks::Client.new('mikepack1.freshbooks.com', '90dd2f27c0785b4022aa85e12defe9e6')
    clients = c.client.list

    res = Rack::Response.new
    res.write "<title>FreshBooks on Rack</title>"
    res.finish    
  end                 
end   