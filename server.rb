require 'sinatra'
require 'sinatra/reloader'
require_relative './libs/connection'
require_relative './libs/methods'
require 'httparty'
require 'pry'
set :server, 'webrick'
require 'twitter'


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

post('/weather') do #creating a new weather search (condition)
	#format params: state, city
	city = params["city"].tr(' ', '_')
	state = params["state"].upcase

	#save search to database
	WeatherConditionSearch.create({city: city, state: state})
	retrieve_weather(city, state)
	retrieve_10day_forecast(city, state)
	redirect'/weather'
end 

get('/weather') do #display weather feed for all cities

	erb(:all_weather, {locals: { weather: WeatherConditionResponse.all, ten_day: Weather10dayResponse.all }})
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
	redirect "/refresh/weather"
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
	erb(:NYTimes, {locals: { news: NytimesResponse.all }})
end 

get('/NYT/add_search') do #form to add new search words
 erb(:NYTimes_new_search_term)
end 

post('/NYT') do  # queries NYTimes API with new search terms
	search_term = params["search_term"].tr(" ", "+")
	retrieve_NYT(search_term)

	redirect ("/NYT")
end 

get("/NYT/:id") do # individual article page
	article = NytimesResponse.find_by(id: params["id"])
	erb(:NYT_post, {locals: { article: article }})
end 

get('/edit/NYT') do # edit search preferences
	erb(:NYTimes_preferences, {locals: { terms: NytimesSearch.all }})
end 

put('/search/NYT') do #updates NYTimes search terms
	new_search = NytimesSearch.find_by(id: params["search_id"])
	new_search.update(search_term: params["new_search_term"])
	redirect('/refresh/NYT')
end 


delete('/search/NYT') do #deletes NYTimes search terms 
	delete_search = NytimesSearch.find_by(id: params["search_id"])
	delete_search.destroy
	redirect('/refresh/NYT')
end 

get('/refresh/NYT') do #deletes posts in NytimesResponse db. Re-queries NYTimes API with updates searches
	NytimesResponse.delete_all
	NytimesSearch.all.each do |a|
		search_term = a["search_term"]
		retrieve_NYT(search_term)
	end 
	redirect('/NYT')
end 


#TWITTER ROUTES

get('/twitter') do #displays all twitter results
	erb(:twitter, {locals: { twitter: TwitterResponse.all }})
end 

get('/twitter/add_search') do # form to add new twitter searches

	erb(:twitter_new_search_term)
end 

post('/twitter') do 
binding.pry
	configure_twitter

	search_term = params["search_term"]
	TwitterSearch.create({search_term: search_term})

	twitter_response = client.search("#{search_term}", :result_type => "recent", :lang => "en").take(10)
	#to go beyond MVP, handle media & hashtags

	twitter_response.each do |a|
		TwitterResponse.create({
		created_at: a.created_at, 
		full_text: a.full_text, 
		screen_name: a.user.screen_name,
		});
	end 
	redirect('/twitter')
end

post("/follow/twitter") do 
	client = Twitter::REST::Client.new do |config|
		  config.consumer_key = "YuXQGZhXW5HVPyPyR430qQGeZ"
		  config.consumer_secret = "c4hpTZbFOpuachYZIqSznJdQVa46jOm3SwnuuV8xztRdwJIxB2"
		  config.access_token = "280633349-Cl1pvueTkyCaHBueOVjRF9nZxX4MTnoodQRWuuXI"
		  config.access_token_secret = "7B10uDNzeTQFZ8UpY8HQfX8eEyqY3xbtAOnC8eSfTlszA"
	end	

	username = params["handle"]
	TwitterUserSearch.create({follow_user: username})
	#need to make twitter_user_searches & responses tables
	twitter_response = client.user("#{username}")
	
	TwitterUserResponse.create({
		tweet: twitter_response.tweet.full_text,
		unparsed_url: twitter_response.tweet.url,


	})
end 
#delete and update routes, twitter/:id, all erb files, displaying info on main twitter page. 

