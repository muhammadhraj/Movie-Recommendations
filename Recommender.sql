DROP TABLE IF EXISTS query1;
DROP TABLE IF EXISTS query2;
DROP TABLE IF EXISTS query3;
DROP TABLE IF EXISTS query4;
DROP TABLE IF EXISTS query5;
DROP TABLE IF EXISTS query6;
DROP TABLE IF EXISTS query7;
DROP TABLE IF EXISTS query8;
DROP TABLE IF EXISTS query9;
DROP TABLE IF EXISTS avgratings;
DROP TABLE IF EXISTS averages;
DROP TABLE IF EXISTS similarities;
DROP INDEX simindex;
DROP TABLE IF EXISTS unratedmovies;
DROP TABLE IF EXISTS preds1;
DROP TABLE IF EXISTS preds2;
DROP TABLE IF EXISTS sums;
DROP TABLE IF EXISTS preds3;
DROP TABLE IF EXISTS recommendation;

CREATE TABLE query1 AS (SELECT genres.name, COUNT(hasagenre.movieid) AS moviecount FROM genres INNER JOIN hasagenre USING(genreid) GROUP BY genres.name);

CREATE TABLE query2 AS (SELECT genres.name, AVG(ratings.rating) AS rating FROM genres INNER JOIN hasagenre USING(genreid) INNER JOIN ratings USING(movieid) GROUP BY genres.name);

CREATE TABLE query3 AS (SELECT movies.title, COUNT(ratings.movieid) AS CountOfRatings FROM movies INNER JOIN ratings USING(movieid) GROUP BY movies.title HAVING COUNT(ratings.movieid)>=10);

CREATE TABLE query4 AS (SELECT movies.movieid, movies.title FROM movies INNER JOIN hasagenre USING(movieid) INNER JOIN genres USING(genreid) WHERE genres.name='Comedy');

CREATE TABLE query5 AS (SELECT movies.title, AVG(ratings.rating) AS average FROM movies INNER JOIN ratings USING(movieid) GROUP BY movies.title);

CREATE TABLE query6 AS (SELECT AVG(ratings.rating) AS average FROM ratings INNER JOIN hasagenre USING(movieid) INNER JOIN genres USING(genreid) WHERE genres.name='Comedy');

CREATE TABLE query7 AS (SELECT AVG(ratings.rating) AS average FROM ratings WHERE ratings.movieid IN (SELECT movieid FROM genres INNER JOIN hasagenre USING(genreid) WHERE genres.name='Comedy' OR genres.name='Romance' GROUP BY movieid HAVING COUNT(movieid)>1));

CREATE TABLE query8 AS (SELECT AVG(ratings.rating) AS average FROM ratings INNER JOIN hasagenre USING(movieid) INNER JOIN genres USING(genreid) WHERE genres.name='Romance' AND hasagenre.movieid NOT IN (SELECT movieid FROM hasagenre INNER JOIN genres USING(genreid) WHERE genres.name='Comedy' GROUP BY movieid HAVING COUNT(movieid)>=1));

CREATE TABLE query9 AS (SELECT movieid, rating FROM ratings WHERE userid=:v1);

CREATE TABLE avgratings AS (SELECT movieid, title, average FROM movies INNER JOIN query5 USING (title));

CREATE TABLE averages AS (SELECT * FROM avgratings ORDER BY movieid);

CREATE TABLE similarities AS (SELECT m1.movieid AS movieid1, m2.movieid AS movieid2, 1-(ABS(m1.average-m2.average)/5) AS sim FROM averages AS m1 CROSS JOIN (SELECT * FROM query9 INNER JOIN averages USING (movieid)) AS m2 WHERE m1.movieid!=m2.movieid);

CREATE INDEX simindex ON similarities (movieid1, movieid2);

CREATE TABLE unratedmovies AS (SELECT * FROM movies WHERE movieid NOT IN (SELECT movieid FROM query9));

CREATE TABLE preds1 AS (SELECT unratedmovies.movieid AS unratedid, title, ratedmovies.movieid AS ratedid, rating FROM unratedmovies CROSS JOIN query9 AS ratedmovies);

CREATE TABLE preds2 AS (SELECT unratedid, title, ratedid, rating, (SELECT sim FROM similarities WHERE movieid1=unratedid AND movieid2=ratedid) AS sim FROM preds1);

CREATE TABLE sums AS (SELECT unratedid, SUM(sim*rating) AS numerator, SUM(sim) AS denominator FROM preds2 GROUP BY unratedid);

CREATE TABLE preds3 AS (SELECT movieid, title, numerator/denominator AS prediction FROM movies INNER JOIN sums ON movieid=unratedid);

CREATE TABLE recommendation AS (SELECT DISTINCT title FROM preds3 WHERE prediction>3.9);