#!/usr/bin/env python3
"""instinct-cli.py -- CLI for managing the GS Orchestrator instinct library.

Commands:
    list        List all instincts (optional: --tag <tag> to filter)
    add         Add a new instinct interactively
    remove      Remove an instinct by ID
    export      Export instincts to a JSON file
    import      Import instincts from a JSON file
    stats       Show instinct library statistics
    evolve      Analyze instincts and suggest promotions

Usage:
    python3 instinct-cli.py list
    python3 instinct-cli.py list --tag asyncpg
    python3 instinct-cli.py add --trigger "..." --observation "..." --action "..." --confidence 0.8 --tags "tag1,tag2"
    python3 instinct-cli.py remove inst-20260301-001
    python3 instinct-cli.py export instincts-backup.json
    python3 instinct-cli.py import instincts-backup.json
    python3 instinct-cli.py stats
    python3 instinct-cli.py evolve
"""

import argparse
import json
import sys
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

INSTINCTS_FILE = Path.home() / ".gs-orchestrator" / "instincts.jsonl"
ARCHIVE_FILE = Path.home() / ".gs-orchestrator" / "instincts-archive.jsonl"


def ensure_file_exists():
    """Ensure the instincts directory and file exist."""
    INSTINCTS_FILE.parent.mkdir(parents=True, exist_ok=True)
    if not INSTINCTS_FILE.exists():
        INSTINCTS_FILE.touch()


def load_instincts() -> list[dict]:
    """Load all instincts from the JSONL file."""
    ensure_file_exists()
    instincts = []
    with open(INSTINCTS_FILE) as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                instincts.append(json.loads(line))
            except json.JSONDecodeError:
                print(f"Warning: Skipping malformed line {line_num}", file=sys.stderr)
    return instincts


def save_instincts(instincts: list[dict]):
    """Write all instincts back to the JSONL file."""
    ensure_file_exists()
    with open(INSTINCTS_FILE, "w") as f:
        for inst in instincts:
            f.write(json.dumps(inst) + "\n")


def append_instinct(instinct: dict):
    """Append a single instinct to the file."""
    ensure_file_exists()
    with open(INSTINCTS_FILE, "a") as f:
        f.write(json.dumps(instinct) + "\n")


def cmd_list(args):
    """List all instincts, optionally filtered by tag."""
    instincts = load_instincts()

    if args.tag:
        instincts = [i for i in instincts if args.tag in i.get("tags", [])]

    if not instincts:
        print("No instincts found.")
        return

    for inst in instincts:
        conf = inst.get("confidence", 0)
        reinf = inst.get("reinforcements", 0)
        tags = ", ".join(inst.get("tags", []))
        promoted = " [PROMOTED]" if inst.get("promoted") else ""

        print(f"  {inst.get('id', '???')}{promoted}")
        print(f"    Trigger:    {inst.get('trigger', 'N/A')}")
        print(f"    Observation: {inst.get('observation', 'N/A')}")
        print(f"    Action:     {inst.get('action', 'N/A')}")
        print(f"    Confidence: {conf:.2f}  Reinforcements: {reinf}")
        print(f"    Tags:       {tags}")
        print()

    print(f"Total: {len(instincts)} instincts")


def cmd_add(args):
    """Add a new instinct."""
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    existing = load_instincts()
    seq = len(existing) + 1

    instinct = {
        "id": f"inst-{timestamp}-{seq:03d}",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "trigger": args.trigger,
        "observation": args.observation,
        "action": args.action,
        "confidence": args.confidence,
        "source": {
            "session": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
            "project": args.project or "unknown",
            "files": [],
        },
        "tags": [t.strip() for t in args.tags.split(",") if t.strip()],
        "reinforcements": 0,
    }

    append_instinct(instinct)
    print(f"Added instinct: {instinct['id']}")


def cmd_remove(args):
    """Remove an instinct by ID (archives it)."""
    instincts = load_instincts()
    to_remove = None
    remaining = []

    for inst in instincts:
        if inst.get("id") == args.instinct_id:
            to_remove = inst
        else:
            remaining.append(inst)

    if to_remove is None:
        print(f"Instinct '{args.instinct_id}' not found.", file=sys.stderr)
        sys.exit(1)

    # Archive the removed instinct
    ARCHIVE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(ARCHIVE_FILE, "a") as f:
        to_remove["archived_at"] = datetime.now(timezone.utc).isoformat()
        f.write(json.dumps(to_remove) + "\n")

    save_instincts(remaining)
    print(f"Archived instinct: {args.instinct_id}")


def cmd_export(args):
    """Export instincts to a JSON file."""
    instincts = load_instincts()
    output_path = Path(args.output)

    with open(output_path, "w") as f:
        json.dump(
            {
                "exported_at": datetime.now(timezone.utc).isoformat(),
                "count": len(instincts),
                "instincts": instincts,
            },
            f,
            indent=2,
        )

    print(f"Exported {len(instincts)} instincts to {output_path}")


def cmd_import(args):
    """Import instincts from a JSON file."""
    input_path = Path(args.input)

    if not input_path.exists():
        print(f"File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    with open(input_path) as f:
        data = json.load(f)

    imported = data.get("instincts", data if isinstance(data, list) else [])
    existing = load_instincts()
    existing_ids = {i.get("id") for i in existing}

    added = 0
    skipped = 0
    for inst in imported:
        if inst.get("id") in existing_ids:
            skipped += 1
        else:
            append_instinct(inst)
            added += 1

    print(f"Imported {added} instincts ({skipped} duplicates skipped)")


def cmd_stats(args):
    """Show instinct library statistics."""
    instincts = load_instincts()

    if not instincts:
        print("No instincts recorded yet.")
        return

    # Basic stats
    total = len(instincts)
    promoted = sum(1 for i in instincts if i.get("promoted"))
    avg_conf = sum(i.get("confidence", 0) for i in instincts) / total
    total_reinf = sum(i.get("reinforcements", 0) for i in instincts)

    # Tag distribution
    all_tags = []
    for inst in instincts:
        all_tags.extend(inst.get("tags", []))
    tag_counts = Counter(all_tags).most_common(10)

    # Project distribution
    projects = Counter()
    for inst in instincts:
        proj = inst.get("source", {}).get("project", "unknown")
        projects[proj] += 1

    # Confidence distribution
    high_conf = sum(1 for i in instincts if i.get("confidence", 0) >= 0.8)
    med_conf = sum(1 for i in instincts if 0.5 <= i.get("confidence", 0) < 0.8)
    low_conf = sum(1 for i in instincts if i.get("confidence", 0) < 0.5)

    print("Instinct Library Statistics")
    print("===========================")
    print(f"  Total:            {total}")
    print(f"  Promoted:         {promoted}")
    print(f"  Avg Confidence:   {avg_conf:.2f}")
    print(f"  Total Reinforcements: {total_reinf}")
    print()
    print("  Confidence Distribution:")
    print(f"    High (0.8+):    {high_conf}")
    print(f"    Medium (0.5-0.8): {med_conf}")
    print(f"    Low (<0.5):     {low_conf}")
    print()
    print("  Top Tags:")
    for tag, count in tag_counts:
        print(f"    {tag}: {count}")
    print()
    print("  By Project:")
    for proj, count in projects.most_common(5):
        print(f"    {proj}: {count}")


def cmd_evolve(args):
    """Analyze instincts and suggest promotion candidates."""
    instincts = load_instincts()

    if len(instincts) < 3:
        print("Need at least 3 instincts to analyze patterns.")
        return

    # Cluster by tags
    tag_groups: dict[str, list[dict]] = {}
    for inst in instincts:
        if inst.get("promoted"):
            continue
        for tag in inst.get("tags", []):
            tag_groups.setdefault(tag, []).append(inst)

    # Find promotion candidates (3+ instincts, avg confidence >= 0.7)
    candidates = []
    for tag, group in sorted(tag_groups.items(), key=lambda x: -len(x[1])):
        if len(group) >= 3:
            avg_conf = sum(i.get("confidence", 0) for i in group) / len(group)
            total_reinf = sum(i.get("reinforcements", 0) for i in group)
            if avg_conf >= 0.7:
                candidates.append(
                    {
                        "tag": tag,
                        "count": len(group),
                        "avg_confidence": avg_conf,
                        "total_reinforcements": total_reinf,
                        "instincts": group,
                    }
                )

    if not candidates:
        print("No promotion candidates found yet.")
        print(f"  Total instincts: {len(instincts)}")
        print("  Need: 3+ instincts with same tag and avg confidence >= 0.7")
        return

    print("Evolution Analysis")
    print("==================")
    print()
    print(
        f"Analyzed {len(instincts)} instincts, found {len(candidates)} promotion candidates:"
    )
    print()

    for i, cand in enumerate(candidates, 1):
        print(f"  {i}. SKILL CANDIDATE: '{cand['tag']}'")
        print(f"     Instincts: {cand['count']}")
        print(f"     Avg Confidence: {cand['avg_confidence']:.2f}")
        print(f"     Total Reinforcements: {cand['total_reinforcements']}")
        print("     Sample triggers:")
        for inst in cand["instincts"][:3]:
            print(f"       - {inst.get('trigger', 'N/A')}")
        print()

    # Identify prune candidates
    prune_candidates = [
        i
        for i in instincts
        if i.get("confidence", 0) < 0.4
        and i.get("reinforcements", 0) == 0
        and not i.get("promoted")
    ]

    if prune_candidates:
        print(f"Prune Candidates: {len(prune_candidates)} low-confidence instincts")
        for inst in prune_candidates[:5]:
            print(
                f"  - {inst.get('id')}: {inst.get('trigger', 'N/A')} (conf: {inst.get('confidence', 0):.2f})"
            )


def main():
    parser = argparse.ArgumentParser(description="GS Orchestrator Instinct CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # list
    list_parser = subparsers.add_parser("list", help="List all instincts")
    list_parser.add_argument("--tag", help="Filter by tag")

    # add
    add_parser = subparsers.add_parser("add", help="Add a new instinct")
    add_parser.add_argument(
        "--trigger", required=True, help="When this instinct activates"
    )
    add_parser.add_argument("--observation", required=True, help="What was observed")
    add_parser.add_argument("--action", required=True, help="What to do about it")
    add_parser.add_argument(
        "--confidence", type=float, default=0.7, help="Confidence 0.0-1.0"
    )
    add_parser.add_argument("--tags", default="", help="Comma-separated tags")
    add_parser.add_argument("--project", default="", help="Project name")

    # remove
    remove_parser = subparsers.add_parser("remove", help="Remove (archive) an instinct")
    remove_parser.add_argument("instinct_id", help="Instinct ID to remove")

    # export
    export_parser = subparsers.add_parser("export", help="Export instincts to JSON")
    export_parser.add_argument("output", help="Output file path")

    # import
    import_parser = subparsers.add_parser("import", help="Import instincts from JSON")
    import_parser.add_argument("input", help="Input file path")

    # stats
    subparsers.add_parser("stats", help="Show library statistics")

    # evolve
    subparsers.add_parser("evolve", help="Analyze and suggest promotions")

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(1)

    commands = {
        "list": cmd_list,
        "add": cmd_add,
        "remove": cmd_remove,
        "export": cmd_export,
        "import": cmd_import,
        "stats": cmd_stats,
        "evolve": cmd_evolve,
    }

    commands[args.command](args)


if __name__ == "__main__":
    main()
