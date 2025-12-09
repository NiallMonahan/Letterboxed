
-- This section will show all of the queries for part 2 of the project.

-- 1. USERS

-- 1a: Create a new user account (unique username/email)
INSERT INTO users (username, email, password_hash, join_date, bio, is_premium)
VALUES ('newuser_letterbox', 'newuser_letterbox@example.com', 'hash_pw_011', CURRENT_DATE, 'Excited to review movies!', FALSE);

-- 1b: Get user profile information by user_id, including follower/following counts
SELECT u.user_id, u.username, u.email, u.bio, u.join_date, u.is_premium,
       (SELECT COUNT(*) FROM follow WHERE followed_id = u.user_id) AS followers_count,
       (SELECT COUNT(*) FROM follow WHERE follower_id = u.user_id) AS following_count
FROM users u
WHERE u.user_id = 1;

-- 1c: Update a user profile
UPDATE users
SET bio = 'Updated bio here', is_premium = TRUE
WHERE user_id = 1;

-- 2. REVIEWS AND LOGS

-- 2a: Insert a new movie log (review) safely
INSERT INTO reviews (user_id, movie_id, rating, liked, review_text)
SELECT 1, 2, 5, TRUE, 'Just watched, absolutely loved it!'
WHERE NOT EXISTS (
    SELECT 1 FROM reviews WHERE user_id = 1 AND movie_id = 2
);

-- 2b: Trigger to remove movie from watchlist automatically when logged
DROP TRIGGER IF EXISTS remove_from_watchlist_after_review;

DELIMITER //
CREATE TRIGGER remove_from_watchlist_after_review
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    DELETE FROM watchlist_movie
    WHERE watchlist_id IN (SELECT watchlist_id FROM watchlist WHERE user_id = NEW.user_id)
      AND movie_id = NEW.movie_id;
END;
//
DELIMITER ;

-- 3. SEARCH FUNCTIONALITY

-- 3a: Search for movies by partial title
SELECT *
FROM movie
WHERE title LIKE '%dark%';

-- 3b: Search for movies by partial overview text
SELECT *
FROM movie
WHERE overview LIKE '%adventure%';

-- 3c: Search for crew members by department or job
SELECT *
FROM crew
WHERE department LIKE '%Directing%'
   OR job LIKE '%Director%';

-- 3d: Search for movies by crew involvement
SELECT m.id AS movie_id, m.title, m.release_date, m.runtime
FROM movie m
JOIN crew c ON m.id = c.movie_id
WHERE c.person_id = 17825;

-- 4. SOCIAL FEATURES

-- 4a: Follow another user safely
INSERT INTO follow (follower_id, followed_id)
SELECT 1, 5
WHERE NOT EXISTS (
    SELECT 1 FROM follow WHERE follower_id = 1 AND followed_id = 5
);

-- 4b: Get movie logging activity from users a given user follows (latest reviews from people who follow 1)
SELECT r.review_id, r.user_id, r.movie_id, r.rating, r.liked, r.review_text, r.logged_at
FROM reviews r
JOIN follow f ON r.user_id = f.followed_id
WHERE f.follower_id = 1
ORDER BY r.logged_at DESC;

-- 5. LIST MANAGEMENT

-- 5a: Create a new list safely
INSERT INTO list (user_id, title, description, is_public)
SELECT 1, 'Sci-Fi Favorites', 'My favorite sci-fi movies', TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM list WHERE user_id = 1 AND title = 'Sci-Fi Favorites'
);

-- 5b: Add a movie to a user list safely
INSERT INTO list_movie (list_id, movie_id, sort_order)
SELECT 1, 2, 1
WHERE NOT EXISTS (
    SELECT 1 FROM list_movie WHERE list_id = 1 AND movie_id = 2
);

-- 5c: Get a user’s watchlist with movie details
SELECT w.watchlist_id, m.id AS movie_id, m.title, m.release_date, m.runtime
FROM watchlist w
JOIN watchlist_movie wm ON w.watchlist_id = wm.watchlist_id
JOIN movie m ON wm.movie_id = m.id
WHERE w.user_id = 1;

-- 6. MOVIE STATISTICS

-- 6a: Average rating for a given film
SELECT AVG(rating) AS avg_rating
FROM reviews
WHERE movie_id = 2;

-- 6b: Summary statistics about a film
SELECT m.title,
       COUNT(DISTINCT r.review_id) AS total_watches,
       SUM(r.liked) AS total_likes,
       (SELECT COUNT(*) FROM list_movie WHERE movie_id = m.id) AS lists_count
FROM movie m
LEFT JOIN reviews r ON m.id = r.movie_id
WHERE m.id = 2
GROUP BY m.title;

-- 7. VIEWS (Optional Convenience)

-- View for simplified user profiles
CREATE OR REPLACE VIEW user_profile AS
SELECT u.user_id, u.username, u.email, u.bio, u.join_date, u.is_premium,
       (SELECT COUNT(*) FROM follow WHERE followed_id = u.user_id) AS followers_count,
       (SELECT COUNT(*) FROM follow WHERE follower_id = u.user_id) AS following_count
FROM users u;

-- Part 3 - Creating indexes for query optimization

-- An index on the title column for search 
CREATE INDEX idx_movie_title ON movie(title);

-- An index on the release_date column, if you want to filter by release date
CREATE INDEX idx_movie_release ON movie(release_date);

-- Part 5 - Security & Privacy (User-based instead of roles)

-- Data Analyst: Read-only access

-- I was having issues with creating roles, so I had to make sure they didn't already exist (they didn't) in order to make them, really strange bug.

DROP USER IF EXISTS 'data_analyst'@'localhost';
CREATE USER 'data_analyst'@'localhost' IDENTIFIED BY 'securepassword';
GRANT SELECT ON letterboxdb.* TO 'data_analyst'@'localhost';

-- Content Manager: Can modify movies, cast, crew, tags, lists
DROP USER IF EXISTS 'content_manager'@'localhost';
CREATE USER 'content_manager'@'localhost' IDENTIFIED BY 'securepassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON movie TO 'content_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON cast TO 'content_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON crew TO 'content_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON genre TO 'content_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON movie_genre TO 'content_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON tags TO 'content_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON list TO 'content_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON list_movie TO 'content_manager'@'localhost';

-- Admin: Full privileges
DROP USER IF EXISTS 'admin'@'localhost';
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'securepassword';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;


-- Prepared statement to avoid SQL injection, this example is for a movie title search function. 

$stmt = $pdo->prepare("
    SELECT * 
    FROM movie 
    WHERE title LIKE CONCAT('%', ?, '%')
");
$stmt->execute([$search]);

-- We also wrote an example transaction for when the user requests for all of their data to be deleted, according to GDPR guidelines. 

START TRANSACTION;

-- Delete user’s review likes
DELETE rl
FROM review_like rl
JOIN reviews r ON rl.review_id = r.review_id
WHERE r.user_id = 123;

-- Delete user’s review comments
DELETE rc
FROM review_comment rc
JOIN reviews r ON rc.review_id = r.review_id
WHERE r.user_id = 123;

-- Delete user's review tags
DELETE rt
FROM review_tag rt
JOIN reviews r ON rt.review_id = r.review_id
WHERE r.user_id = 123;

-- Delete user’s reviews
DELETE FROM reviews WHERE user_id = 123;

-- Delete follow relationships (both directions)
DELETE FROM follow WHERE follower_id = 123 OR followed_id = 123;

-- Delete list movies
DELETE lm
FROM list_movie lm
JOIN list l ON lm.list_id = l.list_id
WHERE l.user_id = 123;

-- Delete lists
DELETE FROM list WHERE user_id = 123;

-- Delete watchlist movies
DELETE wm
FROM watchlist_movie wm
JOIN watchlist w ON wm.watchlist_id = w.watchlist_id
WHERE w.user_id = 123;

-- Delete watchlist
DELETE FROM watchlist WHERE user_id = 123;

-- Finally delete the user
DELETE FROM users WHERE user_id = 123;

COMMIT;



-- EXTRA MILE: PRIVATE REVIEWS

-- BEFORE: Original feed query (shows all reviews)
-- AFTER: Modified feed query (excludes private reviews)
SELECT r.review_id, r.user_id, r.movie_id, r.rating, r.liked, r.review_text, r.logged_at
FROM reviews r
JOIN follow f ON r.user_id = f.followed_id
WHERE f.follower_id = 1
  AND r.is_private = FALSE         -- NEW: Filter out private reviews from public feed
ORDER BY r.logged_at DESC;


-- Mark a review as private (only visible to the review owner)
UPDATE reviews
SET is_private = TRUE
WHERE review_id = 3;

-- Attempt to view review_id 3 in the feed (should not appear if private)
SELECT r.review_id, r.user_id, r.movie_id, r.rating, r.liked, r.review_text, r.logged_at, r.is_private
FROM reviews r
WHERE r.review_id = 3;

-- View another review (review_id 4) that is still public
SELECT r.review_id, r.user_id, r.movie_id, r.rating, r.liked, r.review_text, r.logged_at, r.is_private
FROM reviews r
WHERE r.review_id = 4;

