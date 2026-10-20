#!/bin/sh

# Extends Super-Linter's find-based file discovery so it never descends into
# large, always-ignored package-manager stores and caches.
#
# Super-Linter prunes a fixed set of vendored directories (node_modules, .venv,
# __pycache__, ...) when USE_FIND_ALGORITHM=true, but it misses content stores
# such as pnpm's ".pnpm-store". Those stores hold tens of thousands of files and
# are always Git-ignored, yet "find" still enumerates every entry and then runs
# "git check-ignore" once per file. On local runs (where USE_FIND_ALGORITHM is
# the default) this dominates runtime. Pruning the stores at the "find" level
# keeps untracked-file linting intact while avoiding the per-file cost.

set -eu

target="${1:-/action/lib/functions/buildFileList.sh}"

if [ ! -f "${target}" ]; then
	echo "patch-find-prune: target not found: ${target}" >&2
	exit 1
fi

if grep -q "pnpm-store' -prune" "${target}"; then
	echo "patch-find-prune: already applied to ${target}"
	exit 0
fi

if ! grep -q "node_modules' -prune" "${target}"; then
	echo "patch-find-prune: expected 'node_modules' find-prune anchor is missing in ${target}." >&2
	echo "patch-find-prune: Super-Linter file discovery changed; review this patch." >&2
	exit 1
fi

program="$(mktemp)"
output="$(mktemp)"
trap 'rm -f "${program}" "${output}"' EXIT

cat >"${program}" <<'AWK'
{ print }
!inserted && index($0, "node_modules'") && index($0, "-prune") {
	print "        -not \\( -path '*/\\.pnpm-store' -prune \\) \\"
	print "        -not \\( -path '*/\\.yarn' -prune \\) \\"
	print "        -not \\( -path '*/\\.npm' -prune \\) \\"
	inserted = 1
}
AWK

awk -f "${program}" "${target}" >"${output}"
cat "${output}" >"${target}"

if ! grep -q "pnpm-store' -prune" "${target}"; then
	echo "patch-find-prune: failed to apply the find-prune patch to ${target}." >&2
	exit 1
fi

echo "patch-find-prune: applied to ${target}"
