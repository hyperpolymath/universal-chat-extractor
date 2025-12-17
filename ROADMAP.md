# Universal Chat Extractor - Roadmap

## Project Overview

Universal Chat Extractor aims to provide a unified tool for extracting, parsing, and exporting chat data from various messaging platforms.

---

## Current Status (v0.1.0)

### Completed
- [x] Repository initialization
- [x] Multi-platform git mirroring (GitHub, GitLab, Codeberg, Bitbucket)
- [x] CI/CD infrastructure with security hardening
- [x] AGPL-3.0-or-later licensing

### Security Hardening Applied
- [x] SSH host key verification (MITM protection)
- [x] Credential persistence disabled
- [x] Concurrency controls for race condition prevention
- [x] Job timeouts to prevent resource abuse
- [x] Shell hardening with `set -euo pipefail`
- [x] Pinned GitHub Actions with SHA hashes

---

## Phase 1: Core Infrastructure (Next)

### 1.1 Project Structure Setup
- [ ] Create source directory structure (`src/`, `tests/`, `docs/`)
- [ ] Initialize package configuration (pyproject.toml or package.json)
- [ ] Set up development environment (virtualenv/nvm)
- [ ] Add .gitignore for language-specific artifacts

### 1.2 CI/CD Pipeline Expansion
- [ ] Add linting workflow (ESLint/Ruff/Pylint)
- [ ] Add unit test workflow
- [ ] Add security scanning (Dependabot, CodeQL, or Snyk)
- [ ] Add code coverage reporting

### 1.3 Documentation Foundation
- [ ] README.md with project description
- [ ] CONTRIBUTING.md guidelines
- [ ] CODE_OF_CONDUCT.md
- [ ] LICENSE file (AGPL-3.0)

---

## Phase 2: Core Extraction Engine

### 2.1 Parser Framework
- [ ] Design plugin-based parser architecture
- [ ] Implement base parser interface/abstract class
- [ ] Create parser registry for dynamic loading

### 2.2 Platform Support (Priority Order)
- [ ] WhatsApp (.txt export format)
- [ ] Telegram (JSON export format)
- [ ] Discord (JSON export format)
- [ ] Signal (backup format)
- [ ] iMessage (SQLite database)
- [ ] Facebook Messenger (JSON export)
- [ ] Slack (JSON export)

### 2.3 Data Model
- [ ] Define unified message schema
- [ ] Handle attachments/media references
- [ ] Support threading/reply relationships
- [ ] Normalize timestamps across timezones

---

## Phase 3: Export & Output Formats

### 3.1 Export Formats
- [ ] JSON (structured)
- [ ] CSV (tabular)
- [ ] HTML (viewable)
- [ ] Markdown
- [ ] PDF generation

### 3.2 Export Options
- [ ] Date range filtering
- [ ] Participant filtering
- [ ] Media handling (embed/reference/skip)
- [ ] Anonymization mode

---

## Phase 4: User Interface

### 4.1 Command Line Interface
- [ ] Argument parsing (argparse/click)
- [ ] Progress indicators
- [ ] Verbose/quiet modes
- [ ] Configuration file support

### 4.2 Optional GUI (Future)
- [ ] Web-based interface consideration
- [ ] Desktop app evaluation (Electron/Tauri)

---

## Phase 5: Advanced Features

### 5.1 Analysis Tools
- [ ] Message statistics (counts, frequency)
- [ ] Participant activity analysis
- [ ] Keyword/phrase search
- [ ] Sentiment analysis (optional)

### 5.2 Privacy & Security
- [ ] Local-only processing (no cloud uploads)
- [ ] Secure deletion of temporary files
- [ ] Encryption support for exports
- [ ] PII detection and redaction

### 5.3 Integration
- [ ] Python library API for programmatic use
- [ ] Docker container for isolated execution
- [ ] GitHub Action for automated extraction

---

## Security Considerations

### Input Validation
- Sanitize all file paths
- Validate file formats before parsing
- Limit memory usage for large files

### Dependency Management
- Regular security audits
- Pinned dependency versions
- Automated vulnerability scanning

### Data Handling
- No telemetry or data collection
- Clear data flow documentation
- Secure memory handling for sensitive data

---

## Contributing

Contributions welcome! Please see CONTRIBUTING.md (when available) for guidelines.

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 0.1.0 | 2025-12-17 | Initial infrastructure setup, CI/CD mirroring |

---

*Last updated: 2025-12-17*
