# Manual fallback — the two-session ferry

When the automated subagent dispatch isn't available, the review still runs — a **human
relays the feedback block verbatim between two Claude sessions**. Same contract as the
automated loop; the human is the transport instead of the subagent dispatch. The loop steps,
invariants (isolation, verdict boundary), break conditions, and binding model all live in
`SKILL.md` and still apply unchanged — this file adds only what is specific to running it by
hand across two sessions.

The one thing the ferry must protect is the same thing the dispatch protects: **the reviewer
session is fresh and never sees the writer's conversation.** A fork or self-review is still
forbidden; a second session that saw your narrative is not independent. Independence is the
product.

## The two sessions and the relay

- **Writer session** — holds the artifact and its narrative; invoked the review; processes
  feedback. Never reviews its own artifact.
- **Reviewer session** — a **separately-started, fresh** session with zero shared context. It
  stands in for the isolated subagent.
- **You (the human)** — the relay. You carry the feedback block **verbatim** from reviewer to
  writer, and the constrained re-review message from writer back to reviewer. Verbatim in both
  directions — paraphrasing reintroduces the narrative the isolation exists to exclude.

## Bootstrapping a fresh session into the **reviewer** role

Start a new session (not a fork of the writer). Use the most capable available model; give it
its own git worktree if available. Paste **only** a fixed, minimal trigger — no summary of the
artifact, no explanation of decisions. The trigger contains exactly:

- **Artifact** — the spec/plan path (its diff if versioned; as-it-stands if plain filesystem).
- **Verification target(s)** — the code location(s) to check claims against, each with its
  `git diff` / range where it has a branch under review.
- **Load and operate strictly by these** — as concrete absolute paths resolved for the
  current machine from this skill's install dir (on Claude Code, `$HOME/.claude/skills/requesting-design-review/references/`;
  expand `$HOME`, don't hardcode a box):
  - `<resolved-home>/.claude/skills/requesting-design-review/references/review-types.md`
  - `<resolved-home>/.claude/skills/requesting-design-review/references/feedback-block.md`
- **Audit dir** — session scratch outside all git trees, named `<artifact-slug>-<review-type>/`;
  write the **lowest `round-N.md` that does not yet exist** (append-only), then return the block
  verbatim.

Nothing from the writer's conversation goes in the trigger. The reviewer re-derives every
code-level claim from the code itself.

## Bootstrapping a fresh session into the **writer** (receiving) role

If the writer session is lost — or the receiving side is being picked up fresh — a new session
becomes the writer with **only** these inputs (again, none of the original review
conversation):

- The **artifact** path and its **verification target(s)** (same two inputs as above).
- The **pending feedback block** (the latest `round-N.md`, or the verbatim block handed to you).
- The instruction to process it with **`superpowers:receiving-code-review`**: verify each claim
  against the code, push back with `file:line` where it doesn't hold, commit fixes each named,
  record plan-watch items / no-change decisions where the project keeps them.

That is the whole receiving-side contract — the feedback block is self-contained and addressed
to the writer in the second person precisely so a fresh session can act on it with no other
context.

## Running the loop by hand

1. Writer prepares the two inputs + audit dir; hands you the reviewer trigger.
2. You paste the trigger into a fresh reviewer session. It writes `round-N.md` and returns the
   block.
3. You paste the block **verbatim** into the writer session. The writer processes it via
   `receiving-code-review`.
4. **Re-review:** you carry a constrained message back to the **same** reviewer session —
   `"rereview — fixes committed, range <old>..<new>"` plus any contract-sanctioned pushback,
   no narrative. It writes the next `round-N.md`. *If that reviewer session is gone,* bootstrap
   a new reviewer (above) and additionally hand it the prior block — the append-only "lowest
   unused N" rule is why a re-bootstrapped reviewer never needs to know the current round.
5. Terminate / break conditions / round cap: exactly as `SKILL.md` states.
