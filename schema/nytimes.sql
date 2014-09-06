#creating NYTimes tables

CREATE TABLE nytimes_searches(
	city varchar(255),
	state varchar(2), 
	id serial primary key, 
	);


CREATE TABLE nytimes_responses(
	nytimes_searches_id integer, 
	web_url varchar(255), 
	snippet varchar(255),
	#image varchar(255),
	pub_date varchar(255),
	headline varchar(255),
	id serial primary id, 
	);