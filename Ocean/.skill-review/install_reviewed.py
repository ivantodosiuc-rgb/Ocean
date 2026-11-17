"""Install only the reviewed, commit-pinned skill directories; never overwrite."""
import hashlib
import json
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEST = Path('C:/Users/Administrator/.codex/skills')
HELPER = DEST / '.system/skill-installer/scripts/install-skill-from-github.py'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    skills = json.loads((ROOT / 'selected-skills.json').read_text(encoding='utf-8'))
    groups = defaultdict(list)
    for skill in skills:
        assert '/' not in skill['name'] and '\\' not in skill['name']
        assert len(skill['commit']) == 40
        target = DEST / skill['name']
        if target.exists():
            raise RuntimeError(f'Refusing to overwrite: {target}')
        source = ROOT / skill['checkout'] / skill['path']
        for rel, expected in skill['files'].items():
            assert digest(source / rel) == expected, f'Reviewed source changed: {source / rel}'
        groups[(skill['repo'], skill['commit'])].append(skill)
    results = []
    for (repo, commit), group in groups.items():
        command = [sys.executable, str(HELPER), '--repo', repo, '--ref', commit,
                   '--method', 'download', '--dest', str(DEST), '--path']
        command.extend(s['path'] for s in group)
        completed = subprocess.run(command, text=True, capture_output=True, encoding='utf-8', timeout=180)
        print(completed.stdout, end='', flush=True)
        if completed.returncode:
            print(completed.stderr, file=sys.stderr, flush=True)
        for skill in group:
            target = DEST / skill['name']
            errors = []
            for rel, expected in skill['files'].items():
                path = target / rel
                if not path.is_file() or digest(path) != expected:
                    errors.append(rel)
            if not errors:
                license_path = ROOT / skill['checkout'] / 'LICENSE'
                (target / 'UPSTREAM-LICENSE.txt').write_bytes(license_path.read_bytes())
                provenance = {k: skill[k] for k in ('name', 'repo', 'commit', 'path', 'files')}
                provenance['review_date'] = '2026-11-16'
                (target / 'INSTALL-PROVENANCE.json').write_text(json.dumps(provenance, indent=2), encoding='utf-8')
            results.append({'name': skill['name'], 'destination': str(target),
                            'verified': not errors, 'mismatches_or_missing': errors})
    (ROOT / 'installation-results.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
    passed = sum(r['verified'] for r in results)
    print(f'Installed and SHA-256 verified: {passed}/{len(skills)}', flush=True)
    return 0 if passed == len(skills) else 1


if __name__ == '__main__':
    raise SystemExit(main())
