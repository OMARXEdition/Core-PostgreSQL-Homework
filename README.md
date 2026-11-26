# Course enrollment database project

PostgreSQL example with three related tables: `students`, `courses`, and
`enrollments`. The composite primary key on `enrollments` prevents a student
from enrolling in the same course twice. Foreign keys require existing students
and courses; `ON DELETE CASCADE` removes their enrollment rows. Other constraints
require unique emails and course codes, nonblank names and titles, and positive
course capacity.

## Run

From this folder, against a PostgreSQL database you can modify:

```sh
psql -v ON_ERROR_STOP=1 -d your_database -f schema.sql -f seed.sql -f demo.sql -f verify.sql
```

`schema.sql` drops the three project tables before recreating them. `demo.sql`
adds one committed enrollment, so recreate and reseed before rerunning it.

The demo executes CREATE, READ, UPDATE, DELETE, JOIN, GROUP BY, pagination,
COMMIT, ROLLBACK, and `EXPLAIN (ANALYZE, BUFFERS)` before and after a roster
index. The index test temporarily adds 20,000 benchmark students and enrollments
to make the plan comparison meaningful, then removes them. Execution times vary
by machine; compare the scan and sort operations, buffer use, and execution time.

## Verified results

Run on PostgreSQL 19 on 2026-11-26:

| Check | Result |
|---|---|
| Seed data | 8 students, 4 courses, 12 enrollments |
| CRUD | Student created, read, updated, and deleted; 0 demo students remain |
| JOIN | 4 students in `DB201` |
| GROUP BY | `CS101`: 4, `DB201`: 4, `MATH110`: 2, `STAT210`: 2 |
| Pagination | Page 2 at size 2 returns student IDs 3 and 4 |
| COMMIT / ROLLBACK | Committed enrollment exists (1 row); rolled-back enrollment does not (0 rows) |
| Final data | 8 students, 4 courses, 13 enrollments |

For the same `course_id = 2` query on the temporary 20,013-row enrollment
table, `EXPLAIN (ANALYZE, BUFFERS)` reported a sequential scan plus sort at
**2.985 ms** before the index and an index only scan at **0.095 ms** after it.
That run was about **31 times faster** with the index. This is one local
measurement, not a general performance guarantee. `verify.sql` also checked
the final row counts, transaction results, index presence, and rejection of a
duplicate email, zero capacity, missing student, and duplicate enrollment.

## AI usage

OpenAI Codex proposed the three-table design, generated the PostgreSQL schema,
sample records, and demonstration queries, and checked them by running the SQL.
The sample names and email addresses are fictional. The AI-generated SQL was
reviewed for primary and foreign keys, uniqueness, checks, transactions, and
query output. PostgreSQL measures the execution plans; AI did not invent them.
