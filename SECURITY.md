# Security Policy

## Supported Versions
We release milestones using Semantic Versioning (`v0.x.0`).  
Only the latest milestone is actively maintained.

## Scope
This policy applies to the application code in this repository.  
Third‑party dependencies are monitored via automated tools (Trivy, Dependabot).

## Reporting a Vulnerability
If you discover a security issue:
- Email: **chandan.kolambe@gmail.com**
- Subject: `[SECURITY] Vulnerability Report`

Please include:
- Steps to reproduce
- Affected version/tag
- Suggested fix (if known)

## Responsible Disclosure
Please do not publicly disclose security issues until they have been reviewed and patched.  
We ask that you:
- Provide detailed steps to reproduce
- Allow us reasonable time to investigate and fix
- Avoid exploiting the vulnerability

## Automated Security
All Docker images are scanned with [Trivy](https://github.com/aquasecurity/trivy) during CI/CD.  
Critical vulnerabilities block publishing until resolved.

## CVE Tracking
We track vulnerabilities using GitHub Security Advisories.  
If a CVE is assigned, it will be linked in the Release Notes.
