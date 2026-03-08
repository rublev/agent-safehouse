#!/usr/bin/env bash

run_section_runtime() {
  local policy_shell_init policy_process_control policy_lldb
  local process_debug_dir process_debug_bin process_debug_pid

  section_begin "System Runtime"
  assert_allowed "$POLICY_DEFAULT" "read /usr/bin" /bin/ls /usr/bin
  assert_allowed_if_exists "$POLICY_DEFAULT" "read /opt (Homebrew)" "/opt" /bin/ls /opt
  assert_allowed "$POLICY_DEFAULT" "read system frameworks" /bin/ls /System/Library/Frameworks
  assert_denied_if_exists "$POLICY_DEFAULT" "read /System/Volumes/Data/Library/Keychains denied" "/System/Volumes/Data/Library/Keychains" /bin/ls /System/Volumes/Data/Library/Keychains
  assert_denied_if_exists "$POLICY_DEFAULT" "read /System/Volumes/Data/Users/Shared denied" "/System/Volumes/Data/Users/Shared" /bin/ls /System/Volumes/Data/Users/Shared
  assert_allowed "$POLICY_DEFAULT" "read /dev/null" /bin/cat /dev/null
  assert_allowed "$POLICY_DEFAULT" "read /dev/urandom (1 byte)" /bin/dd if=/dev/urandom bs=1 count=1
  assert_denied_strict "$POLICY_DEFAULT" "write /dev/zero denied" /bin/sh -c 'printf x > /dev/zero'
  assert_allowed "$POLICY_DEFAULT" "read /tmp" /bin/ls /tmp
  assert_allowed_strict "$POLICY_DEFAULT" "write to /tmp" /usr/bin/touch "$TEST_TMP_CANARY"
  assert_denied_if_exists "$POLICY_DEFAULT" "read shell startup (/etc/zshrc) denied by default" "/private/etc/zshrc" /bin/cat /private/etc/zshrc

  policy_shell_init="${TEST_CWD}/policy-runtime-shell-init.sb"
  assert_command_succeeds "--enable=shell-init generates policy with shell startup grants" "$GENERATOR" --output "$policy_shell_init" --enable=shell-init
  assert_allowed_if_exists "$policy_shell_init" "read shell startup (/etc/zshrc) allowed with --enable=shell-init" "/private/etc/zshrc" /bin/cat /private/etc/zshrc
  rm -f "$policy_shell_init"

  section_begin "Clipboard"
  assert_denied_if_exists "$POLICY_DEFAULT" "pbcopy denied by default" "pbcopy" /bin/sh -c 'echo safehouse-test | /usr/bin/pbcopy'

  section_begin "Network"
  assert_allowed_strict "$POLICY_DEFAULT" "outbound HTTPS (curl example.com)" /usr/bin/curl -sf --max-time 5 https://example.com

  section_begin "Process Execution"
  assert_allowed "$POLICY_DEFAULT" "fork + exec (sh -c echo)" /bin/sh -c 'echo sandbox-ok'
  assert_allowed "$POLICY_DEFAULT" "nested subprocesses (sh > sh > echo)" /bin/sh -c '/bin/sh -c "echo nested-ok"'

  section_begin "Host Process Control (Opt-In)"
  policy_process_control="${TEST_CWD}/policy-runtime-process-control.sb"
  process_debug_dir="$(mktemp -d /tmp/safehouse-process-debug.XXXXXX)"
  process_debug_bin="${process_debug_dir}/safehouse-proc-test"
  assert_command_succeeds "--enable=process-control generates policy with host process control grants" "$GENERATOR" --output "$policy_process_control" --enable=process-control
  /bin/ln -s /bin/sleep "$process_debug_bin"
  "$process_debug_bin" 60 >/dev/null 2>&1 &
  process_debug_pid=$!

  assert_denied_strict "$POLICY_DEFAULT" "signal host process denied by default (kill -0)" /bin/kill -0 "$process_debug_pid"
  assert_denied_strict "$POLICY_DEFAULT" "host process enumeration/signalling denied by default (pkill -0)" /usr/bin/pkill -0 -f "$process_debug_bin"
  assert_allowed_strict "$policy_process_control" "signal host process allowed with --enable=process-control (kill -0)" /bin/kill -0 "$process_debug_pid"
  assert_allowed_strict "$policy_process_control" "host process enumeration/signalling allowed with --enable=process-control (pkill -0)" /usr/bin/pkill -0 -f "$process_debug_bin"

  section_begin "LLDB (Opt-In)"
  policy_lldb="${TEST_CWD}/policy-runtime-lldb.sb"
  assert_command_succeeds "--enable=lldb generates policy with LLDB toolchain/debug grants" "$GENERATOR" --output "$policy_lldb" --enable=lldb
  assert_denied_strict "$POLICY_DEFAULT" "lldb --version denied by default" /usr/bin/lldb --version
  assert_denied_strict "$policy_process_control" "lldb --version denied with only --enable=process-control" /usr/bin/lldb --version
  assert_allowed_strict "$policy_lldb" "lldb --version allowed with --enable=lldb" /usr/bin/lldb --version
  assert_allowed_strict "$policy_lldb" "xcrun -f lldb allowed with --enable=lldb" /usr/bin/xcrun -f lldb
  assert_allowed_strict "$policy_lldb" "signal host process allowed with --enable=lldb via implicit process-control (kill -0)" /bin/kill -0 "$process_debug_pid"
  assert_allowed_strict "$policy_lldb" "host process enumeration/signalling allowed with --enable=lldb via implicit process-control (pkill -0)" /usr/bin/pkill -0 -f "$process_debug_bin"

  /bin/kill "$process_debug_pid" >/dev/null 2>&1 || true
  wait "$process_debug_pid" 2>/dev/null || true
  rm -rf "$process_debug_dir" "$policy_process_control" "$policy_lldb"
}

register_section run_section_runtime
