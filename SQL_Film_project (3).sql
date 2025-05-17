CREATE DATABASE IF NOT EXISTS imdb;
USE imdb;

CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255),
    year INT,
    date_published DATE,
    duration INT,
    country VARCHAR(100),
    worldwide_gross_income VARCHAR(50),
    languages VARCHAR(255),
    production_company VARCHAR(255)
);
CREATE TABLE genre (
    movie_id INT,
    genre VARCHAR(50),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
CREATE TABLE director_mapping (
    director_id INT,
    movie_id INT,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
CREATE TABLE role_mapping (
    movie_id INT,
    name_id INT,
    role VARCHAR(50),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);
CREATE TABLE names (
    name_id INT PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE ratings (
    movie_id INT,
    avg_rating FLOAT,
    total_votes INT,
    median_rating INT,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS imdb;
USE imdb;

-- Step 2: Create Tables
CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255),
    year INT,
    date_published DATE,
    duration INT,
    country VARCHAR(100),
    worldwide_gross_income VARCHAR(50),
    languages VARCHAR(255),
    production_company VARCHAR(255)
);

CREATE TABLE genre (
    movie_id INT,
    genre VARCHAR(50),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

CREATE TABLE director_mapping (
    director_id INT,
    movie_id INT,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

CREATE TABLE role_mapping (
    movie_id INT,
    name_id INT,
    role VARCHAR(50),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

CREATE TABLE names (
    name_id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE ratings (
    movie_id INT,
    avg_rating FLOAT,
    total_votes INT,
    median_rating INT,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- SEGMENT 1 

-- Q1: Find the total number of rows in each table
SELECT 'movies' AS table_name, COUNT(*) AS total_rows FROM movies
UNION ALL
SELECT 'genre', COUNT(*) FROM genre
UNION ALL
SELECT 'director_mapping', COUNT(*) FROM director_mapping
UNION ALL
SELECT 'role_mapping', COUNT(*) FROM role_mapping
UNION ALL
SELECT 'names', COUNT(*) FROM names
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings;

-- Q2: Identify columns with NULL values in the movie table
SELECT 'worldwide_gross_income', COUNT(*) FROM movies WHERE worldwide_gross_income IS NULL
UNION ALL
SELECT 'languages', COUNT(*) FROM movies WHERE languages IS NULL
UNION ALL
SELECT 'production_company', COUNT(*) FROM movies WHERE production_company IS NULL;

-- Q3: Find the total number of movies released each year
SELECT year, COUNT(*) AS number_of_movies FROM movies GROUP BY year ORDER BY year;

-- Find the total number of movies released each month
SELECT MONTH(date_published) AS month_num, COUNT(*) AS number_of_movies FROM movies GROUP BY month_num ORDER BY month_num;

-- Q4: Count movies produced in USA or India in 2019
SELECT COUNT(*) FROM movies WHERE (country LIKE '%USA%' OR country LIKE '%India%') AND year = 2019;

-- Q5: Find unique genres
SELECT DISTINCT genre FROM genre;

-- Q6: Find the genre with the highest number of movies
SELECT genre, COUNT(*) AS movie_count FROM genre GROUP BY genre ORDER BY movie_count DESC LIMIT 1;

-- Q7: Count movies belonging to only one genre
SELECT COUNT(*) FROM (
    SELECT movie_id FROM genre GROUP BY movie_id HAVING COUNT(genre) = 1
) AS single_genre_movies;

-- Q8: Find the average duration of movies per genre
SELECT g.genre, AVG(m.duration) AS avg_duration FROM genre g
JOIN movies m ON g.movie_id = m.movie_id
GROUP BY g.genre;

-- Q9: Rank genres based on the number of movies produced
SELECT genre, COUNT(*) AS movie_count, RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
FROM genre GROUP BY genre;

-- SEGMENT - 2

-- Q10: Find min and max values in each column of ratings table
SELECT MIN(avg_rating), MAX(avg_rating), MIN(total_votes), MAX(total_votes), MIN(median_rating), MAX(median_rating) 
FROM ratings;

-- Q11: Find the top 10 movies based on average rating
SELECT title, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS movie_rank 
FROM movies JOIN ratings ON movies.movie_id = ratings.movie_id 
ORDER BY avg_rating DESC LIMIT 10;

-- Q12: Summarise ratings table based on median rating
SELECT median_rating, COUNT(*) AS movie_count 
FROM ratings 
GROUP BY median_rating 
ORDER BY median_rating;

-- Q13: Production house with most hit movies (avg_rating > 8)
SELECT production_company, COUNT(*) AS movie_count, RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_company_rank 
FROM movies JOIN ratings ON movies.movie_id = ratings.movie_id 
WHERE avg_rating > 8 
GROUP BY production_company;

-- Q14: Movies released in each genre during March 2017 in the USA with more than 1000 votes
SELECT g.genre, COUNT(*) AS movie_count 
FROM movies m 
JOIN genre g ON m.movie_id = g.movie_id 
JOIN ratings r ON m.movie_id = r.movie_id 
WHERE YEAR(m.date_published) = 2017 AND MONTH(m.date_published) = 3 AND country LIKE '%USA%' AND total_votes > 1000
GROUP BY g.genre;

-- Q15: Movies starting with 'The' with avg rating > 8
SELECT m.title, r.avg_rating, g.genre 
FROM movies m 
JOIN genre g ON m.movie_id = g.movie_id 
JOIN ratings r ON m.movie_id = r.movie_id 
WHERE m.title LIKE 'The%' AND r.avg_rating > 8;

-- Q16: Movies released between April 1, 2018, and April 1, 2019, with median rating of 8
SELECT COUNT(*) 
FROM ratings r 
JOIN movies m ON r.movie_id = m.movie_id 
WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01' AND r.median_rating = 8;

-- Q17: Do German movies get more votes than Italian movies?
SELECT country, SUM(total_votes) AS total_votes 
FROM movies JOIN ratings ON movies.movie_id = ratings.movie_id 
WHERE country LIKE '%Germany%' OR country LIKE '%Italy%'
GROUP BY country;

-- SEGMENT - 3

-- Q18: Identify columns with NULL values in the names table
SELECT COUNT(*) AS name_nulls FROM names WHERE name IS NULL
UNION ALL
SELECT COUNT(*) AS height_nulls FROM names WHERE height IS NULL
UNION ALL
SELECT COUNT(*) AS date_of_birth_nulls FROM names WHERE date_of_birth IS NULL
UNION ALL
SELECT COUNT(*) AS known_for_movies_nulls FROM names WHERE known_for_movies IS NULL;

-- Q19: Top three directors in the top three genres with avg rating > 8
SELECT d.name AS director_name, COUNT(*) AS movie_count 
FROM director_mapping dm 
JOIN movies m ON dm.movie_id = m.movie_id 
JOIN ratings r ON m.movie_id = r.movie_id 
JOIN names d ON dm.director_id = d.name_id 
JOIN genre g ON m.movie_id = g.movie_id 
WHERE r.avg_rating > 8 AND g.genre IN (
    SELECT genre FROM genre g 
    JOIN ratings r ON g.movie_id = r.movie_id 
    WHERE r.avg_rating > 8 
    GROUP BY genre ORDER BY COUNT(*) DESC LIMIT 3
)
GROUP BY d.name ORDER BY movie_count DESC LIMIT 3;

-- Q20: Top two actors with median rating >= 8
SELECT n.name AS actor_name, COUNT(*) AS movie_count 
FROM role_mapping rm 
JOIN movies m ON rm.movie_id = m.movie_id 
JOIN ratings r ON m.movie_id = r.movie_id 
JOIN names n ON rm.name_id = n.name_id 
WHERE r.median_rating >= 8 
GROUP BY n.name ORDER BY movie_count DESC LIMIT 2;

-- Q21: Top three production houses based on votes received
SELECT production_company, SUM(total_votes) AS vote_count, RANK() OVER (ORDER BY SUM(total_votes) DESC) AS prod_comp_rank 
FROM movies JOIN ratings ON movies.movie_id = ratings.movie_id 
WHERE production_company IS NOT NULL 
GROUP BY production_company LIMIT 3;

-- Q22: Rank actors with movies in India based on avg ratings (weighted by votes)
SELECT n.name AS actor_name, SUM(r.total_votes) AS total_votes, COUNT(*) AS movie_count, 
       SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actor_avg_rating,
       RANK() OVER (ORDER BY SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) DESC) AS actor_rank 
FROM role_mapping rm 
JOIN movies m ON rm.movie_id = m.movie_id 
JOIN ratings r ON m.movie_id = r.movie_id 
JOIN names n ON rm.name_id = n.name_id 
WHERE m.country LIKE '%India%' 
GROUP BY n.name HAVING COUNT(*) >= 5;

-- Q23: Top five actresses in Hindi movies released in India based on avg ratings
SELECT n.name AS actress_name, SUM(r.total_votes) AS total_votes, COUNT(*) AS movie_count, 
       SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actress_avg_rating,
       RANK() OVER (ORDER BY SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) DESC) AS actress_rank 
FROM role_mapping rm 
JOIN movies m ON rm.movie_id = m.movie_id 
JOIN ratings r ON m.movie_id = r.movie_id 
JOIN names n ON rm.name_id = n.name_id 
WHERE m.country LIKE '%India%' AND m.languages LIKE '%Hindi%' 
GROUP BY n.name HAVING COUNT(*) >= 3 LIMIT 5;

-- Q24: Categorize thriller movies based on avg rating
SELECT m.title, r.avg_rating, 
       CASE 
           WHEN r.avg_rating > 8 THEN 'Superhit movies'
           WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
           WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
           ELSE 'Flop movies'
       END AS category 
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
JOIN genre g ON m.movie_id = g.movie_id
WHERE g.genre = 'Thriller';

-- SEGMENT - 4

-- Q25: Genre-wise running total and moving average of avg duration
SELECT g.genre, ROUND(AVG(m.duration), 2) AS avg_duration,
       SUM(AVG(m.duration)) OVER (PARTITION BY g.genre ORDER BY g.genre) AS running_total_duration,
       AVG(AVG(m.duration)) OVER (PARTITION BY g.genre ORDER BY g.genre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_duration
FROM genre g
JOIN movies m ON g.movie_id = m.movie_id
GROUP BY g.genre;

-- Q26: Five highest-grossing movies per year in the top 3 genres
WITH TopGenres AS (
    SELECT genre FROM genre 
    JOIN movies ON genre.movie_id = movies.movie_id
    GROUP BY genre ORDER BY COUNT(*) DESC LIMIT 3
)
SELECT g.genre, m.year, m.title AS movie_name, m.worldwide_gross_income,
       RANK() OVER (PARTITION BY m.year ORDER BY CAST(REPLACE(m.worldwide_gross_income, '$', '') AS UNSIGNED) DESC) AS movie_rank
FROM movies m
JOIN genre g ON m.movie_id = g.movie_id
WHERE g.genre IN (SELECT genre FROM TopGenres)
ORDER BY m.year, movie_rank LIMIT 5;

-- Q27: Top two production houses with most hits among multilingual movies
SELECT production_company, COUNT(*) AS movie_count, 
       RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_comp_rank
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
WHERE r.median_rating >= 8 AND POSITION(',' IN m.languages) > 0
GROUP BY production_company LIMIT 2;

-- Q28: Top 3 actresses based on number of super hit movies (Drama, avg_rating > 8)
SELECT n.name AS actress_name, SUM(r.total_votes) AS total_votes, COUNT(*) AS movie_count, 
       SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actress_avg_rating,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS actress_rank
FROM role_mapping rm
JOIN movies m ON rm.movie_id = m.movie_id
JOIN ratings r ON m.movie_id = r.movie_id
JOIN names n ON rm.name_id = n.name_id
JOIN genre g ON m.movie_id = g.movie_id
WHERE g.genre = 'Drama' AND r.avg_rating > 8
GROUP BY n.name LIMIT 3;

-- Q29: Details for top 9 directors based on number of movies
WITH DirectorStats AS (
    SELECT dm.director_id, n.name AS director_name, COUNT(*) AS number_of_movies,
           AVG(DATEDIFF(LEAD(m.date_published) OVER (PARTITION BY dm.director_id ORDER BY m.date_published), m.date_published)) AS avg_inter_movie_days,
           AVG(r.avg_rating) AS avg_rating, SUM(r.total_votes) AS total_votes,
           MIN(r.avg_rating) AS min_rating, MAX(r.avg_rating) AS max_rating,
           SUM(m.duration) AS total_duration
    FROM director_mapping dm
    JOIN movies m ON dm.movie_id = m.movie_id
    JOIN ratings r ON m.movie_id = r.movie_id
    JOIN names n ON dm.director_id = n.name_id
    GROUP BY dm.director_id
)
SELECT * FROM DirectorStats ORDER BY number_of_movies DESC LIMIT 9;



