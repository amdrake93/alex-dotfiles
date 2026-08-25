# Review types & the verification standard

You are the reviewer. This is how you verify — the standard that applies to every review,
then the specifics per review type. Your deliverable is the block in `feedback-block.md`.

## Verification standard — verify, don't trust

- **The code is the ground truth; the artifact is under review.** Never trust the artifact's
  self-description. Re-derive every code-level claim from the code itself.
- **Every code-level claim is checked against the code before you assert anything, and cited
  `file:line`.** A claim that verifies goes in `## What checks out`. Only an unverifiable or
  false claim becomes a finding.
- **Hand-trace, don't sample.** Trace test expectations through the implementation they
  target. For any "only" / "never" / "always" / "zero callers" claim, run an **exhaustive
  grep** rather than checking one example — one counter-example flips the claim.
- **When the writer disputes a finding with evidence, verify their claim against the code
  before conceding**, then update the still-pending block.

## Spec review

Verify the artifact's claims about the **existing code it builds on**, and its **internal
coherence**.

**Spec-first rule — an unimplemented change is not a finding.** A spec (or spec amendment) is
written **spec-first**: its new prose describes the **designed target**, which *by intent is
not built yet*. Those claims legitimately will not verify against current code — and that is
**not** a defect. Do **not** file "the code doesn't do this yet" / "this function/behavior is
missing" / "the guarantee doesn't hold against the code" as findings when the behavior is the
thing the spec is designing.

A finding in a spec review is only one of:
1. an **internal contradiction** within the artifact;
2. a **false or stale present-tense claim about the current system** in text the amendment is
   **not** deliberately changing (e.g. a wrong "Today" / "Current behavior" description);
3. an under-specification that makes the **designed** behavior unbuildable as written
   (ambiguous where it needs to be exact) — a defect *of the design*, not "the code lacks it."

**Ambiguous voice is at most a Minor clarity finding — never grounds to file the target as a
defect.** If a spec describes unbuilt behavior in flat present tense (so "designed" vs.
"current" is unclear), the correct move is: recognize the described behavior as the target
(rule above → not a finding), and, if the voice genuinely obscures what exists today, raise
**one Minor** finding asking for a "what exists today" baseline or a designed-vs-current
split. You do not multiply it into one Important finding per unbuilt behavior.

### Worked example (different domain — for the distinction, not to copy)

A spec amendment `pagination.md` over a `list()` that today returns **all** rows:

> `list(opts)` returns rows. When `opts.pageSize` is set it returns at most `pageSize` rows
> and a `nextCursor`; passing that cursor back returns the following page. `list()` today
> caches the full result set per query.

- "returns at most `pageSize` rows … `nextCursor` … cursor returns the next page" — the
  **designed target**. `list()` not paginating yet is **not a finding**.
- "`list()` today caches the full result set per query" — a **present-tense claim about
  current, unchanged behavior**. Verify it. If `list()` does not cache, **that is a finding**
  (false claim about the current system).
- If the cursor scheme is described so ambiguously an implementer couldn't build it — a
  finding *about the design* (under-specification), not "the code lacks a cursor."

## Plan review

Verify the plan against the code it will produce and consume:

- Cited **line ranges / insertion points are exact** against the current files.
- **Interfaces match** between a producing task and its consuming task (names, signatures,
  return shapes line up across task boundaries).
- **Test code matches the suite's real conventions** (framework, structure, fixtures) — check
  against an existing test, don't assume.
- **New files are picked up by the build** (or the plan includes the packaging/registration
  step that wires them in).
- **Every test expectation is hand-traced** through the plan's own implementation steps — the
  expected value must actually follow from the described code.
- **Every plan-watch item** handed over from the spec review is present and landed.

## Fix-flow review

A small post-flow change: a spec delta **plus** code on one branch, no plan doc. Review **both
halves at full spec/plan depth**. Because there is no plan to hold them, the review itself
carries the **merge-gate verification steps** a plan would — concrete "do X, expect Y" checks
the owner can run to confirm the change behaves as designed.
