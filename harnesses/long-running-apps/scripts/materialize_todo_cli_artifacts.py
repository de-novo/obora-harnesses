#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def extract_json_block(text: str):
    text = text.strip()
    start = text.find('{')
    end = text.rfind('}')
    if start == -1 or end == -1 or end <= start:
        return None
    candidate = text[start:end+1]
    try:
        return json.loads(candidate)
    except Exception:
        return None


def extract_markdown_after_marker(text: str):
    return text.strip()


def main():
    if len(sys.argv) != 3:
        print('usage: materialize_todo_cli_artifacts.py <run_json> <artifacts_dir>', file=sys.stderr)
        sys.exit(2)

    run_json = Path(sys.argv[1])
    artifacts_dir = Path(sys.argv[2])
    obj = json.loads(run_json.read_text())
    records = obj.get('stepRecords', {})

    mapping = {
        'plan_product': ('spec.md', 'text'),
        'define_contract': ('task-contract.json', 'json'),
        'evaluate_contract': ('qa-report.json', 'json'),
        'summarize_comparison': ('comparison-summary.md', 'text'),
        'implement_contract': ('implementation-notes.md', 'text'),
    }

    written = {}
    for step, (filename, kind) in mapping.items():
        rec = records.get(step) or {}
        output = rec.get('output', '')
        path = artifacts_dir / filename
        if not output:
            continue
        if kind == 'json':
            parsed = extract_json_block(output)
            if parsed is None:
                continue
            path.write_text(json.dumps(parsed, indent=2) + '\n')
            written[filename] = 'json'
        else:
            path.write_text(extract_markdown_after_marker(output) + '\n')
            written[filename] = 'text'

    print(json.dumps({"written": written}, indent=2))


if __name__ == '__main__':
    main()
