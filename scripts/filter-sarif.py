#!/usr/bin/env python3
import json
import pathlib
import sys

sarif_path = pathlib.Path("results.sarif")

if not sarif_path.exists():
    print("results.sarif not found, nothing to filter.")
    sys.exit(0)

with sarif_path.open() as f:
    data = json.load(f)

runs = data.get("runs", [])
total_before = 0
total_after = 0

for run in runs:
    results = run.get("results", [])
    total_before += len(results)

    filtered = []
    for r in results:
        locations = r.get("locations", [])
        keep = True

        for loc in locations:
            phys = loc.get("physicalLocation", {})
            artifact = phys.get("artifactLocation", {})
            uri = artifact.get("uri", "")

            # Drop findings from tests/ and examples/
            if uri.startswith("tests/") or uri.startswith("examples/"):
                keep = False
                break

        if keep:
            filtered.append(r)

    run["results"] = filtered
    total_after += len(filtered)

with sarif_path.open("w") as f:
    json.dump(data, f, indent=2)

print(f"Filtered SARIF results: {total_before} -> {total_after}")
