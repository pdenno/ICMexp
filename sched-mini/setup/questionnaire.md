# Setup questionnaire (answered once; answers live in `_config/domain.md`)

ICM Pattern 8: flat, system-level, ask everything at once, never repeat.

1. Who is the intended interviewee? (owner / production lead / OR analyst)
   -> production lead or owner, non-specialist
2. What is the deliverable? (report / model / dashboard)
   -> MiniZinc model + data file, re-runnable by editing data only
3. Time unit and horizon?
   -> hours; one working week
4. Maximum problem size for this workspace?
   -> 6 orders, 4 resources, 5 steps
5. Which solver is installed locally?
   -> `minizinc` CLI with Gecode (edit `scripts/run-minizinc.sh` if different)
6. Should the interviewer propose modeling choices during the interview?
   -> no; interview only elicits, stage 2 decides
