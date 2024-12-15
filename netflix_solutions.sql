DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);



-- 1. Count the Number of Movies vs TV Shows
SELECT 
	type,
	count(*) as total_content
FROM netflix
GROUP BY type


-- 2. Find the Most Common Rating for Movies and TV Shows
SELECT 
	type,
	rating
FROM (
	SELECT 
		type,
		rating,
		RANK() OVER(PARTITION BY type ORDER BY count(rating) DESC) AS ranking
	FROM netflix
GROUP BY 1,2) AS t1
WHERE ranking = 1

-- 3. List All Movies Released in a Specific Year (e.g., 2021)

SELECT *
FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2021
	

-- 4. Find the Top 5 Countries with the Most Content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


-- 5. Identify the Longest Movie
SELECT 
	title,
	duration
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)


-- 6. Find Content Added in the Last 5 Years

SELECT 
	title,
	type,
	date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'



-- 7. Find All Movies/TV Shows by Director 'Scott Stewart'

SELECT 
	type,
	title,
	director
FROM netflix
WHERE
	director LIKE '%Scott Stewart%'


-- 8. List All TV Shows with More Than 5 Seasons
SELECT 
	show_id,
	title,
	country,
	duration
FROM netflix
WHERE
	 type = 'TV Show'
	 AND
	 SPLIT_PART(duration, ' ', 1)::INT > 5

-- 9. Count the Number of Content Items in Each Genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC


-- 10.Find each year and the average numbers of content release in India on netflix. Return the Top 5 years with highest avg content release
SELECT  
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) AS year,
	COUNT(*) AS content_added_that_year,
	ROUND(
	COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100 ,2
	) as average_content_added
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5


-- 11. List all the Movies that are Documentries

SELECT 
	type,
	title,
	listed_in
FROM netflix
WHERE 
	listed_in LIKE '%Documentaries%'
	
	

-- 12. Find All Content Without a Director

SELECT *
FROM netflix
WHERE director is Null

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10



-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in description
-- And label this content as 'bad' and others as 'good'

WITH category_table as (
SELECT 
*,
	CASE 
	WHEN description ILIKE '%Kill%'
	OR description ILIKE '%Violence%' THEN 'Bad'
	ELSE 'Good'
	END category
FROM netflix
)
SELECT category	,
	COUNT(*) AS total_content
FROM category_table
GROUP BY 1











