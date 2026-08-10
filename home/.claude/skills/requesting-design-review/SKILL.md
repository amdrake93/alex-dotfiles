---
name: requesting-design-review
description: 'Use when a spec or plan needs an independent review before it drives code, or before treating a design artifact as settled — the design-time counterpart to requesting-code-review. Also use for a small fix-flow change (spec delta + code, no plan). Symptoms: about to build from an unreviewed spec, about to call a plan done, "just review it myself."'
---

# requesting-design-review

## Overview

The design-time counterpart to `superpowers:requesting-code-review`: an isolated,
independent review of a **spec or plan**, feeding the writer's
`superpowers:receiving-code-review`. It fills the gap superpowers leaves — `brainstorming`
and `writing-plans` produce the artifacts where an unexamined assumption is cheapest to
catch, but ship no independent review for them.

**Core principle:** *The reviewer re-derives from code ground truth, never from the
writer's narrative — independence is the product.* A self-review by the authoring session
cannot re-derive blind to its own story; that independence is the whole point.

**Code is the truth; the artifact is under review** — never trusted as truth. This is what
makes the skill portable: it needs only an artifact and code to verify against, both present
in any contribution, durable spec or one-off design doc alike. (`review-types.md` carries the
verification standard.)

## When to use

- A spec (from `brainstorming`) or plan (from `writing-plans`) is about to drive code.
- About to treat a design artifact as settled / call a plan done.
- A small **fix-flow** change: a spec delta + code on one branch, no plan doc.

Not for standalone **code** review → that is `superpowers:requesting-code-review`. Not for
re-deriving research/ground-truth docs from binaries or vendored upstream.

## Review taxonomy

- **Spec review** — reviews `brainstorming` output.
- **Plan review** — reviews `writing-plans` output.
- **Fix-flow review** — a small post-flow change (spec delta + code, no plan doc) that keeps
  the spec current and still earns an isolated review of both halves.
- **Re-review / closure** — not an artifact type; the loop's built-in re-verification phase.

Per-type specifics live in `references/review-types.md`; the reviewer's deliverable format
in `references/feedback-block.md`; the manual two-session fallback in `references/bootstrap.md`.

## The review loop

Invoking this skill on an artifact is the owner's **"go" for the whole loop** — one
authorized turn that runs to closure or a break condition. It is **not** a pause gate:
surfacing (below) is an audit trail, the loop does not wait for the owner to read each round.

1. **Spawn** — dispatch the reviewer as a **fresh isolated subagent** — never a
   context-inheriting fork. It sees only: a fixed minimal trigger prompt, the repo(s)
   (CLAUDE.md included), and the diff(s). Its own git worktree when available; spawned on
   the **most capable available model**. The trigger instructs it to **load this skill's
   references and operate strictly by them** — passed as **concrete absolute paths you
   resolve for the current machine** (a fresh subagent can't expand `~`/`$HOME` or resolve
   relative paths itself, per `DISCOVERY-FINDING`). Compute them from **this skill's own
   install directory** — on Claude Code, `$HOME/.claude/skills/requesting-design-review/references/`
   — expanding `$HOME` to a real path when you write the trigger. Do **not** hardcode any one
   box's home. The two files to name:
   - `<resolved-home>/.claude/skills/requesting-design-review/references/review-types.md`
   - `<resolved-home>/.claude/skills/requesting-design-review/references/feedback-block.md`
2. **Review** — the reviewer re-derives everything from the code ground truth (never the
   writer's narrative), writes its feedback block to a **round-numbered audit file**, and
   returns it verbatim. Two safety rules on that file (the audit dir is shared scratch that
   outlives any one review):
   - **Unique dir per effort** — named for the artifact and review type
     (`<artifact-slug>-<review-type>/`), never a generic `plan-review/`. Generic names
     collide across efforts and sessions.
   - **Append-only, never overwrite** — write the **lowest `round-N.md` that does not yet
     exist**, not a self-counted N. A blind `round-1.md` clobbers a prior effort's block;
     a fresh re-bootstrapped reviewer also can't know the current N.

   The dir lives **outside all git trees** (session scratch — never repo-relative, so blocks
   can't be swept into a commit).
3. **Process** — the writer **surfaces the block verbatim** in the conversation (the audit
   trail), then processes it with **REQUIRED SUB-SKILL: `superpowers:receiving-code-review`**:
   verify each claim against the code, push back with `file:line` where it doesn't hold,
   commit fixes each named, and record plan-watch items / "no-change" decisions where the
   project keeps them.
4. **Re-review** — continue the **same** reviewer agent with only a constrained message
   (`"rereview — fixes committed, range <old>..<new>"` + contract-sanctioned pushback). No
   narrative — that is the contamination the fixed trigger exists to exclude. If the agent is
   lost, fall back to a fresh reviewer + the prior block.
5. **Terminate** — on a round with **nothing left to fix** (approved + no findings, or a
   closure on re-review). Minor-only findings keep the loop going until closed. The writer
   then **carries the branch to the owner's merge gate** — presented ready-for-review, never
   ready-to-merge.

Both directions are surfaced verbatim in the writer's conversation (every reviewer block
before it is acted on; every writer→reviewer message when sent).

## Invariants (non-negotiable)

**Violating the letter of these invariants violates their spirit.** They are the difference
between a real independent review and a review-shaped no-op.

**Isolation.** The reviewer is a **fresh** agent — **never a context-inheriting fork, and
never yourself.** A fork carries the writer's narrative; self-review re-derives from your own
story. Independence — not effort — is the product, so "the spec is small" and "the context is
already loaded" are reasons the shortcut is *tempting*, never reasons it is *safe*. The
trigger prompt is fixed and minimal — no summarizing the artifact, no explaining decisions;
everything load-bearing reaches the reviewer through the repo + diff. Audit files live outside
all git trees. If you are genuinely out of budget to spawn, the honest move is the manual
two-session fallback (`references/bootstrap.md`) — never a fork/self-review relabeled as
independent.

**Verdict boundary.** The reviewer's verdict is **exactly `approved` or `request changes`**
— and says **nothing about merge.** `approved` means the artifact is *right* (the review can
close), **not** ready-to-merge. Merge is the **owner's** separate, later gate; the reviewer
has no merge opinion. This holds in **both directions**: "not good to merge", "hold the
release", "clean merge", "ready to ship", "not good to ship this round" are all boundary
violations — a *negative* merge pronouncement crosses the line exactly as a positive one
does. The verdict names the **artifact's** state, never the branch's shippability. The writer
likewise always presents a branch as **ready-for-review, never ready-to-merge.**

### Rationalizations — STOP, you're crossing a boundary

| Excuse | Reality |
|--------|---------|
| "It already has everything loaded — forking is efficient." | A fork carries your narrative; the reviewer must re-derive blind. What makes the fork cheap is what disqualifies it. |
| "The spec is tiny — I'll just review it myself." | Self-review is the anti-pattern by name. Independence, not effort, is the product; a small artifact still gets an independent pass. |
| "Low on time/tokens, so cut the fresh reviewer." | Trade the reviewer's *model tier* or use the manual fallback — never the independence boundary. Fewer tokens on an invalid review is not a saving. |
| "They just need to know if it's shippable — the release is waiting." | Merge-readiness is the owner's call. Say `approved` / `request changes`, nothing about shipping. |
| "I'll just say 'not good to merge' — a rejection is safe." | Any merge/ship/release verdict crosses the boundary, negative included. The verdict names the artifact, not the branch. |

### Red flags — STOP and start over

- About to **fork** the reviewer, or **review it yourself** "because it's small / urgent."
- About to write a **chatty trigger** that summarizes the artifact or explains your decisions.
- About to say **"ready to merge" / "good to ship" / "not good to merge" / "clean merge" /
  "hold the release"** — in *either* direction.
- About to skip the **re-review** and call it closed after one pass.

## Break conditions to the owner (never automated past)

1. **Question findings** — owner design-decisions surface as "Question for `<owner>`"
   findings (never change requests). The loop pauses, the owner decides, the decision is
   **recorded** (a decision that lives only in conversation gets re-raised), then resumes.
2. **Deadlock** — the writer disputes a finding with evidence and the reviewer re-asserts.
   Escalate with both positions; do not ping-pong.
3. **Round cap: 5.** A round = one feedback block received; a Question-finding pause does not
   consume a round. Hitting the cap means the artifact or the process is wrong; the owner
   sees the state as-is.

## Binding model — two independent inputs

The artifact and the code its claims reference are frequently in **different places**, and
the artifact's location may not be a git repo. The reviewer takes two independently-resolved
inputs:

1. **The artifact** — path to the spec/plan under review. Reviewed against its **diff if
   versioned** (a doc-repo PR branch), or **as-it-stands if plain filesystem** (a personal
   dir with no history). No git required.
2. **Verification target(s)** — one or more **code** locations the artifact's claims are
   checked against (same repo, a sibling code repo, or **several** — the cross-repo
   consumer-impact case). Each gets a `git diff` where it has a branch under review.

Resolution: **invocation arg → the relevant project's `CLAUDE.md` → default.** Because the
two can live in different repos, "relevant project" is explicit per row:

| Config | Source |
|---|---|
| **Artifact path** | Invocation only — no default; genuinely varies per project. |
| **Decision-record location** (no-change decisions / plan-watch items) | The **artifact's project** (the repo/dir that owns the spec/plan and its process records). |
| **Reviewer model tier** | Review-environment choice, not a repo property: defaults to the most capable available model, overridable at invocation. |
| **Audit dir** | Fixed default: session scratch outside all git trees. Not repo-sourced. |

The **verification-target repos' `CLAUDE.md` files** are read by the *reviewer* as
ground-truth context for those repos' own conventions — never as this skill's config source.
