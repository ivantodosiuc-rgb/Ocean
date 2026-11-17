"""Verify installed bytes against audited source, allowing only CRLF normalization."""
import ast
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEST = Path('C:/Users/Administrator/.codex/skills')


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    finalize = '--finalize' in sys.argv
    skills = json.loads((ROOT / 'selected-skills.json').read_text(encoding='utf-8'))
    results = []
    for skill in skills:
        target = DEST / skill['name']
        source = ROOT / skill['checkout'] / skill['path']
        errors, normalized, hashes = [], [], {}
        for rel, expected in skill['files'].items():
            path = target / rel
            original = (source / rel).read_bytes()
            assert digest(original) == expected, 'Audited source changed'
            if not path.is_file() or path.is_symlink():
                errors.append(rel)
                continue
            raw = path.read_bytes()
            hashes[rel] = digest(raw)
            if digest(raw) != expected:
                if raw.replace(b'\r\n', b'\n') == original.replace(b'\r\n', b'\n'):
                    normalized.append(rel)
                else:
                    errors.append(rel)
            if path.suffix == '.py':
                ast.parse(raw.decode('utf-8'), filename=str(path))
        doc = (target / 'SKILL.md').read_text(encoding='utf-8')
        assert re.search(r'^name:\s*' + re.escape(skill['name']) + r'\s*$', doc, re.M)
        assert re.search(r'^description:\s*\S', doc, re.M)
        missing_links = []
        for link in re.findall(r'\]\(([^)]+)\)', doc):
            if '://' not in link and not link.startswith('#'):
                if not (target / link.split('#')[0]).exists():
                    missing_links.append(link)
        assert not missing_links, missing_links
        if finalize and not errors:
            (target / 'UPSTREAM-LICENSE.txt').write_bytes((ROOT / skill['checkout'] / 'LICENSE').read_bytes())
            provenance = {k: skill[k] for k in ('name', 'repo', 'commit', 'path')}
            provenance.update(review_date='2026-11-16', files=hashes,
                              checkout_crlf_normalized_files=normalized)
            (target / 'INSTALL-PROVENANCE.json').write_text(json.dumps(provenance, indent=2), encoding='utf-8')
        results.append({'name': skill['name'], 'destination': str(target), 'verified': not errors,
                        'files': len(hashes), 'crlf_only_differences': normalized,
                        'mismatches_or_missing': errors, 'missing_markdown_links': missing_links})
    report = {'review_date': '2026-11-16', 'skills_verified': sum(r['verified'] for r in results),
              'files_verified': sum(r['files'] for r in results), 'results': results}
    (ROOT / 'installation-verification.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps({k: v for k, v in report.items() if k != 'results'}, indent=2))
    print('CRLF-only files:', sum(len(r['crlf_only_differences']) for r in results))
    return 0 if all(r['verified'] for r in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
