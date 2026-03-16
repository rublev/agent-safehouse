#!/usr/bin/env bats
# bats file_tags=suite:policy

load ../../test_helper.bash

@test "[POLICY-ONLY] enable=microphone includes its optional profile source and no GUI dependency" {
  local profile
  profile="$(safehouse_profile --enable=microphone)"

  sft_assert_includes_source "$profile" "55-integrations-optional/microphone.sb"
  sft_assert_omits_source "$profile" "55-integrations-optional/macos-gui.sb"
  sft_assert_omits_source "$profile" "55-integrations-optional/electron.sb"
}
