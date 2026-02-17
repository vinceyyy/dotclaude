# Handoff Instruction

> Paste the instruction below into your Claude.ai chat at the end of an ideation conversation. Claude.ai will generate a
> `PROJECT_SPEC.md` artifact that Claude Code can build from.

## Instruction

```
Generate a PROJECT_SPEC.md artifact that hands off this conversation to Claude Code for implementation. Cover:

- **Why**: background, motivation, the problem we're solving
- **What**: purpose, target audience, success criteria
- **How**: tech stack, architecture, key components, data requirements
- **Order**: what to build first, what's out of scope
- **Open questions**: anything we didn't resolve that Claude Code should ask about

Record final decisions only — not the alternatives we considered or how we got there. The spec is a snapshot of what to
build, not a history of the conversation. Include enough context that Claude Code understands the intent, not just the
spec. Omit sections that aren't relevant.

End with:

## Transfer
1. Save this as PROJECT_SPEC.md in your project folder
2. Tell Claude Code: "Read PROJECT_SPEC.md and build this."
```
