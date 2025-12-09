
-- ============================================
-- USERS
-- ============================================

-- Q1: Create a new user account
INSERT INTO users (username, email, password_hash, join_date, bio, is_premium)
VALUES ('newuser123', 'newuser123@example.com', 'some_hash_here', CURDATE(), 'New to the platform!', FALSE);

-- Q2: Get user profile by user_id, including follower and following counts
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.join_date,
    u.bio,
    u.is_premium,
    -- number of people this user follows
    (SELECT COUNT(*) FROM follow f WHERE f.follower_id = u.user_id) AS following_count,
    -- number of people who follow this user
    (SELECT COUNT(*) FROM follow f WHERE f.followed_id = u.user_id) AS follower_count
FROM users u
WHERE u.user_id = 1;

-- Q3: Update a user profile
UPDATE users
SET bio = 'Updated bio for this user.',
    is_premium = TRUE
WHERE user_id = 1;


-- ============================================
-- REVIEWS / LOGs
-- (in this schema, a review row IS the log)
-- ============================================

-- Q4: Create a new review/log entry for a movie
INSERT INTO reviews (user_id, movie_id, rating, liked, review_text)
VALUES (1, 2, 5, TRUE, 'Rewatching this and it still holds up.');

-- Q5: Get all reviews for a given movie with username and when logged
SELECT 
    r.review_id,
    u.username,
    r.rating,
    r.liked,
    r.review_text,
    r.logged_at
FROM reviews r
JOIN users u ON r.user_id = u.user_id
WHERE r.movie_id = 2
ORDER BY r.logged_at DESC;


-- TRIGGER: When a user reviews a movie, remove that movie from their watchlist

DROP TRIGGER IF EXISTS trg_remove_from_watchlist_on_review;
DELIMITER $$
CREATE TRIGGER trg_remove_from_watchlist_on_review
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    -- Find the users watchlist and remove the movie if it exists there
    DELETE wm
    FROM watchlist_movie wm
    JOIN watchlist w ON wm.watchlist_id = w.watchlist_id
    WHERE w.user_id = NEW.user_id
      AND wm.movie_id = NEW.movie_id;
END$$
DELIMITER ;


-- ============================================
-- SEARCH FUNCTIONALITY
-- ============================================

-- Q6: Search for movies by title 
SELECT 
    m.id AS movie_id,
    m.title,
    m.release_date,
    m.overview
FROM movie m
WHERE LOWER(m.title) LIKE CONCAT('%', LOWER('star'), '%')
ORDER BY m.release_date DESC;

-- Q7: Search for people (actors/crew) by name
SELECT 
    p.id AS person_id,
    p.name,
    p.birthday,
    p.place_of_birth
FROM person p
WHERE LOWER(p.name) LIKE CONCAT('%', LOWER('tom'), '%')
ORDER BY p.name;

-- Indexes to optimize search queries
CREATE INDEX idx_movie_title ON movie(title);
CREATE INDEX idx_person_name ON person(name);


-- ============================================
-- SOCIAL FEATURES
-- ============================================

-- Q8: Follow another user
INSERT INTO follow (follower_id, followed_id)
VALUES (1, 3); -- user 1 follows user 3

-- Q9: Unfollow a user
DELETE FROM follow
WHERE follower_id = 1 AND followed_id = 3;

-- Q10: Get the list of followers for a given user
SELECT 
    f.follower_id,
    u.username
FROM follow f
JOIN users u ON f.follower_id = u.user_id
WHERE f.followed_id = 1;

-- Q11: Get the list of users someone is following
SELECT 
    f.followed_id,
    u.username
FROM follow f
JOIN users u ON f.followed_id = u.user_id
WHERE f.follower_id = 1;

-- Q12: "Activity feed" - recent reviews from users that a given user follows
SELECT 
    r.review_id,
    u.username AS author,
    m.title AS movie_title,
    r.rating,
    r.review_text,
    r.logged_at
FROM follow f
JOIN reviews r ON r.user_id = f.followed_id
JOIN users u ON u.user_id = r.user_id
JOIN movie m ON m.id = r.movie_id
WHERE f.follower_id = 1
ORDER BY r.logged_at DESC
LIMIT 20;


-- ============================================
-- LIST MANAGEMENT
-- ============================================

-- Q13: Create a new list for a user
INSERT INTO `list` (user_id, title, description, is_public)
VALUES (1, 'Sci-Fi Favourites', 'My favourite sci-fi movies', TRUE);

-- Q14: Add a movie to a list
INSERT INTO list_movie (list_id, movie_id, sort_order)
VALUES (1, 42, 3); -- assumes movie id 42 exists

-- Q15: Remove a movie from a list
DELETE FROM list_movie
WHERE list_id = 1 AND movie_id = 42;

-- Q16: Get a user’s watchlist with movie details
SELECT 
    w.watchlist_id,
    m.id AS movie_id,
    m.title,
    m.release_date,
    m.overview
FROM watchlist w
JOIN watchlist_movie wm ON w.watchlist_id = wm.watchlist_id
JOIN movie m ON wm.movie_id = m.id
WHERE w.user_id = 1
ORDER BY m.release_date DESC;


-- ============================================
-- MOVIE STATISTICS
-- ============================================

-- Q17: Get the average rating and number of reviews for a given film
SELECT 
    m.id AS movie_id,
    m.title,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM movie m
LEFT JOIN reviews r ON r.movie_id = m.id
WHERE m.id = 2
GROUP BY m.id, m.title;

-- Q18: Top 10 movies by average rating (with at least 3 reviews)
SELECT 
    m.id AS movie_id,
    m.title,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM movie m
JOIN reviews r ON r.movie_id = m.id
GROUP BY m.id, m.title
HAVING COUNT(r.review_id) >= 3
ORDER BY avg_rating DESC
LIMIT 10;


-- ============================================
-- VIEWS & STORED PROCEDURES (Part 2 extras)
-- ============================================

-- VIEW 1: User profile summary with follower/following counts
CREATE OR REPLACE VIEW v_user_profile_summary AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.join_date,
    u.is_premium,
    (SELECT COUNT(*) FROM follow f WHERE f.follower_id = u.user_id) AS following_count,
    (SELECT COUNT(*) FROM follow f WHERE f.followed_id = u.user_id) AS follower_count
FROM users u;

-- VIEW 2: Movie ratings summary
CREATE OR REPLACE VIEW v_movie_ratings AS
SELECT 
    m.id AS movie_id,
    m.title,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM movie m
LEFT JOIN reviews r ON r.movie_id = m.id
GROUP BY m.id, m.title;


-- STORED PROCEDURE: Follow a user (with simple duplicate check)
DROP PROCEDURE IF EXISTS sp_follow_user;
DELIMITER $$
CREATE PROCEDURE sp_follow_user(IN p_follower_id INT, IN p_followed_id INT)
BEGIN
    -- Avoid following yourself or duplicating follows
    IF p_follower_id = p_followed_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A user cannot follow themselves.';
    ELSEIF EXISTS (
        SELECT 1 FROM follow 
        WHERE follower_id = p_follower_id AND followed_id = p_followed_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Follow relationship already exists.';
    ELSE
        INSERT INTO follow (follower_id, followed_id)
        VALUES (p_follower_id, p_followed_id);
    END IF;
END$$
DELIMITER ;




