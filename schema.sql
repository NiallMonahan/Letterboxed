-- ==========================
-- DROP TABLES
-- ==========================
DROP TABLE IF EXISTS list_movie;
DROP TABLE IF EXISTS list_tag;
DROP TABLE IF EXISTS `list`;
DROP TABLE IF EXISTS review_like;
DROP TABLE IF EXISTS review_comment;
DROP TABLE IF EXISTS review_tag;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS watchlist_movie;
DROP TABLE IF EXISTS watchlist;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS follow;
DROP TABLE IF EXISTS users;

-- ==========================
-- USERS
-- ==========================
CREATE TABLE users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    join_date DATE NOT NULL,
    bio TEXT,
    is_premium BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB;

-- ==========================
-- FOLLOWERS
-- ==========================
CREATE TABLE follow (
    follower_id INT UNSIGNED NOT NULL,
    followed_id INT UNSIGNED NOT NULL,
    PRIMARY KEY(follower_id, followed_id),
    FOREIGN KEY(follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(followed_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- REVIEWS
-- ==========================
-- EXTRA MILE: Added is_private column to allow users to keep reviews private.
-- Many users want to log or review films privately without sharing publicly.
-- This feature is not currently offered by Letterboxd.
CREATE TABLE reviews (
    review_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    movie_id BIGINT UNSIGNED NOT NULL,
    rating TINYINT,
    liked BOOLEAN DEFAULT FALSE,
    review_text TEXT,
    is_private BOOLEAN DEFAULT FALSE,  -- FALSE = public, TRUE = private (only visible to owner)
    logged_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(movie_id) REFERENCES movie(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- WATCHLIST
-- ==========================
CREATE TABLE watchlist (
    watchlist_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- WATCHLIST_MOVIE
-- ==========================
CREATE TABLE watchlist_movie (
    watchlist_id INT UNSIGNED NOT NULL,
    movie_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY(watchlist_id, movie_id),
    FOREIGN KEY(watchlist_id) REFERENCES watchlist(watchlist_id) ON DELETE CASCADE,
    FOREIGN KEY(movie_id) REFERENCES movie(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- TAGS
-- ==========================
CREATE TABLE tags (
    tag_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(50) UNIQUE NOT NULL
) ENGINE=InnoDB;

-- ==========================
-- REVIEW_TAG
-- ==========================
CREATE TABLE review_tag (
    review_id INT UNSIGNED NOT NULL,
    tag_id INT UNSIGNED NOT NULL,
    PRIMARY KEY(review_id, tag_id),
    FOREIGN KEY(review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    FOREIGN KEY(tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- REVIEW_COMMENT
-- ==========================
CREATE TABLE review_comment (
    comment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    review_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    comment_text TEXT,
    logged_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- REVIEW_LIKE
-- ==========================
CREATE TABLE review_like (
    user_id INT UNSIGNED NOT NULL,
    review_id INT UNSIGNED NOT NULL,
    PRIMARY KEY(user_id, review_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(review_id) REFERENCES reviews(review_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- LISTS
-- ==========================
CREATE TABLE `list` (
    list_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    title VARCHAR(255),
    description TEXT,
    is_public BOOLEAN DEFAULT TRUE,
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- LIST_TAG
-- ==========================
CREATE TABLE list_tag (
    list_id INT UNSIGNED NOT NULL,
    tag_id INT UNSIGNED NOT NULL,
    PRIMARY KEY(list_id, tag_id),
    FOREIGN KEY(list_id) REFERENCES `list`(list_id) ON DELETE CASCADE,
    FOREIGN KEY(tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==========================
-- LIST_MOVIE
-- ==========================
CREATE TABLE list_movie (
    list_id INT UNSIGNED NOT NULL,
    movie_id BIGINT UNSIGNED NOT NULL,
    sort_order INT,
    PRIMARY KEY(list_id, movie_id),
    FOREIGN KEY(list_id) REFERENCES `list`(list_id) ON DELETE CASCADE,
    FOREIGN KEY(movie_id) REFERENCES movie(id) ON DELETE CASCADE
) ENGINE=InnoDB;
