-- ==========================
-- EXTRA MILE: PRIVATE REVIEWS
-- ==========================


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
