require 'sinatra'

set :bind, '0.0.0.0'
set :port, 3000
set :haml, :format => :html5
enable :sessions

get '/tk/:id' do
	@tracker = ViewTrack.find params[:id]
	if @tracker.nil?
		@tracker = ViewTrack.new(params[:id], request)
		@tracker.message = params[:message] if params[:message]
		@tracker.persist!
	end
	#set cookie if there isnt one
	#if test code exists disreguard push
	#send back 1x1 data in the form of "pixel.gif" from "http://upload.wikimedia.org/wikipedia/commons/5/52/Spacer.gif"
	@tracker.increase_count unless params[:test_key] == "livelongandprosper"
  haml :show
end

get '/redr/:id' do
	#log the activity
	#redirect to link specified within the path
end

class Event
	require 'redis'
	require 'json'

	attr_accessor :db, :found, :count

	def initialize
		connect_db
		@count = 0
	end

	def connect_db
		@db = Redis.new
	end

	def increase_count
		# SET individual tracking log for each event this way you have a view of what happens over time
		@db.incr "#{@id}-count"
	end

end
 
class ViewTrack < Event
	attr_accessor :id, :request, :ip, :cookies

	def initialize id, request=nil
		@id = id
		@found = false
		unless request.nil?
			@request = request
			@ip = request.ip
			@cookies = request.cookies
		end
		super()
	end

	def persist!

		#TODO : Move this to a more persistant DB
		@db.set "#{@id}-data", to_json
	end

	def to_json
		data = {
			ip: @ip,
			cookies: @cookies
		}
		data[:message] = @message unless @message.nil
		return data.to_json
	end

	def self.find id
		db = Redis.new
		request = db.get "#{id}-data"
		unless request.nil?
			request = JSON.parse(request)
			event = ViewTrack.new(id)
			event.ip = request["ip"]
			event.cookies = request["cookies"]
			event.count = db.get "#{id}-count"
			event.found = true
			return event
		end
		return nil
	end

end