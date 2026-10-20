-- CSN Certification Exam Registration System — PostgreSQL schema
-- Implements the Data Design Document (10 tables, 3NF).
-- The three core business rules are enforced by the database itself:
--   REQ01 no double-booked rooms      -> exclusion constraint on session
--   REQ23 one active reg per exam     -> partial unique index on registration
--   REQ02 no registration once full   -> trigger with a row lock on the session

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- lets = and && share one exclusion constraint

-- People ---------------------------------------------------------------

CREATE TABLE student (
  nshe_id     CHAR(10)     PRIMARY KEY CHECK (nshe_id ~ '^[0-9]{10}$'),
  first_name  VARCHAR(50)  NOT NULL,
  last_name   VARCHAR(50)  NOT NULL,
  csn_email   VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE staff (
  nshe_id    CHAR(10)     PRIMARY KEY CHECK (nshe_id ~ '^[0-9]{10}$'),
  full_name  VARCHAR(100) NOT NULL,
  role       VARCHAR(20)  NOT NULL CHECK (role IN ('Instructor', 'Proctor', 'Faculty'))
);

-- Locations (REQ19) ----------------------------------------------------

CREATE TABLE campus (
  campus_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  campus_name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE building (
  building_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  campus_id      INT NOT NULL REFERENCES campus,
  building_name  VARCHAR(50) NOT NULL,
  UNIQUE (campus_id, building_name)
);

CREATE TABLE room (
  room_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  building_id  INT NOT NULL REFERENCES building,
  room_number  VARCHAR(10) NOT NULL,
  UNIQUE (building_id, room_number)
);

-- Exams and sessions ---------------------------------------------------

CREATE TABLE exam (
  exam_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  exam_name  VARCHAR(100) NOT NULL UNIQUE,
  vendor     VARCHAR(50),
  is_active  BOOLEAN NOT NULL DEFAULT TRUE          -- REQ17 approved list
);

CREATE TABLE session (
  session_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  room_id       INT      NOT NULL REFERENCES room,
  proctor_id    CHAR(10) NOT NULL REFERENCES staff,  -- REQ16
  session_date  DATE     NOT NULL,
  start_time    TIME     NOT NULL,
  end_time      TIME     NOT NULL,
  capacity      INT      NOT NULL DEFAULT 20 CHECK (capacity > 0),  -- REQ30, REQ31
  CHECK (end_time > start_time),
  -- REQ01: no two sessions in the same room at overlapping times.
  -- '[)' means a 10:00-11:00 session and an 11:00-12:00 session do not conflict.
  CONSTRAINT no_double_booked_room EXCLUDE USING gist (
    room_id WITH =,
    tsrange(session_date + start_time, session_date + end_time, '[)') WITH &&
  )
);

CREATE TABLE session_exam (
  session_id  INT NOT NULL REFERENCES session ON DELETE CASCADE,
  exam_id     INT NOT NULL REFERENCES exam,
  PRIMARY KEY (session_id, exam_id)
);

-- Registrations --------------------------------------------------------

CREATE TABLE registration (
  registration_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  student_id       CHAR(10)    NOT NULL REFERENCES student,
  session_id       INT         NOT NULL,
  exam_id          INT         NOT NULL,
  registered_at    TIMESTAMP   NOT NULL DEFAULT now(),
  status           VARCHAR(10) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Cancelled')),
  cancelled_at     TIMESTAMP,
  -- A registration must point at an exam that session actually offers.
  FOREIGN KEY (session_id, exam_id) REFERENCES session_exam,
  CHECK ((status = 'Cancelled') = (cancelled_at IS NOT NULL))
);

-- REQ23: only one ACTIVE registration per student per exam. Cancelled rows
-- stay for history (REQ21) and don't block re-registering.
CREATE UNIQUE INDEX one_active_registration_per_exam
  ON registration (student_id, exam_id) WHERE status = 'Active';

-- REQ02: reject a registration when the session is full. Locking the session
-- row makes two students racing for the last seat take turns, so the count
-- can never go over capacity.
CREATE FUNCTION enforce_session_capacity() RETURNS trigger AS $$
DECLARE
  cap   INT;
  taken INT;
BEGIN
  IF NEW.status <> 'Active' THEN RETURN NEW; END IF;
  SELECT capacity INTO cap FROM session WHERE session_id = NEW.session_id FOR UPDATE;
  SELECT count(*) INTO taken FROM registration
   WHERE session_id = NEW.session_id AND status = 'Active'
     AND registration_id IS DISTINCT FROM NEW.registration_id;
  IF taken >= cap THEN
    RAISE EXCEPTION 'Session % is full (% of % seats taken)', NEW.session_id, taken, cap
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER session_capacity
  BEFORE INSERT OR UPDATE OF status, session_id ON registration
  FOR EACH ROW EXECUTE FUNCTION enforce_session_capacity();

-- Email template (REQ03, REQ15) ----------------------------------------

CREATE TABLE email_template (
  template_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subject      VARCHAR(150) NOT NULL,
  body         TEXT         NOT NULL,  -- placeholders like {{first_name}}, {{exam_name}}, {{room}}
  edited_by    CHAR(10)     REFERENCES staff,
  updated_at   TIMESTAMP    NOT NULL DEFAULT now()
);

-- What a student can pick from (REQ02, REQ09-REQ12, REQ17) --------------
-- One row per open seat option: active exam, future session, seats left.
-- The app filters this further by student to hide exams they already hold (REQ23).
CREATE VIEW open_session_exam AS
SELECT s.session_id, e.exam_id, e.exam_name, e.vendor,
       c.campus_id, c.campus_name, b.building_name, r.room_number,
       s.session_date, s.start_time, s.end_time, s.capacity,
       s.capacity - count(reg.registration_id) FILTER (WHERE reg.status = 'Active') AS seats_left
FROM session s
JOIN room r          USING (room_id)
JOIN building b      USING (building_id)
JOIN campus c        USING (campus_id)
JOIN session_exam se USING (session_id)
JOIN exam e          USING (exam_id)
LEFT JOIN registration reg ON reg.session_id = s.session_id
WHERE e.is_active AND s.session_date + s.start_time > now()
GROUP BY s.session_id, e.exam_id, c.campus_id, b.building_name, r.room_number
HAVING s.capacity - count(reg.registration_id) FILTER (WHERE reg.status = 'Active') > 0;

-- REQ25: end-of-semester wipe. Removes everything except campuses,
-- buildings, rooms, the exam catalog and the email template.
CREATE FUNCTION end_of_semester_wipe() RETURNS void AS $$
BEGIN
  UPDATE email_template SET edited_by = NULL;
  TRUNCATE registration, session_exam, session, student RESTART IDENTITY;
  DELETE FROM staff;  -- DELETE, not TRUNCATE, because email_template references staff
END $$ LANGUAGE plpgsql;
