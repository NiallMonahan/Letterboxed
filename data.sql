-- This section will show all of the insert statements for the sample data. 

-- USERS
INSERT INTO users (username, email, password_hash, join_date, bio, is_premium) VALUES
('moviebuff01', 'moviebuff01@example.com', 'hash_pw_001', '2023-05-14', 'I watch everything from classics to indie films.', FALSE),
('cinemalover', 'cinemalover@example.com', 'hash_pw_002', '2022-11-23', 'Popcorn in hand, always ready for a new release.', TRUE),
('streamqueen', 'streamqueen@example.com', 'hash_pw_003', '2024-01-08', 'Binge-watching is my cardio.', FALSE),
('filmguru', 'filmguru@example.com', 'hash_pw_004', '2023-08-30', 'I write reviews and give 5-star ratings liberally.', TRUE),
('hollywoodfan', 'hollywoodfan@example.com', 'hash_pw_005', '2022-09-19', 'Big fan of blockbuster hits.', FALSE),
('cinemagic', 'cinemagic@example.com', 'hash_pw_006', '2023-03-05', 'Movies are my escape from reality.', TRUE),
('popcornlover', 'popcornlover@example.com', 'hash_pw_007', '2024-06-12', 'I never watch a movie without snacks.', FALSE),
('screenaddict', 'screenaddict@example.com', 'hash_pw_008', '2023-12-01', 'My life revolves around the big screen.', TRUE),
('reelenthusiast', 'reelenthusiast@example.com', 'hash_pw_009', '2022-07-22', 'Always looking for hidden cinematic gems.', FALSE),
('filmfanatic', 'filmfanatic@example.com', 'hash_pw_010', '2024-04-17', 'Cinephile and amateur film critic.', TRUE);

-- FOLLOW (unique pairs only)
INSERT INTO follow (follower_id, followed_id) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 1),
(6, 1),
(7, 3),
(8, 10),
(9, 4),
(10, 2);

-- REVIEWS
INSERT INTO reviews (user_id, movie_id, rating, liked, review_text) VALUES
(1, 2, 5, TRUE, 'Amazing movie.'),
(2, 3, 4, TRUE, 'Great visuals.'),
(3, 5, 5, TRUE, 'Mind-blowing.'),
(4, 6, 5, TRUE, 'Iconic performance.'),
(5, 11, 3, FALSE, 'Interesting but slow.'),
(6, 12, 4, TRUE, 'Really good.'),
(7, 13, 2, FALSE, 'Not for me.'),
(8, 14, 5, TRUE, 'Loved it.'),
(9, 16, 5, TRUE, 'Masterpiece.'),
(10, 17, 4, TRUE, 'Very solid.');

-- REVIEW_TAG
INSERT INTO review_tag (review_id, tag_id) VALUES
(11, 1),
(11, 3),
(12, 2),
(13, 3),
(14, 4),
(15, 1),
(15, 3);

-- REVIEW_COMMENT
INSERT INTO review_comment (review_id, user_id, comment_text) VALUES
(11, 2, 'I totally agree!'),
(11, 3, 'One of my favorites too!'),
(12, 1, 'I had a different opinion.'),
(13, 5, 'Yes, it was great!');

-- REVIEW_LIKE
INSERT INTO review_like (user_id, review_id) VALUES
(2, 11),
(3, 11),
(1, 12),
(5, 13),
(4, 15);

-- WATCHLIST
INSERT INTO watchlist (user_id) VALUES
(1),
(2),
(3),
(4),
(5);

-- WATCHLIST_MOVIE
INSERT INTO watchlist_movie (watchlist_id, movie_id) VALUES
(1, 2),
(1, 3),
(2, 5),
(2, 6),
(3, 11),
(3, 12),
(4, 13),
(5, 14);

-- TAGS
INSERT INTO tags (tag_name) VALUES
('Action'),
('Comedy'),
('Drama'),
('Horror'),
('Romance');

-- LISTS
INSERT INTO list (user_id, title, description, is_public) VALUES
(1, 'My Top 5', 'My favorite movies of all time', TRUE),
(2, 'Comedy Nights', 'Best comedy films', TRUE),
(3, 'Horror Collection', 'Scary movies only', FALSE);

-- LIST_TAG
INSERT INTO list_tag (list_id, tag_id) VALUES
(1, 1),
(1, 3),
(2, 2),
(3, 4);

-- LIST_MOVIE
INSERT INTO list_movie (list_id, movie_id, sort_order) VALUES
(1, 2, 1),
(1, 11, 2),
(2, 3, 1),
(2, 5, 2),
(3, 13, 1),
(3, 14, 2);
