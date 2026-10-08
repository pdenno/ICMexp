# ICMexp — Interpretable Context Methodology, tried on a problem-solving task

This repository holds a small experiment we performed to understand the Interpretable Context Methodology (ICM) of Van Clief and McDermott (2026).
We develop, as faithfully as we could, a task of the kind our Sched6 system performs: eliciting a manufacturer's scheduling problem and producing a
MiniZinc model of it — and watched where the folder-as-plan architecture helped and where it presented difficulties.

- The analysis of this experiment is this READM.md.
- The workspace is in `sched-mini/`; the run artifacts are in its `stages/\*/output/` folders.
- The experiment protocol and its observation log are in `sched-mini/STRESS-TEST.md`.


The analysis has three parts:
(1) what ICM is,
(2) what it offers relative to orchestration frameworks such as LangGraph, and (3)
where it falls short relative to systems like Sched6, in which the plan is not known before the run.
Readers familiar with Sched6 can skim §3.1.

The short version of our analysis is this: ICM is probably a good solution to sequential, human-reviewed, repeatable workflows.
It replaces a framework with a folder, and that is a real contribution, particularly for people who are not programmers.
For problem solving, where the next step depends on what was just learned, where a claim made in conversation may need to be tested with a tool,
and where verification and traceability are part of the method rather than an afterthought, ICM has no place to put the things that matter.
The experiment shows both the strengths and the weaknesses.

- - -
## 1\. What ICM is

Van Clief and McDermott's claim is that for workflows that are sequential, reviewed by a human at each step, and run repeatedly with different inputs,
multi-agent frameworks (they name CrewAI, LangChain, AutoGen) impose engineering overhead the problem does not need.
ICM replaces framework-level orchestration with filesystem structure:
numbered folders are stages,
plain markdown files carry the prompts and context,
local scripts do the mechanical work that needs no AI, and
a single orchestrating agent reads the right files at the right moment.
Their slogan is that the folder structure replaces the framework, and they trace the lineage through Unix pipelines, Make, pipe-and-filter architecture,
Parnas's information hiding, literate programming, and multi-pass compilation.

**Architecture.** A workspace is a folder with a five-layer context hierarchy.
- Layer 0 (`CLAUDE.md`, ~800 tokens) is workspace identity: *where am I?*
- Layer 1 (a root `CONTEXT.md`, ~300 tokens) is task routing: *where do I go?*
- Layer 2 (each stage's `CONTEXT.md`, 200–500 tokens) is the stage contract, with Inputs, Process and Outputs sections: *what do I do?*
- Layer 3 is reference material — voice guides, conventions, domain knowledge — stable across runs, which they call "the factory."
- Layer 4 is working artifacts — the previous stage's output, the user's source material — which change every run, "the product."

The Inputs table in each Layer-2 contract names exactly which Layer-3 and Layer-4 files (and which sections of them) the stage loads;
the authors call this the control point of the system, because it makes context scoping explicit, editable and auditable.
They report 2,000–8,000 tokens of context per stage against ~42,000 for a monolithic prompt, and lean on Liu et al.'s "lost in the middle" result
to argue that scoping prevents rather than compresses irrelevant context.

**Design principles.**
- One stage, one job.
- Plain text as the interface (markdown and JSON only).
- Layered context loading.
- Every output is an edit surface — the human may edit a stage's output file before the next stage reads it.

**Evidence.** All implementations described in their paper ran in Claude Code with Opus 4.6 orchestrating and Sonnet 4.6 sub-agents.
Notably, the orchestrator uses the same `CONTEXT.md` hierarchy to construct sub-agent prompts, so the folder is both the human's
control surface and the model's orchestration logic.
Three workspaces are described (a script-to-animation pipeline, a slide-deck producer, and a workspace that builds workspaces), plus external adoption under NDA.
Practitioner observations come from an invite-only community of 52; the headline is a U-shaped intervention pattern — heavy human editing at the first
stage (direction-setting), light in the middle, heavy again at the last
(alignment, "closer to debugging"), reported by 30 of 33 users.
The authors are candid that all of this is self-reported through conversation, self-selected, single-model-family, and that there is no controlled
comparison with monolithic prompting; the quality claim rests on theory plus practitioner judgment.

**Scope limits they concede.**
ICM is not for real-time multi-agent collaboration, high-concurrency multi-user systems, or workflows that need automated branching on AI decisions mid-pipeline.
Their Table 1 lists conditional branching as "human decides between stages," and §5.2 says that automating it
"would require scripting that moves ICM toward being a framework itself."
We'll revisit this sentence in §3 below.

- - -
## 2\. ICM relative to LangGraph and similar frameworks

The paper's comparison lumps LangChain, AutoGen and CrewAI together as "frameworks."
The human author here (Peter) is only familiar with LangChain, but Claude suggests it is worth separating them as two layers, because ICM's advantages are
real against one of them and its disadvantages are real against the other.

LangChain is a component library: uniform interfaces over models, prompts, tools, retrievers and memory, with a composition idiom for chaining them.
The composition is a fixed dataflow written in code.
LangGraph is an orchestration runtime built on top: a typed state object, nodes that read and update it, edges
— including conditional edges whose target is computed from the state — with cycles, checkpoints after every step, and interrupts so a human can
inspect or edit state and resume.
The graph is the explicit plan; the state is the explicit working memory.

Against this, ICM's advantages are the ones the paper claims, and they hold up, best we can tell:

**The control surface is a folder, and the people who can change it need not be programmers.**
Reordering stages is renaming folders.
Changing what a stage does is editing a markdown file.
Adding a review gate is adding a stage.
In contrast, in a LangGraph application each of these is a code change, a redeploy, and a developer.
For manufacturing operations this is not a small thing.
By such means the production system itself can be evolved — a line is added, an inspection step moves, a planner wants a different hand-off —
and the people who know what changed are production engineers, not the people who wrote the orchestration.
Of course, there would need to be change control imposed on process, but it might not require more than what git provides.
ICM lets them keep the workflow current.
In our run, a production engineer could read `stages/02-specify/CONTEXT.md` cold and understand what the stage reads, does and writes;
the same is not true of a LangGraph node.

**State is inspectable by default.** Every intermediate is a file.
There is no logging layer to build and no dashboard to configure.
LangGraph's checkpoints contain the same information, but reading them is a developer task.

**Portability and hand-off.** A workspace is copied, versioned in git, or zipped.
There is no environment to replicate.
The authors' consultant-to-client hand-off story is plausible.

**Token discipline.** The Inputs table forces someone to say what each stage loads.
Frameworks make it easy to load everything.
Our stage 3 ran against roughly 10k tokens of context (its contract, two reference files, the spec, and the schema-conforming response (SCR) for verification),
which is comfortably inside the paper's envelope.
Two caveats temper this, both visible in our run.

First, "anyone with a text editor can change the behavior" (their claim) is true of what the files *say* and only loosely true of what the agent *does*.
The depth of our stage-1 interview — eighteen questions, several of them about things no field in the Discovery Schema asked for
(the shift calendar, how to treat leak test, changeover by station) — came from the agent's judgment, not from the files.
(The files are talking about here are the stage contract (01-interview/CONTEXT.md), interview-method.md, and the two Discovery Schemas.)
`interview-method.md` §4 says not to ask outside the schema unless the expert raises it, and the agent stretched "raises it" a bit.
The files set the stage;
the model decided how much to do with it.
A non-programmer who edits these files to change the interview will find that part of its behavior comes from what the expert says
and from what the model already knows a scheduling problem requires, and neither of those is in the folder.
The problem isn't that editing the files does nothing;
adding a field to the schema will get that field asked about.
The proble is that there is no edit that gives you the whole behavior, because two of its three sources aren't files.
If the engineer deletes the calendar question from the method, the agent may still ask it when the expert gives wall-clock hours;
if the engineer adds a rule saying "ask only what the schema lists," the agent will still, sometimes, ask what it knows a model needs.
The folder is a partial control surface presented as a complete one.

Second, the comparison favors ICM only where the workflow is actually fixed.
LangGraph's conditional edges, cycles and resumable interrupts are exactly the capabilities ICM concedes it lacks.
ICM's critique of frameworks is largely aimed at the LangGraph layer, and the question is whether your problem needs that layer.
The paper's examples do not.
Our Sched6 experiment is a bit of a stress test that does need that layer.
This is described in §3 below.

- - -
## 3\. ICM relative to Sched6-like systems

### 3.1 What Sched6 is, briefly

Sched6 (also SchedulingTBD) is a NIST research system in which AI agents interview people who run small manufacturing operations and, from what
they learn, build a scheduling solution — a MiniZinc constraint model — that the manufacturer can run without further AI involvement.
It is organized as an MCP server; the orchestrating agent is Claude.
Its working parts are:

*Discovery Schemas (DS)* — templates that guide one interview on one topic (the process flow, the resources, the orders, the objective).
An interview yields a *schema-conforming response (SCR)*, and SCRs from many interviews merge into an *aggregated SCR (ASCR)*, the structured working state of a project.

*Scheduling action sentence templates (SASTs)* — plain-language sentences stating what the schedule must do or respect, each traceable to what the expert
said and to the MiniZinc that implements it.
The set of SASTs is the living specification;
coverage over it is how completeness of the interview segment is judged.

*An orchestrator working from a guide* (`SCHED6_MCP_GUIDE.md`) that states goals, principles, and restrictions on pacing (small increments),
gating (ASCR completion tests before moving on), and scope (SAST coverage, watching for creep).
There is no explicit list of steps to execute; the orchestrator decides what to do next from the state of the ASCR, the guide, and the conversation, using tools:
run an interview, build a model, test a claim.
The only places coordination lives in code are a LangChain-based sub-conversation loop and one MCP tool, `next_step_advice`, which is a planner, roughly speaking.

*Piloting rehearsals* — before a solution is handed over, the interviewee is walked through using it.
In a recent study, the interviewee reversed their judgment that the solution was "ready for piloting" in eleven of twelve rehearsals.
What they described as the scheduling policy the sought didn't sit well with them when they saw it in action against a severe production demands.
The 11 of 12 number is one of the reason the plan cannot be fixed in advance: even the question of when the work is done is settled by the work.

The behavior we value most, and want more of, is, for example, this: an interviewee says "our problem is the braze cell,"
the orchestrator treats that as a claim, builds a small model to test it, and the result changes what gets asked next.
Nobody wrote that step. It was derived from a goal, a foundation of beliefs about how to pursue it, and a disposition to be helpful within our rules for
verification, validation, traceability, and stewardship.

### 3.2 Where the plan lives, and whether it exists

ICM says "the coordination logic lives in the filesystem, not in application code."
That is a fair criticism of LangGraph.
It is not a criticism of Sched6, where the coordination logic does not live in application code either;
it is entailed by the MCP orchestrator's guide.
So the real axis is not *where the plan lives* but *what shape the plan has*, and that turns out to be a spectrum.

In **ICM** the plan is a total order written as folder numbers.
It is fully known before the run.
There are no state-dependent choice points; the human is the only one making branching decisions.
This is why ICM can honestly claim "no application code": a total order is a degenerate plan that needs none.

In **LangGraph** the plan is an authored graph.
Edges may be conditional on state, cycles are allowed, and the runtime checkpoints state between nodes.
The plan is still fully known before the run — someone drew the graph — but which path through it is taken is decided at run time.

In **classical planners** — PDDL-based systems, or HTN planners such as SHOP2 — the plan is not written at all;
it is searched for, or decomposed, from a domain of operators with preconditions and effects, or of methods that break tasks into subtasks.
The plan is produced at run time, and it is sound with respect to the domain: each step's preconditions are guaranteed by the steps before it.
Discovery Schema sequencing in Sched6 is the closest thing it has to this — a DS can say what must be known before it is useful,
roughly an HTN method's precondition — and that is the only place Sched6 has preconditions at all.

**Sched6** sits past the planners on this spectrum, and the reason is that even the planning domain is not fixed.
The operators are not known in advance because the interviewee's situation is not known in advance;
the goal condition is not known because, as the rehearsals show, the interviewee's judgment of "done" moves.
What Sched6 has instead of a domain is a goal, a body of beliefs about how to pursue it, and an orchestrator that is Claude, so that the next
step is justified by evidence and principles rather than by state predicates.
The absence of pre- and post-conditions is not a gap to apologize for:
it is what lets the system be helpful in ways nobody enumerated.
The price is that nothing guarantees soundness, and the substitutes for that guarantee are methodical:
SASTs (like Zave and Jackson's action predicates) for traceability,
ASCR completion tests for gating,
small increments for pacing, rehearsals for validation.
(The discussion that produced this README is a small illustration of the same behavior:
it set out to characterize ICM, took a long detour into domain-specific languages for a different problem, and came back, and the detour was useful.
A planner would not have taken it; a folder could not have.)

Seen this way, ICM's Table 1 row "conditional branching: human decides between stages" and its §5.2 concession that automated branching "would require
scripting that moves ICM toward being a framework itself" are the whole case.
The moment a task needs what Sched6 needs, ICM says to stop using ICM. We agree.

### 3.3 What the experiment showed

`sched-mini/` is a three-stage ICM workspace: `01-interview` elicits a
scheduling problem from an expert using one of two Discovery Schemas (flow shop
or job shop); `02-specify` turns the SCR into a specification whose §3 is a list
of numbered *action sentences*, each citing the SCR field it comes from; `
03-model` writes MiniZinc with an `% AS-n` comment per sentence, a trace table,
and a verification step that checks the model back against the stage-1 SCR (the
paper's *n−2* Verify idea). The run used a surrogate expert for a
refrigerator-compressor plant, drawn from an earlier Sched6 project, with the
human relaying the surrogate's answers. `STRESS-TEST.md` holds eight predictions
made before the run and the observation log; the table below is the summary.
Everything in it is reconstructed from the files in `stages/\*/output/`, `
example-blocked.md`, and `icm-exp.org`.


|\#|Prediction                                                                                                                                 |What happened                                                                                                                                                                                                                                                                                                                                                                                                                   |
|--|-------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|P1|Stage 1 is a loop, not a pass; the contract must describe it in prose because ICM has no construct for iteration inside a stage            |Held. Eighteen questions, a checkpoint summary, and corrections. Part of the depth was the agent's judgment, not the files (see §2).                                                                                                                                                                                                                                                                                            |
|P2|Stage 1 must load *both* Discovery Schemas because the choice depends on the answers; the Inputs table cannot say "A or B depending on state"|Held by construction. Stage 2's Inputs row "section matching the `schema:` line of scr.md" is the agent doing routing the table cannot express.                                                                                                                                                                                                                                                                                 |
|P3|Facts the schema has no field for land in `other constraints (verbatim, unmodeled)`, and stage 2 must then block, improvise, or drop them  |Held: thirteen entries. Stage 2 neither blocked nor dropped; it improvised well — a 6 h leak-test lag and a 3.5 h packing lag as resourceless delays, a working-hour time axis, a quarter-hour time unit (departing from `_config/domain.md`, which says hours), and explicit sequence-dependent setup (departing from `modeling-choices.md`). Each departure was recorded in spec §0 and §6.                                   |
|P4|A late fact forces a backward move that only the human can make                                                                            |Held, differently than planned. No late fact was injected; the backward move came from stage 3's own gate: it read spec §6, found that open question 1 (setup) decided whether two action sentences existed, wrote `BLOCKED.md`, and stopped. The human resolved it (answer A), stage 3 re-ran.                                                                                                                                 |
|P5|Editing an output by hand at a gate will be easier than re-running, the human will do it, and it bypasses the earlier stage's audit        |Held. The resolution was written into `spec.md` §6 by hand; stage 2 was not re-run and its audit did not see the change.                                                                                                                                                                                                                                                                                                        |
|P6|The *n−2* verify step catches at least one discrepancy, probably in the objective                                                          |Half held. All twenty data checks passed. What the verify step caught was not a mismatch but a gap: the objective check "passes only because `weight` is all 1," which spec §6 had left open, and the solved plan serves the escalated lot *worst* (L3 39.5 h late, the filler 1.5 h). The trace says it exactly: "the model is doing exactly what the specification says; the specification is not yet doing what the expert said."|
|P7|Context per stage stays small, but only because the problem is capped                                                                      |Held; roughly 10k tokens at stage 3. The transcript was excluded from stage 2 by contract; the SCR carried the state.                                                                                                                                                                                                                                                                                                           |
|P8|Changing a Layer-3 file silently invalidates downstream outputs; dependency tracking is the human remembering                              |Not tested. No second run was made.                                                                                                                                                                                                                                                                                                                                                                                             |

Four things from the run deserve more than a table row.

**The gate worked, and the agent critiqued it.**
`BLOCKED.md` (preserved as `example-blocked.md`, because stage 3 deleted it on completion) is the best artifact of the experiment.
It
- identified the one structural open question among eight,
- explained the two answers and their consequences for the model,
- named which stage to re-run and why not the other, and
- then observed that the gate as written "will fire on most honestly written specs," because a spec that records real open questions is doing its job, and
"the way to pass it is to write a §6 that is empty or evasive."
That is the edit-source principle applied by the agent to its own contract — and in ICM there is nowhere for it to go except
a note the human may or may not read.
In Sched6 a finding like that is an input to the next step.

**The record of being blocked was lost by the filesystem.**
Stage 3 removed `BLOCKED.md` so that "a stale blocked notice sitting beside a finished model would misread as an active block."
That is reasonable, and it means the only trace that the run was ever blocked is prose in `trace.md` §0 and a copy the human made by hand.
ICM's state is the current contents of files; it has no history beyond what git happens to capture and no way to say "this was true, and then it wasn't."
The ASCR and project database in Sched6 exist to hold exactly that.

**The model found a fact the interview should have found, and could do nothing with it.**
The solved plan is proved optimal at 65 working hours of total tardiness;
nothing ships on time; and lot L1 cannot meet its Wednesday promise under any schedule, because its own path
(build 10.5 + braze 7 + leak 6 + vac 8 \+ run test 12 + pack 3.5 = 47 working hours) exceeds the 42 working hours available.
Either the midpoint durations are pessimistic or the promise was never achievable.
That is a question for the expert, and it is the paradigm case of the claim-testing behavior described in §3.1:
the model has refuted something the interview took as given.
In Sched6 the orchestrator would take it back to the interviewee.
In ICM it is the last paragraph of `trace.md`, and the run is over.

**The solver conventions were overridden by judgment, correctly.** `
minizinc-conventions.md` targets Gecode and says to report rather than tune if it fails.
Gecode (the MiniZinc solver) found no solution in 120 s.
The agent reported it, then ran Chuffed (the script already exposed `MZN_SOLVER`), which proved optimality in under a minute.
Good outcome; also another case of the agent, not the files, deciding what to do.

### 3.4 What ICM cannot express

Our position is that verification, validation, traceability, and stewardship are part of the method, not properties checked afterwards.
ICM cannot express them.
That is a stronger claim than "ICM does not do them," so here is what it rests on.

*Verification* in Sched6 means that a claim — the interviewee's, or the system's own — can be tested by building something and running it, and
that the result feeds back into what happens next.
ICM has outputs and review gates.
A test is a stage, its result is a file, and what happens next is the next folder.
The infeasible promise above is a verification result with nowhere to go.

*Validation* in Sched6 is the piloting rehearsal: the interviewee tries to use the thing, and in eleven of twelve cases changes their mind about whether it is done.
There is no stage in ICM after the last stage, and no way for a later stage to reopen an earlier one except the human re-running it;
the rehearsal's finding that the problem was misframed has no path back to the Discovery Schema that framed it.

*Traceability* in Sched6 is the SAST set:
every requirement traces to what the expert said and to the code that implements it, and coverage is computed over the set.
Our workspace imported this as action sentences, `% AS-n` comments, and the trace table, and it worked — but note what it took.
The sentences, their citations, and the trace are structure that the agent maintained by following instructions;
nothing in ICM checks that an `AS-9` comment really implements sentence 9, or that a sentence cites a field that exists.
ICM's own traceability is that every intermediate is a file you can read.
The paper's §6 wish list (provenance identifiers, Verify sections, tracking recurring edits) is a request for more structure than markdown provides, and it is unmet.

*Stewardship* is the orchestrator's responsibility for the whole: to pace (small increments), to gate (do not move on until the ASCR passes its completion
test), to keep scope (SAST coverage, no creep), and to be helpful within those restrictions.
These are constraints on *how the plan is made*, not steps in it.
A folder can hold steps. It can approximate gating with human review.
It has nowhere to put pacing or scope, because they govern decisions the folder does not make.

The root of all four is the same. ICM's artifacts have only whatever semantics the reader brings to them on each reading.
Discovery Schemas, SCRs, SASTs, and MiniZinc models are sub-languages: something other than the LLM can operate on them
— check them, merge them, compute coverage over them, translate them.
That is what lets the conversation in Sched6 be *about* the artifact rather than about what the artifact says,
and it is what lets a goal plus a body of beliefs produce a plan that nobody wrote down.
Plain markdown in numbered folders cannot carry it.

### 3.5 What is worth taking from ICM

Three things, independent of the folder.

The **explicit Inputs table** — each agent's context declared, editable, and auditable — is a discipline Sched6 could adopt for its agents even though the
loading is done by tools rather than by reading a folder.

The **edit-source principle** — recurring edits to output are diagnostic of a defect in the guidance; fix the guide — is the right frame for how `
SCHED6_MCP_GUIDE.md` and the Discovery Schemas should evolve across tranche evaluations.
The `BLOCKED.md` critique of its own gate is a worked example.

The **n−2 Verify step** — check stage *n* against stage *n−2*, not just *n−1* — is a cheap form of the bidirectional traceability we want for SASTs, and in
this run it is what surfaced the gap between the specification and the expert's priorities.

- - -
## 4\. Repository map

```
ICMexp/
  README.md                      this analysis
  icm-exp.org                    running discussion log (Emacs org)
  example-blocked.md             stage 3's BLOCKED.md, preserved by hand
  data/s6-interviews/            the Sched6 run report the surrogate expert was drawn from
  sched-mini/
	CLAUDE.md, CONTEXT.md        ICM Layers 0 and 1
	STRESS-TEST.md               experiment protocol, predictions, observation log
	_config/, shared/, setup/    Layer 3 (workspace-wide), per ICM conventions
	scripts/run-minizinc.sh      the one non-AI script
	stages/01-interview/         contract, two Discovery Schemas, interview method; output: scr.md, transcript.md
	stages/02-specify/           contract, spec template, standard formulations; output: spec.md
	stages/03-model/             contract, MiniZinc conventions; output: model.mzn, data.dzn, trace.md, solution.txt
```
To reproduce: open `sched-mini/` in Claude Code, say "start," answer as a plant
expert, and say "run stage 2" and "run stage 3" at the gates. Run the solver
with `MZN_SOLVER=chuffed bash scripts/run-minizinc.sh`.

## References

- J. Van Clief and D. McDermott, "Interpretable Context Methodology: Folder
  Structure as Agent Architecture," arXiv:2603.16021v2, March 2026. Protocol
  and conventions: <https://github.com/RinDig/Interpretable-Context-Methodology>
- N. F. Liu et al., "Lost in the Middle: How Language Models Use Long
  Contexts," TACL 12, 2024.
- D. Nau et al., "SHOP2: An HTN Planning System," JAIR 20, 2003.
- M. Ghallab, D. Nau and P. Traverso, *Automated Planning and Acting*,
  Cambridge, 2016 (for the PDDL/HTN distinction used in §3.2).
- P. Denno et al. Participants as Designers: A Human-AI Teaming Method and its Evaluation for Manufacturing Scheduling,
  in press, 2026.
- P. Zave & M. Jackson, Four Dark Corners in Requirements Engineering, ACM Transactions on Software Engineering and Methodology, 1997.
