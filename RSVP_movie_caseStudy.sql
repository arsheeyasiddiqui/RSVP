USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

-- THIS QUERY WILL SHOW THE COUNT OF ROWS FOR EACH TABLE IN THE DATASET

  SELECT
  (SELECT COUNT(*) FROM director_mapping) AS Director_Mapping_Rows,
  (SELECT COUNT(*) FROM genre) AS Genre_Rows,
  (SELECT COUNT(*) FROM movie) AS Movie_Rows,
  (SELECT COUNT(*) FROM names) AS Names_Rows,
  (SELECT COUNT(*) FROM ratings) AS Ratings_Rows,
  (SELECT COUNT(*) FROM role_mapping) AS Role_Mapping_Rows;

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

-- COUNTING THE NULL VALUES FOR EACH COLUMN IN MOVIE TABLE.
SELECT
    COUNT(IF(id IS NULL, 1, NULL))AS id_null_count,
    COUNT(IF(title IS NULL, 1, NULL)) AS title_null_count,
    COUNT(IF(year IS NULL, 1, NULL)) AS year_null_count,
    COUNT(IF(date_published IS NULL, 1, NULL)) AS date_published_null_count,
    COUNT(IF(duration IS NULL, 1, NULL)) AS duration_null_count,
    COUNT(IF(country IS NULL, 1, NULL)) AS country_null_count,
    COUNT(IF(worlwide_gross_income IS NULL, 1, NULL)) AS worlwide_gross_income_null_count,
    COUNT(IF(languages IS NULL, 1, NULL)) AS languages_null_count,
    COUNT(IF(production_company IS NULL, 1, NULL)) AS production_company_null_count
FROM movie;

-- COUNTRY,WORLWIDE_GROSS_INCOME,LANGUAGES,PRODUCTION_COMPANY COLUMNS HAVE NULL VALUES

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- MOVIES RELEASED EACH YEAR

SELECT Year,
       Count(title) AS number_of_movies
FROM  movie
GROUP BY Year; 

--  MOVIES RELEASED EACH MONTH

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM movie
   GROUP BY month_num
   ORDER BY month_num;



/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT Count(id) AS Total_movie_count
FROM movie
WHERE year = 2019
AND (country LIKE'%India%' OR country LIKE '%USA%' ); 


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT genre AS Total_Unique_Genre
from genre
GROUP BY genre;

-- NOT USING DISTINCT() BECAUSE IT TAKES MORE RUN TIME. USING "GROUP BY" AS IT WILL GIVE US THE SAME OUTPUT.



/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

select g.genre, count(m.id) as Total_movie_produced
from movie as m
inner join
genre as g
on m.id= g.movie_id
group by genre
order by Total_movie_produced desc LIMIT 3;

-- DRAMA GENRE HAS THE HIGHEST NUMBER OF MOVIES PRODUCED.

-- WE CAN ALSO DO THIS WITHOUT JOINING THE GENRE AND MOVIE TABLE

-- SELECT genre,
-- Count(movie_id) AS Total_movie_produced
-- FROM genre
-- GROUP BY genre
-- ORDER BY total_movie_produced DESC; select genre, count(movie_id) as Total_movie_produced
-- from genre group by genre
-- order by Total_movie_produced desc LIMIT 1;


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:


WITH one_genre_movies  -- CREATING A COMMON TABLE EXPRESSION NAMED 'one_genre_movies'
     AS (SELECT movie_id
         FROM genre
         GROUP BY movie_id
         HAVING Count(genre) = 1)
         -- THIS PART OF THE MOVIE COUNTS THE NO. OF MOVIES THAT BELONGS TO ONE GENRE
SELECT Count(*) AS One_genre_movies_count
FROM one_genre_movies;

-- 3289 MOVIES BELONGS TO ONE GENRE



/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre,
       Round(Avg(m.duration),2) AS avg_duration
FROM movie AS m
       INNER JOIN genre AS g
	   ON m.id = g.movie_id
GROUP BY genre; 


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- COMMON TABLE EXPRESSION TO CALCULATE THE RANKING OF GENRES BASED ON MOVIE COUNT.
WITH genre_ranking
     AS (SELECT genre,
		    Count(movie_id) AS movie_count,
		Rank() 
         OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
	FROM genre
         GROUP BY genre)
-- SELECTING ALL COLUMNS FROM THE GENRE_RANKING CTE WHERE THE GENRE IS 'THRILLER'.
SELECT *
FROM genre_ranking
WHERE genre = 'Thriller'; 



/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

-- THIS QUERY SELECTS THE MINIMUM AND MAXIMUM VALUES FOR VARIOUS RATING METRICS FROM THE 'RATINGS' TABLE.

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;



/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too


-- WE CAN ALSO DO THIS WITH RANK() OR DENSE_RANK() .

WITH movies_ranking    -- USING CTE AS 'movies_ranking'
     AS (SELECT m.title, r.avg_rating,  -- ASSIGNING RANK TO THE MOVIES BASED ON DESCENDING AVERAGE RATINGS
		 Row_number()
			OVER(ORDER BY avg_rating DESC) AS movie_rank
	FROM ratings AS r
                INNER JOIN movie AS m
                        ON r.movie_id = m.id)
-- FILTERING THE RESULTS TO ONLY INCLUDE MOVIES WITH A RANK OF 1 TO 10
SELECT *
FROM movies_ranking
WHERE movie_rank <= 10; 



/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

select median_rating, count(movie_id) as movie_count
from ratings
group by median_rating
order by median_rating;


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

-- WITH CLAUSE TO CREATE A TEMPORARY TABLE NAMED MOST_HIT_MOVIES

WITH most_hit_movies
                              -- CALCULATING THE COUNT OF MOVIES FOR EACH PRODUCTION COMPANY AND GIVING RANK TO THEM.
     AS (SELECT m.production_company,
                Count(m.id) AS movie_count,
                Dense_rank()
                  OVER(ORDER BY Count(m.id) DESC) AS prod_company_rank
         FROM movie AS m
                INNER JOIN ratings AS r
					ON m.id = r.movie_id
         WHERE avg_rating > 8
                AND production_company IS NOT NULL
         GROUP BY m.production_company)
         -- -- FILTERING THE RESULT TO ONLY INCLUDE ROWS WHERE PROD_COMPANY_RANK IS 1
SELECT *
FROM most_hit_movies
WHERE prod_company_rank = 1; 

-- DREAM WARRIOR PICTURES AND NATIONAL THEATRE LIVE HAS THE HIGHEST NUMBER OF HIT MOVIES.


-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- IN ORDER TO GET THE ANSWER WE NEED TO MERGE THREE TABLES WHICH WILL BE MOVIE,GENRE AND RATINGS.
-- SELECTING THE GENRE AND COUNTING THE NUMBER OF MOVIES IN EACH GENRE FOR THE YEAR 2017, PUBLISHED IN MARCH, IN THE USA, WITH MORE THAN 1000 TOTAL VOTES

SELECT g.genre,
	  Count(m.id) AS movie_count
FROM  movie AS m
	  INNER JOIN ratings AS r
               ON m.id = r.movie_id
	  INNER JOIN genre AS g
               ON g.movie_id = m.id
WHERE m.year = 2017
       AND Month(m.date_published) = '3'
       AND m.country LIKE '%USA%'
       AND r.total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;  -- ORDERING THE RESULT BY MOVIE COUNT IN DESCENDING ORDER




-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT m.title,
       r.avg_rating,
       g.genre
FROM movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
       INNER JOIN genre AS g
               ON g.movie_id = m.id
WHERE title LIKE 'The%'
       AND avg_rating > 8
ORDER BY r.avg_rating DESC; 

-- 'THE BRIGHTON MIRACLE' MOVIE HAS THE HIGHEST RATING WHICH IS '9.5' AND BELONG TO GENRE 'DRAMA'
-- TOP TWO MOVIES WITH THE HIGHEST RATINGS BELONGS TO 'DRAMA' GENRE.

               

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
    COUNT(m.id) AS Movies_with_median_rating_8
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    (m.date_published BETWEEN '2018-04-01' AND '2019-04-01')
        AND (r.median_rating)= 8;
        
-- BETWEEN 1 APRIL 2018 AND 1 APRIL 2019 361 MOVIES WERE RELEASED WITH THE MEDIAN RATING OF 8.



-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- THIS QUERY CALCULATES THE TOTAL NUMBER OF VOTES FOR MOVIES IN GERMAN LANGUAGE AND ITALIAN LANGUAGE SEPARATELY.
-- IT THEN COMPARES THE TOTAL NUMBER OF VOTES FOR GERMAN LANGUAGE MOVIES WITH THE TOTAL NUMBER OF VOTES FOR ITALIAN LANGUAGE MOVIES.

WITH German_language AS 
-- SUMMING UP THE TOTAL VOTES FOR MOVIES IN GERMAN LANGUAGE

(SELECT Sum(r.total_votes) AS German_movie_votes
         FROM movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
         WHERE m.languages LIKE '%German%'),
     Italain_language AS 
     
     -- SUMMING UP THE TOTAL VOTES FOR MOVIES IN ITALIAN LANGUAGE
     (SELECT Sum(r.total_votes) AS Italian_movie_votes
         FROM movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
         WHERE m.languages LIKE '%Italian%')
         
-- COMPARINING THE TOTAL VOTES OF GERMAN LANGUAGE MOVIES WITH ITALIAN LANGUAGE MOVIES        
SELECT CASE
         WHEN german_movie_votes > italian_movie_votes THEN 'Yes'
         ELSE 'No'
       END AS 'German_movies_gets_more_votes_than_Italian'
FROM German_language, Italain_language;



-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT Count(IF(name IS NULL, 1, NULL)) AS name_nulls,
       Count(IF(height IS NULL, 1, NULL)) AS height_nulls,
       Count(IF(date_of_birth IS NULL, 1, NULL)) AS date_of_birth_nulls,
       Count(IF(known_for_movies IS NULL, 1, NULL)) AS known_for_movies_nulls
FROM names; 

-- HEIGHT, DATE_OF_BIRTH, KNOWN_FOR_MOVIES HAS NULL VALUES IN 'NAMES' TABLE. WE DID NOT CHECK FOR ID BECAUSE IT IS A PRIMARY KEY.





/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


-- DEFINED A COMMON TABLE EXPRESSION NAMED TOP_THREE_GENRES TO FIND THE TOP THREE GENRES WITH THE HIGHEST COUNT OF MOVIES WITH AN AVERAGE RATING GREATER THAN 8.

WITH top_three_genres AS(

--  SELECTING GENRE AND COUNT THE NUMBER OF MOVIES BELONGING TO EACH GENRE, FILTERING BY MOVIES WITH AN AVERAGE RATING GREATER THAN 8.
 SELECT g.genre, COUNT(m.id) AS count_of_movies
	FROM movie AS m
 INNER JOIN genre AS g
     ON m.id=g.movie_id
 INNER JOIN ratings AS r
     ON r.movie_id=m.id
 WHERE avg_rating>8
     GROUP BY g.genre
 ORDER BY count_of_movies DESC LIMIT 3
 )
 
 -- SELECTING DIRECTOR NAMES AND COUNT THE NUMBER OF MOVIES DIRECTED BY EACH DIRECTOR WITHIN THE TOP THREE GENRES.
 SELECT n.name AS director_name, COUNT(m.id) AS movie_count
		FROM names AS n 
 INNER JOIN director_mapping AS d 
        ON n.id= d.name_id
 INNER JOIN movie AS m 
        ON m.id=d.movie_id
 INNER JOIN genre AS g 
        ON m.id=g.movie_id
 INNER JOIN ratings AS r 
        ON r.movie_id= m.id
 WHERE g.genre IN (SELECT genre FROM top_three_genres) -- FILTERING MOVIES BY DIRECTORS WHOSE GENRES MATCH THOSE IN THE TOP_THREE_GENRES CTE AND HAVE AN AVERAGE RATING GREATER THAN 8.

        AND avg_rating>8
 GROUP BY director_name
 ORDER BY movie_count DESC 
        LIMIT 3;

-- 'JAMES MANGOLD' , 'JOE RUSSO' AND 'ANTHONY RUSSO' ARE TOP THREE DIRECTORS IN THE TOP THREE GENRES WHOSE MOVIES HAVE AN AVERAGE RATING > 8. 
 

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- CREATED (CTE) WHICH CALCULATES THE RANKING OF ACTORS BASED ON THE COUNT OF MOVIES THEY HAVE WORKED IN, WITH A MEDIAN RATING OF 8 OR HIGHER.
WITH actors_ranking AS (
SELECT n.name AS actor_name,
       Count(m.id) AS movie_count,
       DENSE_RANK() OVER(ORDER BY Count(m.id) DESC) AS rank_per_movie_count
FROM names AS n
       INNER JOIN role_mapping AS RM
               ON n.id = RM.name_id
       INNER JOIN movie AS m
               ON m.id = RM.movie_id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE median_rating >= 8 AND category= 'actor'
GROUP BY actor_name)
-- MAIN QUERY THAT SELECTS THE ACTOR'S NAME AND THEIR MOVIE COUNT, FILTERED BY THEIR RANK PER MOVIE COUNT BEING LESS THAN OR EQUAL TO 2

SELECT actor_name, movie_count
    FROM  actors_ranking 
WHERE rank_per_movie_count<=2;

-- 'MAMMOOTTY' and 'MOHANLAL' ARE THE TOP TWO ACTORS WHO HAS THE HIGHEST NUMBER OF MOVIES WITH MEDIAN RATING OF >= 8




/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

-- THIS QUERY CALCULATES THE TOTAL VOTE COUNT FOR EACH PRODUCTION COMPANY AND RANKS THEM BASED ON THEIR TOTAL VOTES.

WITH prod_comp_ranking AS (
SELECT production_company,
       SUM(total_votes) AS vote_count,
	   DENSE_RANK() 
OVER (ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
       FROM movie AS m
INNER JOIN ratings AS r 
       ON m.id=r.movie_id
GROUP BY production_company

) SELECT * FROM prod_comp_ranking  -- QUERY TO FIND OUT THE PRODUCTION COMPANIES WITH THE TOP THREE HIGHEST TOTAL VOTES.
       WHERE prod_comp_rank<=3;
       
-- 'Marvel Studios', 'Twentieth Century Fox', 'Warner Bros.' ARE THE TOP THREE PRODUCTION HOUSES BASED ON THE NUMBER OF VOTES RECEIVED.
      
      

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


-- WE WILL RANK ACTORS WITH MOVIES RELEASED IN INDIA BASED ON THEIR AVERAGE RATINGS
-- WE ALSO HAVE TO CALCULATE THE AVERAGE RATINGS BASED ON THE VOTES
 -- ACTOR_AVG_RATING= SUM(AVG_RATING * TOTAL_VOTES) / SUM(TOTAL_VOTES). THEN WE WILL ROUND THE VALUES TO 2 DECIMAL PLACE.
 
SELECT n.NAME AS actor_name,
       Sum(r.total_votes)
       AS total_votes,
       Count(m.id)
       AS movie_count,
       Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2)
       AS actor_avg_rating,
       Dense_rank()
         OVER(
           ORDER BY Round(Sum(avg_rating * total_votes)/ Sum(total_votes), 2)
         DESC,Sum(r.total_votes) DESC) AS  -- USING SUM OF TOTAL VOTES ALSO IN ORDER BY BECAUSE IF WE HAVE TWO ACTORS WITH THE SAME RATING THEN WE WILL CONSIDER TOTAL VOTES.
       actor_rank
FROM names AS n
       INNER JOIN role_mapping AS RM
               ON n.id = RM.name_id
       INNER JOIN movie AS m
               ON m.id = RM.movie_id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE country LIKE '%India%'
       AND category = 'Actor'
GROUP BY actor_name
HAVING movie_count >= 5; 

-- 'VIJAY SETHUPATHI' IS THE TOP ACTOR WITH 8.42 AVERAGE RATING.


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH actress_ranking AS (
SELECT n.NAME AS actress_name,
       Sum(r.total_votes)
       AS total_votes,
       Count(m.id)
       AS movie_count,
       Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2)
       AS actress_avg_rating,
       Dense_rank()
         OVER(
           ORDER BY Round(Sum(avg_rating * total_votes)/ Sum(total_votes), 2)
         DESC, sum(total_votes) DESC) AS  -- USING SUM OF TOTAL VOTES ALSO IN ORDER BY BECAUSE IF WE HAVE TWO ACTRESS WITH THE SAME RATING THEN WE WILL CONSIDER TOTAL VOTES.
       actress_rank
FROM names AS n
       INNER JOIN role_mapping AS RM
               ON n.id = RM.name_id
       INNER JOIN movie AS m
               ON m.id = RM.movie_id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE country LIKE '%India%'
       AND category = 'Actress'
AND languages LIKE '%Hindi%'       
GROUP BY actress_name
HAVING movie_count >= 3
)
SELECT * FROM actress_ranking
    WHERE actress_rank <6;

-- TAAPSEE PANNU, KRITI SANON, DIVYA DUTTA, SHRADDHA KAPOOR, KRITI KHARBANDA ARE TOP 5 ACTRESS.



/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

 -- THIS QUERY SELECTS THE TITLE OF MOVIES, THEIR AVERAGE RATINGS, AND CATEGORIZES THEM BASED ON THEIR AVERAGE RATINGS.
SELECT m.title,
       r.avg_rating,
       CASE    -- USING CASE STATEMENT TO CATEGORIZE MOVIES BASED ON THEIR AVERAGE RATINGS INTO DIFFERENT CATEGORIES.
         WHEN r.avg_rating > 8 THEN 'Superhit movies'
         WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       end AS rating_category
FROM movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE g.genre = 'Thriller';  -- FILTERS THE RESULT SET TO INCLUDE ONLY MOVIES WITH THE GENRE 'THRILLER'.



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT g.genre,
       Round (Avg(duration), 2) AS avg_duration,
       SUM(Round(Avg(duration), 2)) over (ORDER BY g.genre) AS running_total_duration, -- CALCULATING THE RUNNING TOTAL OF AVERAGE DURATIONS OF MOVIES IN EACH GENRE, ORDERED BY GENRE.
       Round(Avg(Round(Avg(duration), 2)) over (ORDER BY g.genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)  -- CALCULATING THE MOVING AVERAGE OF AVERAGE DURATIONS OF MOVIES IN EACH GENRE, FROM THE BEGINNING TO THE CURRENT ROW.
				AS moving_avg_duration
FROM genre AS g
       inner join movie AS m
               ON g.movie_id = m.id
GROUP BY g.genre
ORDER BY g.genre; 


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

-- IN THE FIRST SEGMENT WE WILL BE FINDING THE TOP THREE GENRES BASED ON NUMBER OF MOVIES

 WITH top_three_genre
 AS (
             SELECT g.genre,
			 count(m.id) AS count_of_movies
             FROM genre AS g
             INNER JOIN movie AS m
             ON m.id=g.movie_id
             GROUP BY g.genre
             ORDER BY count_of_movies DESC
             LIMIT 3 
             ), value_correction AS
             
-- IN THIS SEGMENT WE ARE USING ANOTHER CTE TO CHANGE THE VALUES FROM INR TO USD AS WE HAVE VALUES IN DIFFERENT CURRENCIES.

		     ( SELECT g.genre,
			 m.year,
			 m.title AS movie_name,
			 CASE
			 WHEN substring(m.worlwide_gross_income, 1,3) = 'INR' 
                 THEN round(cast(REPLACE(m.worlwide_gross_income,'INR ','') AS signed)/83.39,2) -- WE WILL USE CURRENT EXCHANGE RATE AS NOT GIVEN IN THE QUESTION.
			 WHEN substring(m.worlwide_gross_income, 1,1) = '$' 
                 THEN cast(REPLACE(m.worlwide_gross_income,'$ ','') AS signed)
			 WHEN m.worlwide_gross_income IS NULL THEN 0
				 end AS worlwide_gross_income
             FROM movie AS m
                 INNER JOIN genre AS g
             ON m.id=g.movie_id
                 WHERE g.genre IN (SELECT genre FROM top_three_genre) 
                 
-- IN THIS SEGEMENT WE WILL CONCAT THE 'GENRE' HAVING SAME MOVIES NAME AND SAME GROSS INCOME TO AVOID DUPLICATE MOVIE NAMES
        
                        ),concating_genre AS
			 (SELECT group_concat(genre,'') AS genre,
                    year,
                    movie_name,
                    worlwide_gross_income
           FROM value_correction
           GROUP BY movie_name,
                    worlwide_gross_income, year
                    
-- IN THIS SEGMENT WE ARE GIVING RANKING TO THE MOVIES BASED ON WORLDWIDE_GROSS_INCOME IN DESCENDING ORDER
                    ), movie_ranking AS
  (
           SELECT genre, year,
				  movie_name,
				  worlwide_gross_income,
				  row_number() over(partition BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
           FROM concating_genre)
 -- IN THE LAST SEGMENT WE ARE SELECTING THE REQUIRED COLUMNS WITH MOVIE RANK LESS THAN AND EQUAL TO 5. ALSO WE WILL BE CONCATINATING THE '$' SIGN AS REQUIRED IN OUTPUT.        
           
  SELECT genre, year,
		 movie_name,
		 concat('$ ', worlwide_gross_income) AS worlwide_gross_income, movie_rank
  FROM movie_ranking
  WHERE movie_rank <=5
  ORDER BY year, movie_rank;




-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

-- THIS CTE CALCULATES THE RANKING OF PRODUCTION COMPANIES BASED ON CERTAIN CRITERIA.
 WITH production_comp_ranking AS(
       SELECT production_company,
 count(m.id) AS movie_count,
	   DENSE_RANK() OVER(ORDER BY count(m.id) DESC) AS prod_comp_rank
 FROM movie AS m
       INNER JOIN ratings AS r
           on m.id=r.movie_id
 WHERE median_rating >=8 AND POSITION(',' IN languages)>0
       AND production_company IS NOT NULL
 GROUP BY production_company
 )
 SELECT * FROM production_comp_ranking  -- SELECTING FROM THE CTE, ONLY THE TOP TWO RANKED PRODUCTION COMPANIES
     WHERE prod_comp_rank <=2;
 
 -- STAR CINEMA AND TWENTIETH CENTURY FOX ARE THE TOP TWO PRODUCTION COMPANIES WHO HAVE PRODUCED THE HIGHEST NUMBER OF HITS AMONG MULTILINGUAL MOVIES


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- CREATE A CTE NAMED "ACTRESS_RANKING" TO CALCULATE VARIOUS METRICS FOR ACTRESSES
WITH actress_ranking AS
  -- SELECTING THE ACTRESS NAME, TOTAL VOTES, MOVIE COUNT, AND AVERAGE RATING FOR EACH ACTRESS
         (SELECT n.NAME AS actress_name,
				Sum(r.total_votes) AS total_votes,
				Count(m.id) AS movie_count,
				Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes),2) AS actress_avg_rating -- CALCULATING THE ACTRESS AVERAGE RATINGS AS WE HAVE ONLY GIVEN MOVIE RATINGS
           FROM movie AS m
           INNER JOIN role_mapping AS rm
                 ON m.id=rm.movie_id
           INNER JOIN genre AS g
                 ON m.id=g.movie_id
           INNER JOIN ratings AS r
                 ON m.id= r.movie_id
           INNER JOIN names AS n
                 ON rm.name_id=n.id
           WHERE r.avg_rating>8
                 AND g.genre LIKE '%drama%'
           AND rm.category= 'actress'
                 GROUP BY actress_name )
                 -- SELECTING THE TOP 3 ACTRESSES BASED ON MOVIE COUNT AND AVERAGE RATING.
                 -- ORDERING WITH AVERAGE RATING ALSO BECAUSE IF TWO ACTRESS HAVE SAME MOVIE COUNT THEN WE CAN CHECK IT WITH THEIR AVERAGE RATING.
SELECT  *,
         Dense_rank() OVER(ORDER BY movie_count DESC, actress_avg_rating DESC) AS actress_rank
         FROM actress_ranking limit 3;
 

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH next_released_date
AS
-- IN THE FIRST SEGEMTN GETTING INFORMATION ABOUT EACH MOVIE, INCLUDING ITS DIRECTOR, RATINGS, AND THE DATE IT WAS PUBLISHED,
-- ALONG WITH THE DATE OF THE NEXT MOVIE PUBLISHED BY THE SAME DIRECTOR.

				   (SELECT d.name_id,
				    n.name ,
					d.movie_id,
					total_votes,
					duration,
					r.avg_rating,
					m.date_published,
					lead(date_published,1) over(partition BY d.name_id ORDER BY date_published) AS next_date_published
             FROM movie AS m
             INNER JOIN director_mapping AS d
             ON m.id=d.movie_id
             INNER JOIN names AS n
             ON n.id= d.name_id
             INNER JOIN ratings AS r
             ON m.id= r.movie_id ),
  date_difference_info
AS
     -- CALCULATING THE DIFFERENCE IN DAYS BETWEEN THE DATE A MOVIE WAS PUBLISHED AND THE DATE OF THE NEXT MOVIE.
     
  ( SELECT *,
			datediff(next_date_published,date_published) AS date_published_difference
         FROM next_released_date )
  -- QUERY TO AGGREGATE INFORMATION ABOUT DIRECTORS AND THEIR MOVIES
  
  SELECT name_id                                 AS director_id,
		 name                                    AS director_name,
		 count(movie_id)                         AS number_of_movies,
		 round(avg(date_published_difference),2) AS avg_inter_movie_days,
		 round(avg(avg_rating),2)                AS avg_rating,
		 sum(total_votes)                        AS total_votes,
		 min(avg_rating)                         AS min_rating,
		 max(avg_rating)                         AS max_rating,
		 sum(duration)                           AS total_duration
  FROM date_difference_info
  GROUP BY director_id,
           director_name
  ORDER BY count(movie_id) DESC    -- ORDERING THE DIRECTORS ON THE BASIS OF TOTAL NUMBER OF MOVIES.

  LIMIT 9;    -- lIMITING THE OUTPUT TO GET TOP 9 DIRECTORS.
























