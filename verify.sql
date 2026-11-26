-- Run after demo.sql. Raises an error if a required result is wrong.
DO $$
BEGIN
    IF (SELECT count(*) FROM students) <> 8
       OR (SELECT count(*) FROM courses) <> 4
       OR (SELECT count(*) FROM enrollments) <> 13 THEN
        RAISE EXCEPTION 'Unexpected final row counts';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_id = 8 AND course_id = 2)
       OR EXISTS (SELECT 1 FROM enrollments WHERE student_id = 8 AND course_id = 3) THEN
        RAISE EXCEPTION 'COMMIT or ROLLBACK result was incorrect';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes
                   WHERE tablename = 'enrollments'
                     AND indexname = 'enrollments_course_roster_idx') THEN
        RAISE EXCEPTION 'Roster index is missing';
    END IF;

    BEGIN
        INSERT INTO students (full_name, email) VALUES ('Duplicate', 'aylin@example.edu');
        RAISE EXCEPTION 'Duplicate email was accepted';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO courses (course_code, title, capacity) VALUES ('BAD', 'Bad course', 0);
        RAISE EXCEPTION 'Zero capacity was accepted';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO enrollments (student_id, course_id) VALUES (999999, 1);
        RAISE EXCEPTION 'Missing student was accepted';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO enrollments (student_id, course_id) VALUES (1, 1);
        RAISE EXCEPTION 'Duplicate enrollment was accepted';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
END $$;
SELECT 'All result and constraint checks passed' AS verification;
