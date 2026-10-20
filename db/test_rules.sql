-- Runs the requirement test scripts for the three business rules.
-- Each block expects an error; it prints PASS when the database rejects the bad data.
\set ON_ERROR_STOP off

\echo '--- REQ01: overlapping session in the same room (expect rejection)'
INSERT INTO session (room_id, proctor_id, session_date, start_time, end_time)
VALUES (1, '2000000003', CURRENT_DATE + 14, '10:30', '11:30');

\echo '--- REQ01: back-to-back session in the same room (expect success)'
INSERT INTO session (room_id, proctor_id, session_date, start_time, end_time)
VALUES (1, '2000000003', CURRENT_DATE + 14, '11:00', '12:00') RETURNING session_id, capacity AS default_capacity;

\echo '--- REQ23: first registration (expect success)'
INSERT INTO registration (student_id, session_id, exam_id) VALUES ('1000000001', 1, 3);
\echo '--- REQ23: same student, same exam, different session (expect rejection)'
INSERT INTO registration (student_id, session_id, exam_id) VALUES ('1000000001', 2, 3);

\echo '--- REQ02: fill the 2-seat session (expect two successes, then rejection)'
INSERT INTO registration (student_id, session_id, exam_id) VALUES ('1000000001', 3, 1);
INSERT INTO registration (student_id, session_id, exam_id) VALUES ('1000000002', 3, 1);
INSERT INTO registration (student_id, session_id, exam_id) VALUES ('1000000003', 3, 1);
\echo '--- REQ02: full session is hidden from the open list (expect no row for session 3)'
SELECT session_id, exam_name, seats_left FROM open_session_exam ORDER BY session_id, exam_id;

\echo '--- REQ22: cancel a seat, then the third student can register (expect success)'
UPDATE registration SET status = 'Cancelled', cancelled_at = now()
 WHERE student_id = '1000000002' AND session_id = 3;
INSERT INTO registration (student_id, session_id, exam_id) VALUES ('1000000003', 3, 1);

\echo '--- Registration for an exam the session does not offer (expect rejection)'
INSERT INTO registration (student_id, session_id, exam_id) VALUES ('1000000002', 2, 1);

\echo '--- REQ25: end-of-semester wipe'
SELECT end_of_semester_wipe();
SELECT (SELECT count(*) FROM student) AS students, (SELECT count(*) FROM registration) AS registrations,
       (SELECT count(*) FROM session) AS sessions, (SELECT count(*) FROM exam) AS exams_kept;
