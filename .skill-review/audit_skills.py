"""Inventory and statically inspect selected skills without executing their code."""
import ast
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SELECTION = [
    ('Roblox/roblox-studio-agent-plugin', 'roblox-official', ['skills/roblox-get-started']),
    ('EL4CTEO/roblox-skills', 'roblox-skills', ['skills/' + n for n in (
        'roblox-luau', 'roblox-ui', 'roblox-input', 'roblox-world-building',
        'roblox-performance', 'roblox-testing', 'roblox-tooling', 'roblox-studio-mcp')]),
    ('tabooharmony/roblox-brain', 'roblox-brain', ['skills/gameplay/' + n for n in (
        'roblox-gui', 'roblox-building', 'roblox-lighting')]),
    ('EL4CTEO/blender-skills', 'blender-skills', ['skills/' + n for n in (
        'blender-core', 'blender-scene-setup', 'blender-hardsurface-modeling',
        'blender-sculpting', 'blender-retopology-uv', 'blender-pbr-materials',
        'blender-texturing', 'blender-texture-baking', 'blender-geometry-nodes',
        'blender-game-optimization', 'blender-export-pipelines', 'blender-rendering',
        'blender-lighting-lookdev', 'blender-stylized-npr', 'blender-environment-kits',
        'blender-asset-qa', 'blender-pipeline-automation', 'blender-workflow-recipes')]),
]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    manifest, findings, imports = [], [], {}
    for repo, checkout, paths in SELECTION:
        local = ROOT / checkout
        commit = subprocess.check_output(['git', '-C', str(local), 'rev-parse', 'HEAD'], text=True).strip()
        for rel in paths:
            folder = local / rel
            doc = (folder / 'SKILL.md').read_text(encoding='utf-8')
            assert doc.startswith('---\n') and re.search(r'^description:', doc, re.M), folder
            name = re.search(r'^name:\s*(\S+)', doc, re.M).group(1)
            assert name == folder.name, folder
            files = {}
            for path in sorted(folder.rglob('*')):
                assert not path.is_symlink(), path
                if not path.is_file():
                    continue
                key = path.relative_to(folder).as_posix()
                files[key] = sha(path)
                content = path.read_text(encoding='utf-8')
                if path.suffix == '.py':
                    tree = ast.parse(content, filename=str(path))
                    mods = set()
                    for node in ast.walk(tree):
                        if isinstance(node, ast.Import):
                            mods.update(a.name for a in node.names)
                        elif isinstance(node, ast.ImportFrom):
                            mods.add(node.module or '')
                    imports[f'{name}/{key}'] = sorted(mods)
                patterns = [r'(?i)\b(?:requests|urllib|socket|subprocess)\b',
                            r'(?i)\b(?:exec|eval)\s*\(', r'(?i)shell\s*=\s*True',
                            r'(?i)(?:rmtree|os\.system|os\.remove|\.unlink)\s*\(',
                            r'(?i)(?:ignore|override).{0,35}(?:previous|system).{0,20}instructions',
                            r'(?i)(?:curl|wget).{0,180}\|\s*(?:bash|sh|iex)',
                            r'(?i)(?:credentials|api.key|token|password|secret)']
                for line_no, line in enumerate(content.splitlines(), 1):
                    if any(re.search(p, line) for p in patterns):
                        findings.append({'skill': name, 'file': key, 'line': line_no, 'text': line[:500]})
            manifest.append({'name': name, 'repo': repo, 'commit': commit, 'path': rel,
                             'checkout': checkout, 'files': files})
    (ROOT / 'selected-skills.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    (ROOT / 'static-findings.json').write_text(json.dumps(findings, indent=2), encoding='utf-8')
    (ROOT / 'python-imports.json').write_text(json.dumps(imports, indent=2), encoding='utf-8')
    print(json.dumps({'skills': len(manifest), 'files': sum(len(s['files']) for s in manifest),
                      'python_files_parsed': len(imports), 'findings_to_review': len(findings),
                      'imports': sorted({m for v in imports.values() for m in v})}, indent=2))


if __name__ == '__main__':
    main()
