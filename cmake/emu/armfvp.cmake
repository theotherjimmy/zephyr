# Copyright (c) 2021 Arm Limited (or its affiliates). All rights reserved.
# SPDX-License-Identifier: Apache-2.0

set(armfvp_bin_path $ENV{ARMFVP_BIN_PATH})

find_program(
  ARMFVP
  PATHS ${armfvp_bin_path}
  NO_DEFAULT_PATH
  NAMES ${ARMFVP_BIN_NAME}
  )

if(ARMFVP AND (DEFINED ARMFVP_MIN_VERSION))
  execute_process(
    COMMAND ${ARMFVP} --version
    OUTPUT_VARIABLE out
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  string(REPLACE "\n" "" out ${out})
  string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" armfvp_version ${out})
  if(${armfvp_version} VERSION_LESS ${ARMFVP_MIN_VERSION})
    set(armfvp_warning_message "Found FVP version is \"${armfvp_version}\", "
      "the minimum required by the current board is \"${ARMFVP_MIN_VERSION}\".")
    message(WARNING "${armfvp_warning_message}")
    set(ARMFVP
      COMMAND ${CMAKE_COMMAND} -E echo ${armfvp_warning_message}
      COMMAND ${ARMFVP}
    )
  endif()
endif()

if(CONFIG_BUILD_WITH_TFA AND NOT CONFIG_BUILD_WITH_TFM)
  set(ARMFVP_FLAGS ${ARMFVP_FLAGS}
    -C bp.secureflashloader.fname=${APPLICATION_BINARY_DIR}/tfa${FVP_SECURE_FLASH_FILE}
    -C bp.flashloader0.fname=${APPLICATION_BINARY_DIR}/tfa${FVP_FLASH_FILE}
    )
endif()

if (NOT CONFIG_BUILD_WITH_TFA)
  set(ARMFVP_FLAGS ${ARMFVP_FLAGS}
    -a ${APPLICATION_BINARY_DIR}/zephyr/${KERNEL_ELF_NAME}
    )
endif()


add_custom_target(run_armfvp
  COMMAND
  ${ARMFVP}
  ${ARMFVP_FLAGS}
  DEPENDS ${logical_target_for_zephyr_elf}
  WORKING_DIRECTORY ${APPLICATION_BINARY_DIR}
  COMMENT "${ARMFVP_BIN_NAME}: ${armfvp_version}"
  USES_TERMINAL
  )
