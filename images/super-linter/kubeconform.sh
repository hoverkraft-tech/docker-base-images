#!/usr/bin/env bash

set -euo pipefail

# Super-Linter discovers template files as Kubernetes YAML. Validate their
# rendered chart instead, while leaving ordinary Kubeconform arguments intact.
declare -a arguments=()
declare -A rendered=()
temporary_directory=""
trap '[[ -z "$temporary_directory" ]] || rm -rf "$temporary_directory"' EXIT

chart_for_template() {
	local file directory
	file="$(realpath "$1")"
	directory="$(dirname "$file")"
	while [[ "$directory" != / ]]; do
		if [[ -f "$directory/Chart.yaml" && "$file" == "$directory/templates/"* ]]; then
			printf '%s\n' "$directory"
			return
		fi
		directory="$(dirname "$directory")"
	done
	return 1
}

render_chart() {
	local chart="$1" destination scenario repository repositories index=0
	if [[ -z "$temporary_directory" ]]; then
		temporary_directory="$(mktemp -d)"
	fi
	destination="$temporary_directory/${#rendered[@]}"
	mkdir -p "$destination"
	cp -a "$chart" "$destination/chart"
	# Dependencies are restored from the lock without modifying the source chart.
	if [[ -f "$destination/chart/Chart.lock" ]]; then
		repositories="$(yq -r '.dependencies[] | .repository' "$destination/chart/Chart.yaml")"
		while IFS= read -r repository; do
			if [[ "$repository" == https://* || "$repository" == http://* ]]; then
				helm repo add "lint-$index" "$repository" \
					--repository-config "$destination/repositories.yaml" \
					--repository-cache "$destination/repository-cache" >/dev/null
				index=$((index + 1))
			fi
		done <<<"$repositories"
		helm dependency build "$destination/chart" --skip-refresh \
			--repository-config "$destination/repositories.yaml" \
			--repository-cache "$destination/repository-cache" >/dev/null
	fi
	shopt -s nullglob
	local scenarios=("$destination/chart/ci/"*-values.yaml)
	if [[ ${#scenarios[@]} -eq 0 ]]; then
		scenarios=("")
	fi
	index=0
	for scenario in "${scenarios[@]}"; do
		local values=()
		[[ -z "$scenario" ]] || values=(--values "$scenario")
		printf 'Validating Helm chart %s (%s)\n' "$chart" "${scenario:-default values}" >&2
		helm template lint "$destination/chart" --namespace lint \
			"${values[@]}" >"$destination/scenario-$index.yaml"
		arguments+=("$destination/scenario-$index.yaml")
		index=$((index + 1))
	done
	rendered["$chart"]=true
}

option_value=false
for argument in "$@"; do
	if [[ "$option_value" == true ]]; then
		arguments+=("$argument")
		option_value=false
		continue
	fi
	case "$argument" in
	-cache | --cache | -kubernetes-version | --kubernetes-version | -n | --n | -output | --output | -schema-location | --schema-location | -skip | --skip | -reject | --reject | -ignore-filename-pattern | --ignore-filename-pattern)
		option_value=true
		arguments+=("$argument")
		;;
	-*) arguments+=("$argument") ;;
	*)
		if [[ -f "$argument" ]] && chart="$(chart_for_template "$argument")"; then
			if [[ -z "${rendered[$chart]:-}" ]]; then
				render_chart "$chart"
			fi
		else
			arguments+=("$argument")
		fi
		;;
	esac
done

/usr/bin/kubeconform "${arguments[@]}"
