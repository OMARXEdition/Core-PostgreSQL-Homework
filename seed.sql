INSERT INTO students (student_id, full_name, email) VALUES
 (1, 'Aylin Demir', 'aylin@example.edu'),
 (2, 'Mert Kaya', 'mert@example.edu'),
 (3, 'Zeynep Arslan', 'zeynep@example.edu'),
 (4, 'Can Yilmaz', 'can@example.edu'),
 (5, 'Elif Sahin', 'elif@example.edu'),
 (6, 'Deniz Acar', 'deniz@example.edu'),
 (7, 'Ece Polat', 'ece@example.edu'),
 (8, 'Kerem Celik', 'kerem@example.edu');

INSERT INTO courses (course_id, course_code, title, capacity) VALUES
 (1, 'CS101', 'Introduction to Programming', 30),
 (2, 'DB201', 'Database Systems', 25),
 (3, 'MATH110', 'Calculus I', 35),
 (4, 'STAT210', 'Statistics', 20);

INSERT INTO enrollments (student_id, course_id, enrolled_at) VALUES
 (1, 1, '2026-09-01'), (1, 2, '2026-09-03'),
 (2, 1, '2026-09-02'), (2, 3, '2026-09-04'),
 (3, 2, '2026-09-03'), (3, 4, '2026-09-05'),
 (4, 1, '2026-09-06'), (4, 2, '2026-09-07'),
 (5, 3, '2026-09-02'), (6, 2, '2026-09-08'),
 (7, 4, '2026-09-09'), (8, 1, '2026-09-10');

SELECT setval(pg_get_serial_sequence('students', 'student_id'), 8);
SELECT setval(pg_get_serial_sequence('courses', 'course_id'), 4);
