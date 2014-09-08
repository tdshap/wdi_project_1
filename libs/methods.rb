require 'active_record'
require 'HTTParty'

class WeatherConditionSearch < ActiveRecord::Base
end

class WeatherConditionResponse < ActiveRecord::Base
end 

class Weather10dayResponse <ActiveRecord::Base
	def city
		Weather10dayResponse.search(weather_condition_searches_id: WeatherConditionSearch.id)
	end 
end 

class NytimesSearch <ActiveRecord::Base
end 

class NytimesResponse <ActiveRecord::Base
end 

# class NytimesEventsSearch < ActiveRecord::Base
# end 

# class NytimesEventsResponse <ActiveRecord::Base
# end 


class TwitterSearch < ActiveRecord::Base
end 

class TwitterResponse < ActiveRecord::Base
end 

class TwitterUserSearches < ActiveRecord::Base
end 

class TwitterUserResponses < ActiveRecord::Base
end 

def retrieve_weather(city, state)
	#querying wunderground API 
	response = HTTParty.get("http://api.wunderground.com/api/d8beaac28d7f691e/conditions/q/#{state}/#{city}.json")
	
	search = WeatherConditionSearch.find_by({city: city, state: state})
	
	#adding results Weather_Condition_Searches table
	WeatherConditionResponse.create({
		weather_condition_searches_id: search.id,
		city: city,
		state: response["current_observation"]["display_location"]["state"],
		country: response["current_observation"]["display_location"]["country"],
		weather: response["current_observation"]["weather"],
		temp_f: response["current_observation"]["temp_f"],
		feelslike_f: response["current_observation"]["feelslike_f"],
		icon_url: response["current_observation"]["icon_url"],
		forecast_url: response["current_observation"]["forecast_url"]  
	})
end

def retrieve_10day_forecast(city, state)
	response = HTTParty.get("http://api.wunderground.com/api/d8beaac28d7f691e/forecast10day/q/#{state}/#{city}.json")
	
	search = WeatherConditionSearch.find_by({city: city, state: state})

response["forecast"]["txt_forecast"]["forecastday"].each do |a|
	Weather10dayResponse.create({
		weather_condition_searches_id: search.id,
		period: a["period"],
		image: a["icon_url"],
		day: a["title"],
		forecast: a["fcttext"]
		})
	end 
end



def retrieve_NYT(search_term) #NYTs article search 
	#quering NYTimes API
	response = HTTParty.get("http://api.nytimes.com/svc/search/v2/articlesearch.json?q=#{search_term}&sort=newest&api-key=a96b439050b304551ed93ba9a87f929c:1:69763820")
	#creating search results with NYTimes JSON (if statement to handel empty ["multimedia"] hash)
	search = NytimesSearch.find_by(search_term: search_term)
	response["response"]["docs"].each do |a|
		if a['multimedia'] == []
			NytimesResponse.create({
				nytimes_searches_id: search.id, 
				web_url: a["web_url"],
				snippet: a["snippet"],
				image: "http://img.talkandroid.com/uploads/2011/03/nytimes-icon.jpg",
				pub_date: a["pub_date"],
				headline: a["headline"]["main"]
				})
		else
			NytimesResponse.create({
				nytimes_searches_id: search.id, 
				web_url: a["web_url"],
				snippet: a["snippet"],
				image: "https://www.nytimes.com/#{a['multimedia'][0]['url']}",
				pub_date: a["pub_date"],
				headline: a["headline"]["main"]
				})
		end
	end 
end 

def configure_twitter 
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key = "YuXQGZhXW5HVPyPyR430qQGeZ"
		  config.consumer_secret = "c4hpTZbFOpuachYZIqSznJdQVa46jOm3SwnuuV8xztRdwJIxB2"
		  config.access_token = "280633349-Cl1pvueTkyCaHBueOVjRF9nZxX4MTnoodQRWuuXI"
		  config.access_token_secret = "7B10uDNzeTQFZ8UpY8HQfX8eEyqY3xbtAOnC8eSfTlszA"
	end	
end

# post('/events/NYT')do #queries API for events in borough over the next 2 weeks
# 	borough = params["borough"]
# 	NytimesEventsSearch.create({
# 		borough: borough
# 		})
# 	start_time = Time.now.strftime("%F")
# 	end_time = (Time.now + (60*60*24*14)).strftime("%F")
# 	# 

# 	events = HTTParty.get("http://api.nytimes.com/svc/events/v2/listings.json?&date_range=#{start_time}:#{end_time}&filters=borough:#{borough}&api-key=59a0231673224986da432c5bce6ca9e6:5:69763820")
# events = HTTParty.get("http://api.nytimes.com/svc/events/v2/listings.json?filters=borough:Manhattan&&api-key=59a0231673224986da432c5bce6ca9e6:5:69763820")

# end 