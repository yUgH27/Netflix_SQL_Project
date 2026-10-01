


-- Netflix Project
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(
	show_id	varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(250),
	casts varchar(1000),
	country varchar(250),
	date_added varchar(50),	
	release_year int,
	rating varchar(10),
	duration varchar(30),
	listed_in varchar(100),
	description varchar(500)

);

Select * from netflix;

Select count(*) as total_content
from netflix;

Select 
	DISTINCT type
from netflix;

-- 15 Business Problems

-- 1. Count the number of movies vs TV shows

Select
	type,
	count(*) as num_of_type
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
Select 
	type,
	rating,
	ranking
from

(Select 
	type,
	rating,
	count(*),
	rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by 1, 2 
order by 1, 3 desc
)
as t1
where ranking = 1;


-- 3. List all movies released in a specific year (e.g. 2020)

Select 
	title,
	release_year
from netflix 
where release_year = 2020 AND type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix

Select 
	unnest(string_to_array(country, ',')) as new_country,
	count(show_id) as total_content
from netflix
group by 1
order by 2 desc limit 5;

-- 5. Identify the longest movie

Select
	title,
	duration
from netflix
where 
	type = 'Movie' AND
	duration = (select max(duration) from netflix)

-- 6. FInd content added in the last five years

Select
	*
From netflix
where
	to_date(date_added, 'Month DD, YYYY') >= current_date - INTERVAL '5 years'

-- 7. Find all movies/TV shows by director 'Rajiv Chilaka'

Select
	title,
	director
from netflix
where director ILIKE '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons

Select 
	title,
	type,
	duration
from netflix
where
	type = 'TV Show' AND
	split_part(duration, ' ', 1)::numeric >=5;

-- 9. Count the number of content items in each genre

Select 
	unnest(string_to_array(listed_in, ',')) as genre,
	count(*) as number_of_content
from netflix
group by 1
order by number_of_content desc;

-- 10. Find each year and the average number of content released by India on netflix; return top 5 year within highest avg content release

select
	Extract( Year from to_date(date_added, 'Month DD, YYYY')) as date,
	count(*) as total_content,
	round(count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100, 2) as avg_content
from netflix
where country = 'India'
group by 1;

-- 11. List all movies that are documentaries

select
	*
from netflix
where listed_in ilike '%Documentaries%';

-- 12. Find all content without a director

select
	*
from netflix
where director is null;	

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select
	*
from netflix
where 
	casts ilike '%Salman Khan%'
	AND
	release_year > extract(year from current_date)- 10
;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select
	Unnest(string_to_array(casts, ',')) as actors,
	count(*) as total_movies
from netflix
where country ilike '%India%'
group by 1
order by 2 desc
limit 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category

with new_table as
(
select
	*,
	case
		when description ilike '%kill%' or description ilike '%violence%'
		then 'Bad' else 'Good'
	end category
from netflix
)

select
	category,
	count(*) as total_content
from new_table
group by 1;
