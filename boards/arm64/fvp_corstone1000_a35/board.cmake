# Copyright (c) 2021 Carlo Caione <ccaione@baylibre.com>
# SPDX-License-Identifier: Apache-2.0

set(SUPPORTED_EMU_PLATFORMS armfvp)
set(ARMFVP_BIN_NAME FVP_Corstone-1000)

set(PREPROCESSED_FILE_BL2 ${CMAKE_CURRENT_LIST_DIR}/signing_layout_bl2.o)
set(PREPROCESSED_FILE_FIP ${CMAKE_CURRENT_LIST_DIR}/signing_layout_fip.o)
set(CONFIG_TFM_IMAGE_VERSION_BL2 0.0.1+0)
set(CONFIG_TFM_IMAGE_VERSION_FIP 0.0.1+0)
set(CONFIG_TFM_KEY_FILE_BL2 ${CONFIG_TFM_KEY_FILE_NS})
set(CONFIG_TFM_KEY_FILE_FIP ${CONFIG_TFM_KEY_FILE_NS})

set(ARMFVP_FLAGS
  -C se.uart0.out_file=-
  -C se.uart0.unbuffered_output=1
  -C se.trustedBootROMloader.fname=$<TARGET_PROPERTY:tfm,BL1_BIN_FILE>
  -C se.trustedSRAM_config=6
  -C se.BootROM_config=3
  -C board.se_flash_size=8192
  -C diagnostics=4
  --data board.flash0="${APPLICATION_BINARY_DIR}/tfm/bin/bl2_signed.bin"@0x00100000
  --data board.flash0="${APPLICATION_BINARY_DIR}/tfm/bin/tfm_s_signed.bin"@0x00132000
  --data board.flash0="${APPLICATION_BINARY_DIR}/zephyr_ns_signed.bin"@0x0001ee000
)
