-- Fictitious sample data for demos and testing. Not real students or staff.

INSERT INTO campus (campus_name) VALUES ('West Charleston'), ('North Las Vegas'), ('Henderson');

INSERT INTO building (campus_id, building_name) VALUES
  (1, 'Building K'), (1, 'Building D'),
  (2, 'Building E'),
  (3, 'Building C');

INSERT INTO room (building_id, room_number) VALUES
  (1, 'K-205'), (1, 'K-210'), (2, 'D-104'), (3, 'E-118'), (4, 'C-131');

INSERT INTO staff (nshe_id, full_name, role) VALUES
  ('2000000001', 'Dana Whitfield', 'Faculty'),
  ('2000000002', 'Marcus Ortega',  'Proctor'),
  ('2000000003', 'Priya Raman',    'Proctor');

INSERT INTO student (nshe_id, first_name, last_name, csn_email) VALUES
  ('1000000001', 'Jordan', 'Avery',  'jordan.avery@student.example.edu'),
  ('1000000002', 'Sam',    'Lindqvist', 'sam.lindqvist@student.example.edu'),
  ('1000000003', 'Riley',  'Chen',   'riley.chen@student.example.edu');

INSERT INTO exam (exam_name, vendor) VALUES
  ('Microsoft Office Specialist: Excel Associate', 'Microsoft'),
  ('Cisco Certified Support Technician: Networking', 'Cisco'),
  ('CompTIA A+ Core 1', 'CompTIA');

INSERT INTO session (room_id, proctor_id, session_date, start_time, end_time, capacity) VALUES
  (1, '2000000002', CURRENT_DATE + 14, '09:00', '11:00', 20),
  (4, '2000000003', CURRENT_DATE + 16, '13:00', '15:00', 20),
  (5, '2000000002', CURRENT_DATE + 21, '10:00', '12:00', 2);   -- small, to demo "full"

INSERT INTO session_exam VALUES (1, 1), (1, 3), (2, 2), (2, 3), (3, 1);

INSERT INTO email_template (subject, body, edited_by) VALUES (
  'You''re registered: {{exam_name}}',
  'Hi {{first_name}} {{last_name}},

You are registered for {{exam_name}}.

Campus: {{campus}}
Building: {{building}}
Room: {{room}}
Date: {{date}}
Time: {{start_time}} – {{end_time}}

Bring a photo ID. To cancel, log in and open My Registrations up to 5 minutes before the exam.',
  '2000000001');
