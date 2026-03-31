#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def load_json(path):
    return json.loads(Path(path).read_text())


def extract_smoke(obj):
    if 'deterministicSmoke' in obj:
        return obj['deterministicSmoke']
    return obj


def main():
    if len(sys.argv) != 4:
        print('usage: compare_todo_cli_variants.py <baseline_json> <enhanced_json_or_qa_report> <output_md>', file=sys.stderr)
        sys.exit(2)

    baseline = extract_smoke(load_json(sys.argv[1]))
    enhanced = extract_smoke(load_json(sys.argv[2]))
    output = Path(sys.argv[3])

    lines = []
    lines.append('# Automated Todo CLI comparison')
    lines.append('')
    lines.append('## Deterministic smoke result')
    lines.append('')
    lines.append(f'- baseline: {"PASS" if baseline.get("passed") else "FAIL"}')
    lines.append(f'- enhanced: {"PASS" if enhanced.get("passed") else "FAIL"}')
    lines.append('')
    lines.append('## Failure signatures')
    lines.append('')
    lines.append(f'- baseline signature: {baseline.get("signature")!s}')
    lines.append(f'- enhanced signature: {enhanced.get("signature")!s}')
    lines.append('')
    lines.append('## Observations')
    lines.append('')
    if baseline.get('passed') and enhanced.get('passed'):
        lines.append('- Both artifacts pass deterministic command smoke.')
    elif enhanced.get('passed') and not baseline.get('passed'):
        lines.append('- Enhanced artifact passes deterministic smoke while baseline does not.')
    elif baseline.get('passed') and not enhanced.get('passed'):
        lines.append('- Baseline passes deterministic smoke while enhanced does not.')
    else:
        lines.append('- Both artifacts fail deterministic smoke and require further analysis.')
    lines.append('- Enhanced variant should still be reviewed for artifact quality, contract clarity, and QA traceability beyond command pass/fail.')
    lines.append('')

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text('\n'.join(lines) + '\n')
    print('\n'.join(lines))


if __name__ == '__main__':
    main()
