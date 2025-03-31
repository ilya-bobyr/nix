{
  lib,
  getSystem,
  inputs,
  ...
}:

{
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {

      # https://flake.parts/options/git-hooks-nix#options
      pre-commit.settings = {
        hooks = {
          # Conflicts are usually found by other checks, but not those in docs,
          # and potentially other places.
          check-merge-conflicts.enable = true;
          # built-in check-merge-conflicts seems ineffective against those produced by mergify backports
          check-merge-conflicts-2 = {
            enable = true;
            entry = "${pkgs.writeScript "check-merge-conflicts" ''
              #!${pkgs.runtimeShell}
              conflicts=false
              for file in "$@"; do
                if grep --with-filename --line-number -E '^>>>>>>> ' -- "$file"; then
                  conflicts=true
                fi
              done
              if $conflicts; then
                echo "ERROR: found merge/patch conflicts in files"
                exit 1
              fi
            ''}";
          };
          nixfmt-rfc-style = {
            enable = true;
            excludes = [
              # Invalid
              ''^tests/functional/lang/parse-.*\.nix$''

              # Formatting-sensitive
              ''^tests/functional/lang/eval-okay-curpos\.nix$''
              ''^tests/functional/lang/.*comment.*\.nix$''
              ''^tests/functional/lang/.*newline.*\.nix$''
              ''^tests/functional/lang/.*eol.*\.nix$''

              # Syntax tests
              ''^tests/functional/shell.shebang\.nix$''
              ''^tests/functional/lang/eval-okay-ind-string\.nix$''

              # Not supported by nixfmt
              ''^tests/functional/lang/eval-okay-deprecate-cursed-or\.nix$''
              ''^tests/functional/lang/eval-okay-attrs5\.nix$''

              # More syntax tests
              # These tests, or parts of them, should have been parse-* test cases.
              ''^tests/functional/lang/eval-fail-eol-2\.nix$''
              ''^tests/functional/lang/eval-fail-path-slash\.nix$''
              ''^tests/functional/lang/eval-fail-toJSON-non-utf-8\.nix$''
              ''^tests/functional/lang/eval-fail-set\.nix$''
            ];
          };
          clang-format = {
            enable = true;
            # https://github.com/cachix/git-hooks.nix/pull/532
            package = pkgs.llvmPackages_latest.clang-tools;
            excludes = [
              # We don't want to format test data
              # ''tests/(?!nixos/).*\.nix''
              ''^src/[^/]*-tests/data/.*$''

              # Don't format vendored code
              ''^doc/manual/redirects\.js$''
              ''^doc/manual/theme/highlight\.js$''

              # We haven't applied formatting to these files yet
              ''^doc/manual/redirects\.js$''
              ''^doc/manual/theme/highlight\.js$''
              ''^precompiled-headers\.h$''
              ''^src/build-remote/build-remote\.cc$''
              ''^src/libcmd/built-path\.cc$''
              ''^src/libcmd/include/nix/cmd/built-path\.hh$''
              ''^src/libcmd/common-eval-args\.cc$''
              ''^src/libcmd/include/nix/cmd/common-eval-args\.hh$''
              ''^src/libcmd/editor-for\.cc$''
              ''^src/libcmd/installable-attr-path\.cc$''
              ''^src/libcmd/include/nix/cmd/installable-attr-path\.hh$''
              ''^src/libcmd/installable-derived-path\.cc$''
              ''^src/libcmd/include/nix/cmd/installable-derived-path\.hh$''
              ''^src/libcmd/installable-flake\.cc$''
              ''^src/libcmd/include/nix/cmd/installable-flake\.hh$''
              ''^src/libcmd/installable-value\.cc$''
              ''^src/libcmd/include/nix/cmd/installable-value\.hh$''
              ''^src/libcmd/installables\.cc$''
              ''^src/libcmd/include/nix/cmd/installables\.hh$''
              ''^src/libcmd/include/nix/cmd/legacy\.hh$''
              ''^src/libcmd/markdown\.cc$''
              ''^src/libcmd/misc-store-flags\.cc$''
              ''^src/libcmd/repl-interacter\.cc$''
              ''^src/libcmd/include/nix/cmd/repl-interacter\.hh$''
              ''^src/libcmd/repl\.cc$''
              ''^src/libcmd/include/nix/cmd/repl\.hh$''
              ''^src/libexpr-c/nix_api_expr\.cc$''
              ''^src/libexpr-c/nix_api_external\.cc$''
              ''^src/libexpr/attr-path\.cc$''
              ''^src/libexpr/include/nix/expr/attr-path\.hh$''
              ''^src/libexpr/attr-set\.cc$''
              ''^src/libexpr/include/nix/expr/attr-set\.hh$''
              ''^src/libexpr/eval-cache\.cc$''
              ''^src/libexpr/include/nix/expr/eval-cache\.hh$''
              ''^src/libexpr/eval-error\.cc$''
              ''^src/libexpr/include/nix/expr/eval-inline\.hh$''
              ''^src/libexpr/eval-settings\.cc$''
              ''^src/libexpr/include/nix/expr/eval-settings\.hh$''
              ''^src/libexpr/eval\.cc$''
              ''^src/libexpr/include/nix/expr/eval\.hh$''
              ''^src/libexpr/function-trace\.cc$''
              ''^src/libexpr/include/nix/expr/gc-small-vector\.hh$''
              ''^src/libexpr/get-drvs\.cc$''
              ''^src/libexpr/include/nix/expr/get-drvs\.hh$''
              ''^src/libexpr/json-to-value\.cc$''
              ''^src/libexpr/nixexpr\.cc$''
              ''^src/libexpr/include/nix/expr/nixexpr\.hh$''
              ''^src/libexpr/include/nix/expr/parser-state\.hh$''
              ''^src/libexpr/primops\.cc$''
              ''^src/libexpr/include/nix/expr/primops\.hh$''
              ''^src/libexpr/primops/context\.cc$''
              ''^src/libexpr/primops/fetchClosure\.cc$''
              ''^src/libexpr/primops/fetchMercurial\.cc$''
              ''^src/libexpr/primops/fetchTree\.cc$''
              ''^src/libexpr/primops/fromTOML\.cc$''
              ''^src/libexpr/print-ambiguous\.cc$''
              ''^src/libexpr/include/nix/expr/print-ambiguous\.hh$''
              ''^src/libexpr/include/nix/expr/print-options\.hh$''
              ''^src/libexpr/print\.cc$''
              ''^src/libexpr/include/nix/expr/print\.hh$''
              ''^src/libexpr/search-path\.cc$''
              ''^src/libexpr/include/nix/expr/symbol-table\.hh$''
              ''^src/libexpr/value-to-json\.cc$''
              ''^src/libexpr/include/nix/expr/value-to-json\.hh$''
              ''^src/libexpr/value-to-xml\.cc$''
              ''^src/libexpr/include/nix/expr/value-to-xml\.hh$''
              ''^src/libexpr/include/nix/expr/value\.hh$''
              ''^src/libexpr/value/context\.cc$''
              ''^src/libexpr/include/nix/expr/value/context\.hh$''
              ''^src/libfetchers/attrs\.cc$''
              ''^src/libfetchers/cache\.cc$''
              ''^src/libfetchers/include/nix/fetchers/cache\.hh$''
              ''^src/libfetchers/fetch-settings\.cc$''
              ''^src/libfetchers/include/nix/fetchers/fetch-settings\.hh$''
              ''^src/libfetchers/fetch-to-store\.cc$''
              ''^src/libfetchers/fetchers\.cc$''
              ''^src/libfetchers/include/nix/fetchers/fetchers\.hh$''
              ''^src/libfetchers/filtering-source-accessor\.cc$''
              ''^src/libfetchers/include/nix/fetchers/filtering-source-accessor\.hh$''
              ''^src/libfetchers/fs-source-accessor\.cc$''
              ''^src/libfetchers/include/nix/fs-source-accessor\.hh$''
              ''^src/libfetchers/git-utils\.cc$''
              ''^src/libfetchers/include/nix/fetchers/git-utils\.hh$''
              ''^src/libfetchers/github\.cc$''
              ''^src/libfetchers/indirect\.cc$''
              ''^src/libfetchers/memory-source-accessor\.cc$''
              ''^src/libfetchers/path\.cc$''
              ''^src/libfetchers/registry\.cc$''
              ''^src/libfetchers/include/nix/fetchers/registry\.hh$''
              ''^src/libfetchers/tarball\.cc$''
              ''^src/libfetchers/include/nix/fetchers/tarball\.hh$''
              ''^src/libfetchers/git\.cc$''
              ''^src/libfetchers/mercurial\.cc$''
              ''^src/libflake/flake/config\.cc$''
              ''^src/libflake/flake/flake\.cc$''
              ''^src/libflake/include/nix/flake/flake\.hh$''
              ''^src/libflake/flake/flakeref\.cc$''
              ''^src/libflake/include/nix/flake/flakeref\.hh$''
              ''^src/libflake/flake/lockfile\.cc$''
              ''^src/libflake/include/nix/flake/lockfile\.hh$''
              ''^src/libflake/flake/url-name\.cc$''
              ''^src/libmain/common-args\.cc$''
              ''^src/libmain/include/nix/main/common-args\.hh$''
              ''^src/libmain/loggers\.cc$''
              ''^src/libmain/include/nix/main/loggers\.hh$''
              ''^src/libmain/progress-bar\.cc$''
              ''^src/libmain/shared\.cc$''
              ''^src/libmain/include/nix/main/shared\.hh$''
              ''^src/libmain/unix/stack\.cc$''
              ''^src/libstore/binary-cache-store\.cc$''
              ''^src/libstore/include/nix/store/binary-cache-store\.hh$''
              ''^src/libstore/include/nix/store/build-result\.hh$''
              ''^src/libstore/include/nix/store/builtins\.hh$''
              ''^src/libstore/builtins/buildenv\.cc$''
              ''^src/libstore/include/nix/store/builtins/buildenv\.hh$''
              ''^src/libstore/include/nix/store/common-protocol-impl\.hh$''
              ''^src/libstore/common-protocol\.cc$''
              ''^src/libstore/include/nix/store/common-protocol\.hh$''
              ''^src/libstore/include/nix/store/common-ssh-store-config\.hh$''
              ''^src/libstore/content-address\.cc$''
              ''^src/libstore/include/nix/store/content-address\.hh$''
              ''^src/libstore/daemon\.cc$''
              ''^src/libstore/include/nix/store/daemon\.hh$''
              ''^src/libstore/derivations\.cc$''
              ''^src/libstore/include/nix/store/derivations\.hh$''
              ''^src/libstore/derived-path-map\.cc$''
              ''^src/libstore/include/nix/store/derived-path-map\.hh$''
              ''^src/libstore/derived-path\.cc$''
              ''^src/libstore/include/nix/store/derived-path\.hh$''
              ''^src/libstore/downstream-placeholder\.cc$''
              ''^src/libstore/include/nix/store/downstream-placeholder\.hh$''
              ''^src/libstore/dummy-store\.cc$''
              ''^src/libstore/export-import\.cc$''
              ''^src/libstore/filetransfer\.cc$''
              ''^src/libstore/include/nix/store/filetransfer\.hh$''
              ''^src/libstore/include/nix/store/gc-store\.hh$''
              ''^src/libstore/globals\.cc$''
              ''^src/libstore/include/nix/store/globals\.hh$''
              ''^src/libstore/http-binary-cache-store\.cc$''
              ''^src/libstore/legacy-ssh-store\.cc$''
              ''^src/libstore/include/nix/store/legacy-ssh-store\.hh$''
              ''^src/libstore/include/nix/store/length-prefixed-protocol-helper\.hh$''
              ''^src/libstore/linux/personality\.cc$''
              ''^src/libstore/linux/include/nix/store/personality\.hh$''
              ''^src/libstore/local-binary-cache-store\.cc$''
              ''^src/libstore/local-fs-store\.cc$''
              ''^src/libstore/include/nix/store/local-fs-store\.hh$''
              ''^src/libstore/log-store\.cc$''
              ''^src/libstore/include/nix/store/log-store\.hh$''
              ''^src/libstore/machines\.cc$''
              ''^src/libstore/include/nix/store/machines\.hh$''
              ''^src/libstore/make-content-addressed\.cc$''
              ''^src/libstore/include/nix/store/make-content-addressed\.hh$''
              ''^src/libstore/misc\.cc$''
              ''^src/libstore/names\.cc$''
              ''^src/libstore/include/nix/store/names\.hh$''
              ''^src/libstore/nar-accessor\.cc$''
              ''^src/libstore/include/nix/store/nar-accessor\.hh$''
              ''^src/libstore/nar-info-disk-cache\.cc$''
              ''^src/libstore/include/nix/store/nar-info-disk-cache\.hh$''
              ''^src/libstore/nar-info\.cc$''
              ''^src/libstore/include/nix/store/nar-info\.hh$''
              ''^src/libstore/outputs-spec\.cc$''
              ''^src/libstore/include/nix/store/outputs-spec\.hh$''
              ''^src/libstore/parsed-derivations\.cc$''
              ''^src/libstore/path-info\.cc$''
              ''^src/libstore/include/nix/store/path-info\.hh$''
              ''^src/libstore/path-references\.cc$''
              ''^src/libstore/include/nix/store/path-regex\.hh$''
              ''^src/libstore/path-with-outputs\.cc$''
              ''^src/libstore/path\.cc$''
              ''^src/libstore/include/nix/store/path\.hh$''
              ''^src/libstore/pathlocks\.cc$''
              ''^src/libstore/include/nix/store/pathlocks\.hh$''
              ''^src/libstore/profiles\.cc$''
              ''^src/libstore/include/nix/store/profiles\.hh$''
              ''^src/libstore/realisation\.cc$''
              ''^src/libstore/include/nix/store/realisation\.hh$''
              ''^src/libstore/remote-fs-accessor\.cc$''
              ''^src/libstore/include/nix/store/remote-fs-accessor\.hh$''
              ''^src/libstore/include/nix/store/remote-store-connection\.hh$''
              ''^src/libstore/remote-store\.cc$''
              ''^src/libstore/include/nix/store/remote-store\.hh$''
              ''^src/libstore/s3-binary-cache-store\.cc$''
              ''^src/libstore/include/nix/store/s3\.hh$''
              ''^src/libstore/serve-protocol-impl\.cc$''
              ''^src/libstore/include/nix/store/serve-protocol-impl\.hh$''
              ''^src/libstore/serve-protocol\.cc$''
              ''^src/libstore/include/nix/store/serve-protocol\.hh$''
              ''^src/libstore/sqlite\.cc$''
              ''^src/libstore/include/nix/store/sqlite\.hh$''
              ''^src/libstore/ssh-store\.cc$''
              ''^src/libstore/ssh\.cc$''
              ''^src/libstore/include/nix/store/ssh\.hh$''
              ''^src/libstore/store-api\.cc$''
              ''^src/libstore/include/nix/store/store-api\.hh$''
              ''^src/libstore/include/nix/store/store-dir-config\.hh$''
              ''^src/libstore/build/derivation-goal\.cc$''
              ''^src/libstore/include/nix/store/build/derivation-goal\.hh$''
              ''^src/libstore/build/drv-output-substitution-goal\.cc$''
              ''^src/libstore/include/nix/store/build/drv-output-substitution-goal\.hh$''
              ''^src/libstore/build/entry-points\.cc$''
              ''^src/libstore/build/goal\.cc$''
              ''^src/libstore/include/nix/store/build/goal\.hh$''
              ''^src/libstore/unix/build/hook-instance\.cc$''
              ''^src/libstore/unix/build/local-derivation-goal\.cc$''
              ''^src/libstore/unix/include/nix/store/build/local-derivation-goal\.hh$''
              ''^src/libstore/build/substitution-goal\.cc$''
              ''^src/libstore/include/nix/store/build/substitution-goal\.hh$''
              ''^src/libstore/build/worker\.cc$''
              ''^src/libstore/include/nix/store/build/worker\.hh$''
              ''^src/libstore/builtins/fetchurl\.cc$''
              ''^src/libstore/builtins/unpack-channel\.cc$''
              ''^src/libstore/gc\.cc$''
              ''^src/libstore/local-overlay-store\.cc$''
              ''^src/libstore/include/nix/store/local-overlay-store\.hh$''
              ''^src/libstore/local-store\.cc$''
              ''^src/libstore/include/nix/store/local-store\.hh$''
              ''^src/libstore/unix/user-lock\.cc$''
              ''^src/libstore/unix/include/nix/store/user-lock\.hh$''
              ''^src/libstore/optimise-store\.cc$''
              ''^src/libstore/unix/pathlocks\.cc$''
              ''^src/libstore/posix-fs-canonicalise\.cc$''
              ''^src/libstore/include/nix/store/posix-fs-canonicalise\.hh$''
              ''^src/libstore/uds-remote-store\.cc$''
              ''^src/libstore/include/nix/store/uds-remote-store\.hh$''
              ''^src/libstore/windows/build\.cc$''
              ''^src/libstore/include/nix/store/worker-protocol-impl\.hh$''
              ''^src/libstore/worker-protocol\.cc$''
              ''^src/libstore/include/nix/store/worker-protocol\.hh$''
              ''^src/libutil-c/nix_api_util_internal\.h$''
              ''^src/libutil/archive\.cc$''
              ''^src/libutil/include/nix/util/archive\.hh$''
              ''^src/libutil/args\.cc$''
              ''^src/libutil/include/nix/util/args\.hh$''
              ''^src/libutil/include/nix/util/args/root\.hh$''
              ''^src/libutil/include/nix/util/callback\.hh$''
              ''^src/libutil/canon-path\.cc$''
              ''^src/libutil/include/nix/util/canon-path\.hh$''
              ''^src/libutil/include/nix/util/chunked-vector\.hh$''
              ''^src/libutil/include/nix/util/closure\.hh$''
              ''^src/libutil/include/nix/util/comparator\.hh$''
              ''^src/libutil/compute-levels\.cc$''
              ''^src/libutil/include/nix/util/config-impl\.hh$''
              ''^src/libutil/configuration\.cc$''
              ''^src/libutil/include/nix/util/configuration\.hh$''
              ''^src/libutil/current-process\.cc$''
              ''^src/libutil/include/nix/util/current-process\.hh$''
              ''^src/libutil/english\.cc$''
              ''^src/libutil/include/nix/util/english\.hh$''
              ''^src/libutil/error\.cc$''
              ''^src/libutil/include/nix/util/error\.hh$''
              ''^src/libutil/include/nix/util/exit\.hh$''
              ''^src/libutil/experimental-features\.cc$''
              ''^src/libutil/include/nix/util/experimental-features\.hh$''
              ''^src/libutil/file-content-address\.cc$''
              ''^src/libutil/include/nix/util/file-content-address\.hh$''
              ''^src/libutil/file-descriptor\.cc$''
              ''^src/libutil/include/nix/util/file-descriptor\.hh$''
              ''^src/libutil/include/nix/util/file-path-impl\.hh$''
              ''^src/libutil/include/nix/util/file-path\.hh$''
              ''^src/libutil/file-system\.cc$''
              ''^src/libutil/include/nix/util/file-system\.hh$''
              ''^src/libutil/include/nix/util/finally\.hh$''
              ''^src/libutil/include/nix/util/fmt\.hh$''
              ''^src/libutil/fs-sink\.cc$''
              ''^src/libutil/include/nix/util/fs-sink\.hh$''
              ''^src/libutil/git\.cc$''
              ''^src/libutil/include/nix/util/git\.hh$''
              ''^src/libutil/hash\.cc$''
              ''^src/libutil/include/nix/util/hash\.hh$''
              ''^src/libutil/hilite\.cc$''
              ''^src/libutil/include/nix/util/hilite\.hh$''
              ''^src/libutil/source-accessor\.hh$''
              ''^src/libutil/include/nix/util/json-impls\.hh$''
              ''^src/libutil/json-utils\.cc$''
              ''^src/libutil/include/nix/util/json-utils\.hh$''
              ''^src/libutil/linux/cgroup\.cc$''
              ''^src/libutil/linux/namespaces\.cc$''
              ''^src/libutil/logging\.cc$''
              ''^src/libutil/include/nix/util/logging\.hh$''
              ''^src/libutil/include/nix/util/lru-cache\.hh$''
              ''^src/libutil/memory-source-accessor\.cc$''
              ''^src/libutil/include/nix/util/memory-source-accessor\.hh$''
              ''^src/libutil/include/nix/util/pool\.hh$''
              ''^src/libutil/position\.cc$''
              ''^src/libutil/include/nix/util/position\.hh$''
              ''^src/libutil/posix-source-accessor\.cc$''
              ''^src/libutil/include/nix/util/posix-source-accessor\.hh$''
              ''^src/libutil/include/nix/util/processes\.hh$''
              ''^src/libutil/include/nix/util/ref\.hh$''
              ''^src/libutil/references\.cc$''
              ''^src/libutil/include/nix/util/references\.hh$''
              ''^src/libutil/regex-combinators\.hh$''
              ''^src/libutil/serialise\.cc$''
              ''^src/libutil/include/nix/util/serialise\.hh$''
              ''^src/libutil/include/nix/util/signals\.hh$''
              ''^src/libutil/signature/local-keys\.cc$''
              ''^src/libutil/include/nix/util/signature/local-keys\.hh$''
              ''^src/libutil/signature/signer\.cc$''
              ''^src/libutil/include/nix/util/signature/signer\.hh$''
              ''^src/libutil/source-accessor\.cc$''
              ''^src/libutil/include/nix/util/source-accessor\.hh$''
              ''^src/libutil/source-path\.cc$''
              ''^src/libutil/include/nix/util/source-path\.hh$''
              ''^src/libutil/include/nix/util/split\.hh$''
              ''^src/libutil/suggestions\.cc$''
              ''^src/libutil/include/nix/util/suggestions\.hh$''
              ''^src/libutil/include/nix/util/sync\.hh$''
              ''^src/libutil/terminal\.cc$''
              ''^src/libutil/include/nix/util/terminal\.hh$''
              ''^src/libutil/thread-pool\.cc$''
              ''^src/libutil/include/nix/util/thread-pool\.hh$''
              ''^src/libutil/include/nix/util/topo-sort\.hh$''
              ''^src/libutil/include/nix/util/types\.hh$''
              ''^src/libutil/unix/file-descriptor\.cc$''
              ''^src/libutil/unix/file-path\.cc$''
              ''^src/libutil/unix/processes\.cc$''
              ''^src/libutil/unix/include/nix/util/signals-impl\.hh$''
              ''^src/libutil/unix/signals\.cc$''
              ''^src/libutil/unix-domain-socket\.cc$''
              ''^src/libutil/unix/users\.cc$''
              ''^src/libutil/include/nix/util/url-parts\.hh$''
              ''^src/libutil/url\.cc$''
              ''^src/libutil/include/nix/util/url\.hh$''
              ''^src/libutil/users\.cc$''
              ''^src/libutil/include/nix/util/users\.hh$''
              ''^src/libutil/util\.cc$''
              ''^src/libutil/include/nix/util/util\.hh$''
              ''^src/libutil/include/nix/util/variant-wrapper\.hh$''
              ''^src/libutil/widecharwidth/widechar_width\.h$'' # vendored source
              ''^src/libutil/windows/file-descriptor\.cc$''
              ''^src/libutil/windows/file-path\.cc$''
              ''^src/libutil/windows/processes\.cc$''
              ''^src/libutil/windows/users\.cc$''
              ''^src/libutil/windows/windows-error\.cc$''
              ''^src/libutil/windows/include/nix/util/windows-error\.hh$''
              ''^src/libutil/xml-writer\.cc$''
              ''^src/libutil/include/nix/util/xml-writer\.hh$''
              ''^src/nix-build/nix-build\.cc$''
              ''^src/nix-channel/nix-channel\.cc$''
              ''^src/nix-collect-garbage/nix-collect-garbage\.cc$''
              ''^src/nix-env/buildenv.nix$''
              ''^src/nix-env/nix-env\.cc$''
              ''^src/nix-env/user-env\.cc$''
              ''^src/nix-env/user-env\.hh$''
              ''^src/nix-instantiate/nix-instantiate\.cc$''
              ''^src/nix-store/dotgraph\.cc$''
              ''^src/nix-store/graphml\.cc$''
              ''^src/nix-store/nix-store\.cc$''
              ''^src/nix/add-to-store\.cc$''
              ''^src/nix/app\.cc$''
              ''^src/nix/build\.cc$''
              ''^src/nix/bundle\.cc$''
              ''^src/nix/cat\.cc$''
              ''^src/nix/config-check\.cc$''
              ''^src/nix/config\.cc$''
              ''^src/nix/copy\.cc$''
              ''^src/nix/derivation-add\.cc$''
              ''^src/nix/derivation-show\.cc$''
              ''^src/nix/derivation\.cc$''
              ''^src/nix/develop\.cc$''
              ''^src/nix/diff-closures\.cc$''
              ''^src/nix/dump-path\.cc$''
              ''^src/nix/edit\.cc$''
              ''^src/nix/eval\.cc$''
              ''^src/nix/flake\.cc$''
              ''^src/nix/fmt\.cc$''
              ''^src/nix/hash\.cc$''
              ''^src/nix/log\.cc$''
              ''^src/nix/ls\.cc$''
              ''^src/nix/main\.cc$''
              ''^src/nix/make-content-addressed\.cc$''
              ''^src/nix/nar\.cc$''
              ''^src/nix/optimise-store\.cc$''
              ''^src/nix/path-from-hash-part\.cc$''
              ''^src/nix/path-info\.cc$''
              ''^src/nix/prefetch\.cc$''
              ''^src/nix/profile\.cc$''
              ''^src/nix/realisation\.cc$''
              ''^src/nix/registry\.cc$''
              ''^src/nix/repl\.cc$''
              ''^src/nix/run\.cc$''
              ''^src/nix/run\.hh$''
              ''^src/nix/search\.cc$''
              ''^src/nix/sigs\.cc$''
              ''^src/nix/store-copy-log\.cc$''
              ''^src/nix/store-delete\.cc$''
              ''^src/nix/store-gc\.cc$''
              ''^src/nix/store-info\.cc$''
              ''^src/nix/store-repair\.cc$''
              ''^src/nix/store\.cc$''
              ''^src/nix/unix/daemon\.cc$''
              ''^src/nix/upgrade-nix\.cc$''
              ''^src/nix/verify\.cc$''
              ''^src/nix/why-depends\.cc$''

              ''^tests/functional/plugins/plugintest\.cc''
              ''^tests/functional/test-libstoreconsumer/main\.cc''
              ''^tests/nixos/ca-fd-leak/sender\.c''
              ''^tests/nixos/ca-fd-leak/smuggler\.c''
              ''^tests/nixos/user-sandboxing/attacker\.c''
              ''^src/libexpr-test-support/include/nix/expr/tests/libexpr\.hh''
              ''^src/libexpr-test-support/tests/value/context\.cc''
              ''^src/libexpr-test-support/include/nix/expr/tests/value/context\.hh''
              ''^src/libexpr-tests/derived-path\.cc''
              ''^src/libexpr-tests/error_traces\.cc''
              ''^src/libexpr-tests/eval\.cc''
              ''^src/libexpr-tests/json\.cc''
              ''^src/libexpr-tests/main\.cc''
              ''^src/libexpr-tests/primops\.cc''
              ''^src/libexpr-tests/search-path\.cc''
              ''^src/libexpr-tests/trivial\.cc''
              ''^src/libexpr-tests/value/context\.cc''
              ''^src/libexpr-tests/value/print\.cc''
              ''^src/libfetchers-tests/public-key\.cc''
              ''^src/libflake-tests/flakeref\.cc''
              ''^src/libflake-tests/url-name\.cc''
              ''^src/libstore-test-support/tests/derived-path\.cc''
              ''^src/libstore-test-support/include/nix/store/tests/derived-path\.hh''
              ''^src/libstore-test-support/include/nix/store/tests/nix_api_store\.hh''
              ''^src/libstore-test-support/tests/outputs-spec\.cc''
              ''^src/libstore-test-support/include/nix/store/tests/outputs-spec\.hh''
              ''^src/libstore-test-support/path\.cc''
              ''^src/libstore-test-support/include/nix/store/tests/path\.hh''
              ''^src/libstore-test-support/include/nix/store/tests/protocol\.hh''
              ''^src/libstore-tests/common-protocol\.cc''
              ''^src/libstore-tests/content-address\.cc''
              ''^src/libstore-tests/derivation\.cc''
              ''^src/libstore-tests/derived-path\.cc''
              ''^src/libstore-tests/downstream-placeholder\.cc''
              ''^src/libstore-tests/machines\.cc''
              ''^src/libstore-tests/nar-info-disk-cache\.cc''
              ''^src/libstore-tests/nar-info\.cc''
              ''^src/libstore-tests/outputs-spec\.cc''
              ''^src/libstore-tests/path-info\.cc''
              ''^src/libstore-tests/path\.cc''
              ''^src/libstore-tests/serve-protocol\.cc''
              ''^src/libstore-tests/worker-protocol\.cc''
              ''^src/libutil-test-support/include/nix/util/tests/characterization\.hh''
              ''^src/libutil-test-support/hash\.cc''
              ''^src/libutil-test-support/include/nix/util/tests/hash\.hh''
              ''^src/libutil-tests/args\.cc''
              ''^src/libutil-tests/canon-path\.cc''
              ''^src/libutil-tests/chunked-vector\.cc''
              ''^src/libutil-tests/closure\.cc''
              ''^src/libutil-tests/compression\.cc''
              ''^src/libutil-tests/config\.cc''
              ''^src/libutil-tests/file-content-address\.cc''
              ''^src/libutil-tests/git\.cc''
              ''^src/libutil-tests/hash\.cc''
              ''^src/libutil-tests/hilite\.cc''
              ''^src/libutil-tests/json-utils\.cc''
              ''^src/libutil-tests/logging\.cc''
              ''^src/libutil-tests/lru-cache\.cc''
              ''^src/libutil-tests/pool\.cc''
              ''^src/libutil-tests/references\.cc''
              ''^src/libutil-tests/suggestions\.cc''
              ''^src/libutil-tests/url\.cc''
              ''^src/libutil-tests/xml-writer\.cc''
            ];
          };
          shellcheck = {
            enable = true;
            excludes = [
              # We haven't linted these files yet
              ''^config/install-sh$''
              ''^misc/bash/completion\.sh$''
              ''^misc/fish/completion\.fish$''
              ''^misc/zsh/completion\.zsh$''
              ''^scripts/create-darwin-volume\.sh$''
              ''^scripts/install-darwin-multi-user\.sh$''
              ''^scripts/install-multi-user\.sh$''
              ''^scripts/install-systemd-multi-user\.sh$''
              ''^src/nix/get-env\.sh$''
              ''^tests/functional/ca/build-dry\.sh$''
              ''^tests/functional/ca/build-with-garbage-path\.sh$''
              ''^tests/functional/ca/common\.sh$''
              ''^tests/functional/ca/concurrent-builds\.sh$''
              ''^tests/functional/ca/eval-store\.sh$''
              ''^tests/functional/ca/gc\.sh$''
              ''^tests/functional/ca/import-from-derivation\.sh$''
              ''^tests/functional/ca/new-build-cmd\.sh$''
              ''^tests/functional/ca/nix-shell\.sh$''
              ''^tests/functional/ca/post-hook\.sh$''
              ''^tests/functional/ca/recursive\.sh$''
              ''^tests/functional/ca/repl\.sh$''
              ''^tests/functional/ca/selfref-gc\.sh$''
              ''^tests/functional/ca/why-depends\.sh$''
              ''^tests/functional/characterisation-test-infra\.sh$''
              ''^tests/functional/common/vars-and-functions\.sh$''
              ''^tests/functional/completions\.sh$''
              ''^tests/functional/compute-levels\.sh$''
              ''^tests/functional/config\.sh$''
              ''^tests/functional/db-migration\.sh$''
              ''^tests/functional/debugger\.sh$''
              ''^tests/functional/dependencies\.builder0\.sh$''
              ''^tests/functional/dependencies\.sh$''
              ''^tests/functional/dump-db\.sh$''
              ''^tests/functional/dyn-drv/build-built-drv\.sh$''
              ''^tests/functional/dyn-drv/common\.sh$''
              ''^tests/functional/dyn-drv/dep-built-drv\.sh$''
              ''^tests/functional/dyn-drv/eval-outputOf\.sh$''
              ''^tests/functional/dyn-drv/old-daemon-error-hack\.sh$''
              ''^tests/functional/dyn-drv/recursive-mod-json\.sh$''
              ''^tests/functional/eval-store\.sh$''
              ''^tests/functional/export-graph\.sh$''
              ''^tests/functional/export\.sh$''
              ''^tests/functional/extra-sandbox-profile\.sh$''
              ''^tests/functional/fetchClosure\.sh$''
              ''^tests/functional/fetchGit\.sh$''
              ''^tests/functional/fetchGitRefs\.sh$''
              ''^tests/functional/fetchGitSubmodules\.sh$''
              ''^tests/functional/fetchGitVerification\.sh$''
              ''^tests/functional/fetchMercurial\.sh$''
              ''^tests/functional/fixed\.builder1\.sh$''
              ''^tests/functional/fixed\.builder2\.sh$''
              ''^tests/functional/fixed\.sh$''
              ''^tests/functional/flakes/absolute-paths\.sh$''
              ''^tests/functional/flakes/check\.sh$''
              ''^tests/functional/flakes/config\.sh$''
              ''^tests/functional/flakes/flakes\.sh$''
              ''^tests/functional/flakes/follow-paths\.sh$''
              ''^tests/functional/flakes/prefetch\.sh$''
              ''^tests/functional/flakes/run\.sh$''
              ''^tests/functional/flakes/show\.sh$''
              ''^tests/functional/fmt\.sh$''
              ''^tests/functional/fmt\.simple\.sh$''
              ''^tests/functional/gc-auto\.sh$''
              ''^tests/functional/gc-concurrent\.builder\.sh$''
              ''^tests/functional/gc-concurrent\.sh$''
              ''^tests/functional/gc-concurrent2\.builder\.sh$''
              ''^tests/functional/gc-non-blocking\.sh$''
              ''^tests/functional/git-hashing/common\.sh$''
              ''^tests/functional/git-hashing/simple\.sh$''
              ''^tests/functional/hash-convert\.sh$''
              ''^tests/functional/impure-derivations\.sh$''
              ''^tests/functional/impure-eval\.sh$''
              ''^tests/functional/install-darwin\.sh$''
              ''^tests/functional/legacy-ssh-store\.sh$''
              ''^tests/functional/linux-sandbox\.sh$''
              ''^tests/functional/local-overlay-store/add-lower-inner\.sh$''
              ''^tests/functional/local-overlay-store/add-lower\.sh$''
              ''^tests/functional/local-overlay-store/bad-uris\.sh$''
              ''^tests/functional/local-overlay-store/build-inner\.sh$''
              ''^tests/functional/local-overlay-store/build\.sh$''
              ''^tests/functional/local-overlay-store/check-post-init-inner\.sh$''
              ''^tests/functional/local-overlay-store/check-post-init\.sh$''
              ''^tests/functional/local-overlay-store/common\.sh$''
              ''^tests/functional/local-overlay-store/delete-duplicate-inner\.sh$''
              ''^tests/functional/local-overlay-store/delete-duplicate\.sh$''
              ''^tests/functional/local-overlay-store/delete-refs-inner\.sh$''
              ''^tests/functional/local-overlay-store/delete-refs\.sh$''
              ''^tests/functional/local-overlay-store/gc-inner\.sh$''
              ''^tests/functional/local-overlay-store/gc\.sh$''
              ''^tests/functional/local-overlay-store/optimise-inner\.sh$''
              ''^tests/functional/local-overlay-store/optimise\.sh$''
              ''^tests/functional/local-overlay-store/redundant-add-inner\.sh$''
              ''^tests/functional/local-overlay-store/redundant-add\.sh$''
              ''^tests/functional/local-overlay-store/remount\.sh$''
              ''^tests/functional/local-overlay-store/stale-file-handle-inner\.sh$''
              ''^tests/functional/local-overlay-store/stale-file-handle\.sh$''
              ''^tests/functional/local-overlay-store/verify-inner\.sh$''
              ''^tests/functional/local-overlay-store/verify\.sh$''
              ''^tests/functional/logging\.sh$''
              ''^tests/functional/misc\.sh$''
              ''^tests/functional/multiple-outputs\.sh$''
              ''^tests/functional/nested-sandboxing\.sh$''
              ''^tests/functional/nested-sandboxing/command\.sh$''
              ''^tests/functional/nix-build\.sh$''
              ''^tests/functional/nix-channel\.sh$''
              ''^tests/functional/nix-collect-garbage-d\.sh$''
              ''^tests/functional/nix-copy-ssh-common\.sh$''
              ''^tests/functional/nix-copy-ssh-ng\.sh$''
              ''^tests/functional/nix-copy-ssh\.sh$''
              ''^tests/functional/nix-daemon-untrusting\.sh$''
              ''^tests/functional/nix-profile\.sh$''
              ''^tests/functional/nix-shell\.sh$''
              ''^tests/functional/nix_path\.sh$''
              ''^tests/functional/optimise-store\.sh$''
              ''^tests/functional/output-normalization\.sh$''
              ''^tests/functional/parallel\.builder\.sh$''
              ''^tests/functional/parallel\.sh$''
              ''^tests/functional/pass-as-file\.sh$''
              ''^tests/functional/path-from-hash-part\.sh$''
              ''^tests/functional/path-info\.sh$''
              ''^tests/functional/placeholders\.sh$''
              ''^tests/functional/post-hook\.sh$''
              ''^tests/functional/pure-eval\.sh$''
              ''^tests/functional/push-to-store-old\.sh$''
              ''^tests/functional/push-to-store\.sh$''
              ''^tests/functional/read-only-store\.sh$''
              ''^tests/functional/readfile-context\.sh$''
              ''^tests/functional/recursive\.sh$''
              ''^tests/functional/referrers\.sh$''
              ''^tests/functional/remote-store\.sh$''
              ''^tests/functional/repair\.sh$''
              ''^tests/functional/restricted\.sh$''
              ''^tests/functional/search\.sh$''
              ''^tests/functional/secure-drv-outputs\.sh$''
              ''^tests/functional/selfref-gc\.sh$''
              ''^tests/functional/shell\.shebang\.sh$''
              ''^tests/functional/simple\.builder\.sh$''
              ''^tests/functional/supplementary-groups\.sh$''
              ''^tests/functional/toString-path\.sh$''
              ''^tests/functional/user-envs-migration\.sh$''
              ''^tests/functional/user-envs-test-case\.sh$''
              ''^tests/functional/user-envs\.builder\.sh$''
              ''^tests/functional/user-envs\.sh$''
              ''^tests/functional/why-depends\.sh$''
              ''^src/libutil-tests/data/git/check-data\.sh$''
            ];
          };
        };
      };
    };

  # We'll be pulling from this in the main flake
  flake.getSystem = getSystem;
}
