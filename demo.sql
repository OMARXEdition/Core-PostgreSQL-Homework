\echo 'CRUD: create, read, update, delete'
BEGIN;
INSERT INTO students (full_name, email) VALUES ('Demo Student', 'demo@example.edu');
SELECT student_id, full_name, email FROM students WHERE email = 'demo@example.edu';
UPDATE students SET full_name = 'Updated Student' WHERE email = 'demo@example.edu';
SELECT full_name FROM students WHERE email = 'demo@example.edu';
DELETE FROM students WHERE email = 'demo@example.edu';
COMMIT;
SELECT count(*) AS demo_students_remaining FROM students WHERE email = 'demo@example.edu';

\echo 'JOIN: students enrolled in DB201'
SELECT s.full_name, c.course_code, e.enrolled_at
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses c ON c.course_id = e.course_id
WHERE c.course_code = 'DB201'
ORDER BY s.full_name;

\echo 'GROUP BY: enrollment count per course, including empty courses'
SELECT c.course_code, count(e.student_id) AS student_count
FROM courses c LEFT JOIN enrollments e ON e.course_id = c.course_id
GROUP BY c.course_id, c.course_code
ORDER BY c.course_code;

\echo 'Pagination: second page of two students, stable order'
SELECT student_id, full_name FROM students ORDER BY student_id LIMIT 2 OFFSET 2;

\echo 'Transaction: COMMIT an enrollment'
BEGIN;
INSERT INTO enrollments (student_id, course_id, enrolled_at) VALUES (8, 2, '2026-09-11');
COMMIT;
SELECT count(*) AS committed_rows FROM enrollments WHERE student_id = 8 AND course_id = 2;

\echo 'Transaction: ROLLBACK an enrollment'
BEGIN;
INSERT INTO enrollments (student_id, course_id, enrolled_at) VALUES (8, 3, '2026-09-11');
ROLLBACK;
SELECT count(*) AS rolled_back_rows FROM enrollments WHERE student_id = 8 AND course_id = 3;

\echo 'Index evaluation: same query before and after indexing'
BEGIN;
INSERT INTO students (student_id, full_name, email)
SELECT n, 'Benchmark Student ' || n, 'bench' || n || '@example.edu'
FROM generate_series(1000, 20999) AS n;
INSERT INTO enrollments (student_id, course_id, enrolled_at)
SELECT n, 1 + n % 4, DATE '2026-01-01' + (n % 180)
FROM generate_series(1000, 20999) AS n;
ANALYZE enrollments;
\echo 'Before index'
EXPLAIN (ANALYZE, BUFFERS)
SELECT student_id, enrolled_at FROM enrollments
WHERE course_id = 2 ORDER BY enrolled_at DESC, student_id DESC LIMIT 20;
CREATE INDEX enrollments_course_roster_idx
ON enrollments (course_id, enrolled_at DESC, student_id DESC);
ANALYZE enrollments;
\echo 'After index'
EXPLAIN (ANALYZE, BUFFERS)
SELECT student_id, enrolled_at FROM enrollments
WHERE course_id = 2 ORDER BY enrolled_at DESC, student_id DESC LIMIT 20;
DELETE FROM students WHERE student_id BETWEEN 1000 AND 20999;
COMMIT;
ANALYZE enrollments;

\echo 'Final verification'
SELECT (SELECT count(*) FROM students) AS students,
       (SELECT count(*) FROM courses) AS courses,
       (SELECT count(*) FROM enrollments) AS enrollments;
SELECT indexname FROM pg_indexes WHERE tablename = 'enrollments'
ORDER BY indexname;
