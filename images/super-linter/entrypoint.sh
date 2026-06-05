#!/bin/sh

set -eu

SUPER_LINTER_ENTRYPOINT="${SUPER_LINTER_ENTRYPOINT:-/action/lib/linter.sh}"

set_default_env() {
	variable_name="$1"
	variable_value="$2"

	eval "is_set=\${${variable_name}+x}"
	if [ -n "${is_set}" ]; then
		return
	fi

	export "${variable_name}=${variable_value}"
}

apply_runtime_defaults() {
	set_default_env RUN_LOCAL true
	set_default_env USE_FIND_ALGORITHM true
	set_default_env LOG_LEVEL WARN
	set_default_env LOG_FILE /github/home/logs
	set_default_env IGNORE_GITIGNORED_FILES true
	set_default_env KUBERNETES_KUBECONFORM_OPTIONS '-schema-location default -schema-location https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
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

main() {
	apply_runtime_defaults
	apply_javascript_toolchain
	apply_python_toolchain
	exec "${SUPER_LINTER_ENTRYPOINT}" "$@"
}

main "$@"
