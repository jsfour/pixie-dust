require 'sinatra'
require 'sinatra/cookies'

set :bind, '0.0.0.0'
set :port, 3000
set :haml, :format => :html5
enable :sessions

get '/view/:id' do
	#look for a cookie (user_id) and turn it into a user
	#if no cookie found create a user and set the cookie
	#if params[:test_key] == "livelongandprosper" log the below with a 5 min pop
	#log event against the user and id #event_id => view:#id:#user_id this counts that the view happened
	#increment the id counter "views:#id", this provides quick access to the views
	#push any data into a JSON under "data#event_id"
	#send back 1x1 data in the form of "pixel.gif" from "http://upload.wikimedia.org/wikipedia/commons/5/52/Spacer.gif"
  	haml :track_fired
end


get '/redirect/:id' do
	#look for a cookie (user_id) and turn it into a user
	#if params[:test_key] == "livelongandprosper" log the below with a 5 min pop
	#log the click event under "event_id" => click:#id:#user_id
	#log the click event under "clicks:#id" => #id:#user_id
	#push any data into a JSON under "data#event_id"
	#look up the click destination
	#redirect to the destination
	redirect url
end