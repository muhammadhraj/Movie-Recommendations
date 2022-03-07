CREATE TABLE users(userid INTEGER PRIMARY KEY, name TEXT);

CREATE TABLE movies(movieid INTEGER PRIMARY KEY, title TEXT);

CREATE TABLE taginfo(tagid INTEGER PRIMARY KEY, content TEXT);

CREATE TABLE genres(genreid INTEGER PRIMARY KEY, name TEXT);

CREATE TABLE ratings(userid INTEGER REFERENCES users(userid), movieid INTEGER REFERENCES movies(movieid), rating NUMERIC CHECK(rating>=0 AND rating<=5), timestamp BIGINT, PRIMARY KEY(userid, movieid));

CREATE TABLE tags(userid INTEGER REFERENCES users(userid), movieid INTEGER REFERENCES movies(movieid), tagid INTEGER REFERENCES taginfo(tagid), timestamp BIGINT);

CREATE TABLE hasagenre(movieid INTEGER REFERENCES movies(movieid), genreid INTEGER REFERENCES genres(genreid));