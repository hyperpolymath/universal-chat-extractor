<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- TOPOLOGY.md — Project architecture map and completion dashboard -->
<!-- Last updated: 2026-02-19 -->

# Universal Chat Extractor — Project Topology

## System Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              OPERATOR / USER           │
                        │        (CLI Interface / Privacy HUD)    │
                        └───────────────────┬─────────────────────┘
                                            │ Command / File
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │           PARSER REGISTRY HUB           │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ WhatsApp  │  │ Telegram / Signal │  │
                        │  │ (.txt)    │  │ (JSON / Backup)   │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        │  ┌─────▼─────┐  ┌────────▼──────────┐  │
                        │  │ Discord / │  │ iMessage / Slack  │  │
                        │  │ Slack     │  │ (SQLite / API)    │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │           UNIFIED MESSAGE SCHEMA        │
                        │    (Normalization, PII Anonymization)   │
                        └───────────────────┬─────────────────────┘
                                            │
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │           EXPORT ENGINE                 │
                        │  ┌───────────┐  ┌───────────┐  ┌───────┐│
                        │  │ JSON/CSV  │  │ Markdown  │  │ PDF   ││
                        │  └───────────┘  └───────────┘  └───────┘│
                        └─────────────────────────────────────────┘

                        ┌─────────────────────────────────────────┐
                        │          REPO INFRASTRUCTURE            │
                        │  Justfile Automation  .machine_readable/  │
                        │  Deno / ReScript      0-AI-MANIFEST.a2ml  │
                        └─────────────────────────────────────────┘
```

## Completion Dashboard

```
COMPONENT                          STATUS              NOTES
─────────────────────────────────  ──────────────────  ─────────────────────────────────
PARSER REGISTRY
  WhatsApp Parser (.txt)            █░░░░░░░░░  10%    Architecture stubs
  Telegram Parser (JSON)            █░░░░░░░░░  10%    Format spec verified
  iMessage / Discord                ░░░░░░░░░░   0%    Pending specification

CORE LOGIC
  Unified Message Schema            █░░░░░░░░░  10%    Normalization stubs
  PII Anonymization Mode            ░░░░░░░░░░   0%    Privacy logic planned
  Export Engine                     █░░░░░░░░░  10%    Output format stubs

REPO INFRASTRUCTURE
  Justfile Automation               ██████████ 100%    Standard tasks active
  Multi-Forge Synchronization       ██████████ 100%    GH/GL/BB/CB sync stable
  .machine_readable/                ██████████ 100%    STATE tracking active

─────────────────────────────────────────────────────────────────────────────
OVERALL:                            ██░░░░░░░░  ~20%   Specification Phase
```

## Key Dependencies

```
Chat Export ──────► Parser Registry ─────► Unified Schema ────► Export File
     │                 │                      │                    │
     ▼                 ▼                      ▼                    ▼
Privacy Rules ───► Anonymization ──────► Local Processing ────► Report
```

## Update Protocol

This file is maintained by both humans and AI agents. When updating:

1. **After completing a component**: Change its bar and percentage
2. **After adding a component**: Add a new row in the appropriate section
3. **After architectural changes**: Update the ASCII diagram
4. **Date**: Update the `Last updated` comment at the top of this file

Progress bars use: `█` (filled) and `░` (empty), 10 characters wide.
Percentages: 0%, 10%, 20%, ... 100% (in 10% increments).
