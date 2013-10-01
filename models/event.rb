class Event
	require 'redis'
	require 'json'
	require 'securerandom'

	attr_accessor :request_id, :db, :found, :count, :persistable_vars, :request, :id, :ip, :cookies, :session

	def initialize id=nil, request=nil, session=nil
		connect_db
		@id = id unless id.nil?
		@session = session unless session.nil?
		@found = false
		unless request.nil?
			@request = request
			@ip = request.ip
			@cookies = request.cookies
		end
		@count ||= 0
		@persistable_vars ||= []
		@request_id ||= SecureRandom.hex
		persist_var :ip
		persist_var :cookies
		persist_var :request
	end

	def connect_db
		@db ||= Redis.new
	end

	def increase_count
		@db.incr "count:#{@id}"
		#increase count for prid:id also to track the user's activity
	end

	def log_request
		persist!
		increase_count
		#find items based on the prid and count them under prid:(id):id:(id)
		@db.set "request:#{@request_id}", @id
	end

	def persist_var var_name
		@persistable_vars ||= []
		@persistable_vars << var_name
	end

	def persist!
		@db.set "data:#{@id}", to_json
		persistable_vars.each do |pvar|
			@db.set "obj:#{@id}", send(pvar)
		end
	end

	def to_json
		data = {
			ip: @ip,
			cookies: @cookies
		}
		data[:message] = @message unless @message.nil?
		return data.to_json
	end

	def self.find id
		db = Redis.new
		tracked_item = db.get "data:#{id}"
		unless tracked_item.nil?
			tracked_item = JSON.parse(tracked_item)
			event = View.new(id)
			event.count = db.get("count:#{id}")
			event.found = true
			return event
		end
		return nil
	end

end