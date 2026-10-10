#!/bin/sh

set -eu

SUPER_LINTER_ENTRYPOINT="${SUPER_LINTER_ENTRYPOINT:-/action/lib/linter.sh}"
SUPER_LINTER_CONFIG_DIRECTORY="/usr/local/lib/super-linter"
DEFAULT_KUBERNETES_KUBECONFORM_SCHEMA_LOCATIONS='https://raw.githubusercontent.com/hoverkraft-tech/crds-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

set_default_env() {
	variable_name="$1"
	variable_value="$2"

	eval "is_set=\${${variable_name}+x}"
	if [ -n "${is_set}" ]; then
		return
	fi

	export "${variable_name}=${variable_value}"
}

build_kubernetes_kubeconform_options() {
	options='-schema-location default'

	for schema_location in ${KUBERNETES_KUBECONFORM_SCHEMA_LOCATIONS}; do
		options="${options} -schema-location ${schema_location}"
	done

	echo "${options}"
}

apply_runtime_defaults() {
	if [ "${GITHUB_ACTIONS:-false}" = true ]; then
		set_default_env RUN_LOCAL false
	else
		set_default_env RUN_LOCAL true
	fi

	RUN_LOCAL="$(printf '%s' "${RUN_LOCAL}" | tr '[:upper:]' '[:lower:]')"
	export RUN_LOCAL
	case "${RUN_LOCAL}" in
	true)
		set_default_env USE_FIND_ALGORITHM true
		;;
	false)
		;;
	*)
		echo "Unsupported RUN_LOCAL: ${RUN_LOCAL}" >&2
		exit 1
		;;
	esac

	set_default_env LOG_LEVEL WARN
	set_default_env IGNORE_GITIGNORED_FILES true
	set_default_env KUBERNETES_KUBECONFORM_SCHEMA_LOCATIONS "${DEFAULT_KUBERNETES_KUBECONFORM_SCHEMA_LOCATIONS}"
	set_default_env KUBERNETES_KUBECONFORM_OPTIONS "$(build_kubernetes_kubeconform_options)"
	set_default_env VALIDATE_JAVASCRIPT_TOOLCHAIN biome
	set_default_env VALIDATE_PYTHON_TOOLCHAIN ruff-format
}

apply_biome_toolchain() {
	set_default_env VALIDATE_CSS false
	set_default_env VALIDATE_CSS_PRETTIER false
	set_default_env VALIDATE_GRAPHQL_PRETTIER false
	set_default_env VALIDATE_HTML_PRETTIER false
	set_default_env VALIDATE_JAVASCRIPT_ES false
	set_default_env VALIDATE_JAVASCRIPT_PRETTIER false
	set_default_env VALIDATE_JSON false
	set_default_env VALIDATE_JSON_PRETTIER false
	set_default_env VALIDATE_JSONC false
	set_default_env VALIDATE_JSONC_PRETTIER false
	set_default_env VALIDATE_JSX false
	set_default_env VALIDATE_JSX_PRETTIER false
	set_default_env VALIDATE_TYPESCRIPT_ES false
	set_default_env VALIDATE_TYPESCRIPT_PRETTIER false
	set_default_env VALIDATE_TSX false
	set_default_env VALIDATE_VUE false
	set_default_env VALIDATE_VUE_PRETTIER false
}

apply_eslint_prettier_toolchain() {
	set_default_env VALIDATE_BIOME_FORMAT false
	set_default_env VALIDATE_BIOME_LINT false
}

apply_black_toolchain() {
	set_default_env VALIDATE_PYTHON_RUFF_FORMAT false
}

apply_ruff_format_toolchain() {
	set_default_env VALIDATE_PYTHON_BLACK false
}

apply_javascript_toolchain() {
	case "${VALIDATE_JAVASCRIPT_TOOLCHAIN:-}" in
	"")
		return
		;;
	biome)
		apply_biome_toolchain
		;;
	eslint-prettier)
		apply_eslint_prettier_toolchain
		;;
	*)
		echo "Unsupported VALIDATE_JAVASCRIPT_TOOLCHAIN: ${VALIDATE_JAVASCRIPT_TOOLCHAIN}" >&2
		exit 1
		;;
	esac
}

apply_python_toolchain() {
	case "${VALIDATE_PYTHON_TOOLCHAIN:-}" in
	"")
		return
		;;
	black)
		apply_black_toolchain
		;;
	ruff-format)
		apply_ruff_format_toolchain
		;;
	*)
		echo "Unsupported VALIDATE_PYTHON_TOOLCHAIN: ${VALIDATE_PYTHON_TOOLCHAIN}" >&2
		exit 1
		;;
	esac
}

normalize_commitlint_validation() {
	# With both selectors disabled, preserve Super-Linter's native allowlist mode.
	if [ -z "${VALIDATE_JAVASCRIPT_TOOLCHAIN}" ] && [ -z "${VALIDATE_PYTHON_TOOLCHAIN}" ]; then
		return
	fi

	case "$(printf '%s' "${VALIDATE_GIT_COMMITLINT:-}" | tr '[:upper:]' '[:lower:]')" in
	true)
		# Explicit true switches Super-Linter to an allowlist and conflicts with
		# the toolchain exclusions. Commitlint is already enabled by default.
		unset VALIDATE_GIT_COMMITLINT
		;;
	esac
}

configure_commitlint() {
	case "$(printf '%s' "${VALIDATE_GIT_COMMITLINT:-}" | tr '[:upper:]' '[:lower:]')" in
	false) return ;;
	esac

	# Commitlint searches project configuration before this global fallback.
	# Install at runtime because GitHub Actions mounts its own HOME directory.
	config_directory="${XDG_CONFIG_HOME:-${HOME}/.config}/commitlint"
	for extension in '' .json .yaml .yml .js .ts .cjs .mjs; do
		if [ -e "${config_directory}/config${extension}" ]; then
			return
		fi
	done
	mkdir -p "${config_directory}"
	cp "${SUPER_LINTER_CONFIG_DIRECTORY}/commitlint.config.cjs" "${config_directory}/config.cjs"
}

main() {
	apply_runtime_defaults
	apply_javascript_toolchain
	apply_python_toolchain
	normalize_commitlint_validation
	configure_commitlint
	exec "${SUPER_LINTER_ENTRYPOINT}" "$@"
}

main "$@"
