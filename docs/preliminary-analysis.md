# Preliminary Analysis Report

**CSN Certification Exam Registration System**
In preparation for: CIT Department, CSN
Prepared by: Systems Analysis & Consulting Department

> Student coursework for CIT 260. Not an official CSN document or system.

## Project description

The CIT Department at College of Southern Nevada has requested a self-service system for their Certification Exams. CSN offers a wide variety of certifications (such as Excel, Cisco, and Microsoft) across its three campuses: West Charleston, North Las Vegas, and Henderson. Students will authenticate with their Student ID and NSHE ID to register for an available exam using drop-down selections only, preventing free-text input and bad data entry. The system design enforces three business rules: no double booking rooms, no duplicate registrations for the same exam, and no registration once an exam is full (no waitlist).

For admins, there will be another portal to define each term's exam list and create sessions (time, campus, building, room number, proctor, and a seat capacity set at 20 by default). Faculty will also be able to compose the confirmation email templates and generate reports for export (CSV, Excel, PDF). These reports will include instructor, student, exam, location, or date. This system does not administer exams, track scores, or process fees.

## Project importance

Certifications are incredibly important for CIT students transitioning into the workforce, and a smooth transition is important to maintaining the program's reputation. The current process of manual sign-ups and spreadsheets shared via email is exactly the workflow that causes double bookings and incorrect seat counts.

- Certifications are increasingly required or preferred for those entering the IT industry. Dependable access to exams that administer certifications is a necessity.
- A multi-campus, multi-proctor operation cannot effectively scale on manual scheduling. The risk of double booking and duplicate registrations increases with every exam offered.
- A clean, user-friendly drop-down registration system removes bad data issues (incorrect spelling, wrong room numbers, misspelled names, duplicate sign-ups, etc.).

Considering the above, this is a high-priority, high-value project for the CIT Department.

## Benefits

- Eliminates the possibility of exam rooms being double booked through rule-based validation the moment registration starts.
- Reduces administrative workload by automating confirmation emails and exportable reports instead of manually kept lists.
- Improves the student experience with a single, fast registration screen with easy drop-down selections, plus self-cancellation and history.
- Gives staff flexibility to add, remove, or adjust approved exams each term.
- Cleaner institutional data (no free-text entry) means more reliable reporting for program reviews.

## Resources

| Resource | Detail |
|---|---|
| Project team | Systems Analyst/Project Lead, AI-assisted Full-Stack Developer, one QA tester |
| Stakeholders | CIT faculty available for requirements confirmation, UAT, and sign-off for 1 month |
| Identity data | Read access to CSN's student directory for validating emails and NSHE IDs |
| Infrastructure | Cloud hosting environment and an institutional email for sending confirmations |
| AI development platform | Subscription access to an AI assistant to accelerate the project |

## Scope

**In scope**

- One student-facing registration screen (login → select exam → confirm)
- Faculty portal for creating/editing exams, maintaining approved exams, composing confirmation emails, and exporting reports
- Automated enforcement of three core rules: no double-booked rooms, no duplicate exams per student, no registration once an exam is full (no waitlist)
- Support for all three campuses (West Charleston, North Las Vegas, Henderson), including multiple buildings, rooms, and proctors per campus

**Out of scope**

- Exam delivery of any kind. Exams remain proctored and onsite.
- Scoring or any tracking of pass/fail metrics
- Attendance tracking
- Fee processing or payment of any kind
- A waitlist. Any exam with full registration becomes unavailable.

## Software tools needed

| Area | Tool |
|---|---|
| AI-assisted development | Claude as the primary AI assistant for both student and admin portals |
| Front end | React, using CSN's current visual component library where available |
| Back end / API | Node.js with a REST API layer |
| Database | PostgreSQL (sessions, registrations, exam catalog) |
| Authentication | Existing CSN SSO / NSHE identity provider |
| Email | Transactional email for personalized confirmations |
| Hosting | Cloud platform, or whichever CSN uses for dev/staging/prod |
| Report exporting | Server-generated CSV/Excel exports; PDF exports from a lightweight library |
| Project management / QA | Lightweight PM board (Jira) and a test tracking sheet for the 1-month sprint |

## Estimated project cost

This project is recommended to be completed with an AI assistant. Because the system is a single student-facing registration screen plus a faculty admin portal, an AI coding platform (Claude) can cut production time significantly, allowing a small team to complete the project in 1 month.

| Role | Hours | Rate | Cost |
|---|---:|---:|---:|
| Systems Analyst / Project Lead | 160 | $100/hr | $16,000 |
| AI-assisted Full-Stack Developer | 160 | $100/hr | $16,000 |
| QA / Test Engineer | 160 | $100/hr | $16,000 |
| **Labor subtotal** | **480** | | **$48,000** |

| One-time / recurring cost | Amount |
|---|---:|
| AI platform (Claude) | $200 |
| Cloud hosting | $150 |
| Email service | $50 |
| **Total** | **$400** |

**Estimated total project cost:** $48,000 (labor) + $400 (platform, month one)

## Feasibility

- **Technical: Feasible.** The system uses common web technology (React, Node, PostgreSQL), and the data model is clean and easy to follow (exams, sessions, registrations). The main risk is integrating with CSN's existing SSO/NSHE system.
- **Operational: Feasible.** Faculty must adapt to a new portal for creating exam sessions and reports, transitioning from the current manual process.
- **Schedule: Aggressive, but feasible.** The 1-month timeline is reasonable only with an AI assistant and a narrow scope. Additions such as a waitlist or payment processing should be treated as version 2.
- **Economic: Feasible.** For a multi-campus registration and administration system, $48,000 is reasonable, assuming CSN provides SSO/NSHE and hosting rather than the team building them from scratch.

## Recommendation

Approve a 1-month sprint using AI-assisted development for a team of three as outlined above, and keep the scope to registration and administration only. Exclude exam delivery, test scoring, attendance tracking, and payment processing.
