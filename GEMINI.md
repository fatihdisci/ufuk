# UFUK (Horizon) — GEMINI.md
This file is the operational constitution for agents working in this repository.

## 1) Operational Security (OPSEC)

### Terminal Execution Policy
- ALLOW (safe / non-destructive):
  - `ls`, `pwd`, `cd`, `cat`, `echo`, `mkdir`, `touch`, `cp` (within workspace)
  - `flutter --version`, `dart --version`, `flutter doctor`
  - `git status`, `git diff` (read-only)
- REQUIRE_REVIEW (must STOP and ask for approval before running):
  - `flutter create`, any `flutter pub add`, `flutter pub get`
  - `flutter run`, `flutter build *`, `dart format`, `dart analyze`, tests
  - Any command that changes dependencies or generates files in bulk
- FORBIDDEN (never run):
  - `sudo`, `rm -rf`, system services (`systemctl`), editing files outside repo root
  - Uploading secrets or printing keys/tokens
  - Network scans or any security-sensitive probing

### Secrets & Credentials
- NEVER print API keys or tokens in logs or artifacts.
- Use `.env` (or platform equivalents) only if required; prefer keyless/public endpoints where possible.
- If a key is needed, ask user to create it and store locally. Do not request sensitive personal data.

## 2) Coding Standards (Flutter)
- Language: Dart (stable), Flutter (stable)
- Style:
  - Prefer composition over inheritance.
  - Keep widgets small, readable, and single-purpose.
  - Avoid “magic numbers”; centralize spacing/radius in a theme constants file.
- State Management:
  - Prefer minimal approach (ValueNotifier/ChangeNotifier) unless PRD requires more.
- Accessibility:
  - Respect text scaling, avoid tiny fonts, provide sufficient contrast.
  - Provide "Reduce Motion" behavior for heavy animations.

## 3) Interaction & Artifacts Protocol
- If a task touches more than 1 file:
  - MUST output an "Implementation Plan" artifact first.
  - MUST wait for approval before executing terminal commands.
- After finishing a task:
  - MUST output a "Walkthrough" describing how to manually verify.
  - MUST update `PROGRESS.md` (what changed, what’s next, blockers).

## 4) Cognitive Strategy (Reliability)
- Think → Plan → Execute:
  1) Analyze repo and requirements
  2) Propose plan + file list
  3) Wait for approval
  4) Implement with small diffs
- Self-correction:
  - If a command fails, analyze error and retry ONCE with a different approach.
  - If it fails again, STOP and ask user with a concise diagnosis + options.

## 5) Product Vibe Constraints (Non-negotiables)
- Single Page experience (no page navigation in MVP)
- Ambient background must feel calm and premium (no noisy gradients)
- Glassmorphism cards must be readable (blur + translucency + subtle border)
- No disruptive monetization (ads must never hijack the core “huzur” flow)
