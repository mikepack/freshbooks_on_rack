require 'rack'
require 'fb_on_rack'

use Rack::Auth::Basic, "FreshBooks on Rack" do |user, pass|
  user == 'me' and pass == 'secret'
end

run FBOnRack.new
