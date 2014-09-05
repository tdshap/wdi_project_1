#setting up tables in psql


CREATE TABLE weather_condition_searches(
	city varchar(255),
	state varchar(2), 
	id serial primary key, 
	);


CREATE TABLE weather_condition_responses(
	weather_condition_searches_id integer, 
	city varchar(255), 
	state varchar(2), 
	country varchar(255), 
	weather varchar(255), 
	temp_f integer,
	feelslike_f varchar(100), 
	icon_url varchar(255),
	forecast_url varchar(255),
	id serial primary id, 
	);

