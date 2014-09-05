require 'sinatra'
require 'sinatra/reloader'
require_relative './libs/connection'
require_relative './libs/methods'
require 'httparty'
require 'pry'

after do #closes ActiveRecord connection
  ActiveRecord::Base.connection.close
end

get('/') do # main feed
	erb(:index)
end 

#WEATHER ROUTES

get('/weather/add_location') do #page to add locations to search
	erb(:weather_new_location)
end 

def retrieve_weather(city, state)
	#querying wunderground API 
	response = HTTParty.get("http://api.wunderground.com/api/d8beaac28d7f691e/conditions/q/#{state}/#{city}.json")
	
	search = WeatherConditionSearch.find_by(city: city)
	
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

post('/weather') do #creating a new weather search (condition)
	#format params: state, city
	city = params["city"].tr(' ', '_')
	state = params["state"].upcase

	#save search to database
	WeatherConditionSearch.create({city: city, state: state})
	retrieve_weather(city, state)
	redirect'/weather'
end 

get('/weather') do #display weather feed for all cities
	erb(:all_weather, {locals: { weather: WeatherConditionResponse.all }})
end 

get("/weather/:id") do #displays weather for 1 city
	city_weather = WeatherConditionResponse.find_by(id: params["id"])
	erb(:weather_post, {locals: {weather: city_weather}})
end 

get("/edit/weather") do #form to edit and delete searches
	erb(:weather_preferences, {locals: { search: WeatherConditionSearch.all, response: WeatherConditionResponse.all }})
end

put('/search/weather') do #editing a weather search 
	city = WeatherConditionSearch.find_by(id: params["search_city"])
	city_hash={
		city: params["city"],
		state: params["state"]
	}
	city.update(city_hash)
	redirect "/refresh/weather" #refreshed all weather data using new search
end 

delete('/search/weather') do #deleting a weather search
	city = WeatherConditionSearch.find_by(id: params["search_city"])
	city.destroy
	redirect "/"
end 

get('/refresh/weather') do #deletes and re-creates WeatherConditionResponses using WeatherConditionSearch
	WeatherConditionResponse.delete_all
	WeatherConditionSearch.all.each do |a|
		city = a["city"]
		state = a["state"]
		retrieve_weather(city, state)
	end 
	redirect('/weather')
end 



# NYTIMES ROUTES

get('/NYT') do #displays NYT articles 
	erb(:NYTimes)
end 

get('/NYT/add_search') do #form to add new search words
 erb(:NYTimes_new_search_term)
end 

post('/NYT') do 
	search_term = params["search_term"].tr(" ", "+")
	NytimesSearch.create({search_term: search_term})
	response = HTTParty.get("http://api.nytimes.com/svc/search/v2/articlesearch.json?q=#{search_term}&sort=newest&api-key=a96b439050b304551ed93ba9a87f929c:1:69763820")
binding.pry

search = NytimesSearch.find_by(search_term: search_term)
	response["response"]["docs"].each do |a|
		NytimesResponse.create({
			nytimes_searches_id: search.id, 
			web_url: a["web_url"],
			snippet: a["snippet"],
			image: "www.nytimes.com#{a['multimedia'][0]['url']}",
			pub_date: a["pub_date"],
			headline: a["headline"]["main"]
		})
	end 
	redirect ("/NYT")
end 

get('/edit/NYT') do 

end 

get("refresh/NYT") do 

end 










