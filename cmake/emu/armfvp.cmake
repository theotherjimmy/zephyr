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

if(CONFIG_ARMV8_A_NS AND NOT CONFIG_BUILD_WITH_TFM)
  foreach(filetype BL1 FIP)
    if ((NOT DEFINED ARMFVP_${filetype}_FILE) AND (EXISTS "$ENV{ARMFVP_${filetype}_FILE}"))
      set(ARMFVP_${filetype}_FILE "$ENV{ARMFVP_${filetype}_FILE}" CACHE FILEPATH
        "ARM FVP ${filetype} File specified in environment"
	)
    endif()

    if(NOT EXISTS "${ARMFVP_${filetype}_FILE}")
      string(TOLOWER ${filetype} filename)
      message(FATAL_ERROR "Please specify ARMFVP_${filetype}_FILE in environment "
        "or with -DARMFVP_${filetype}_FILE=</path/to/${filename}.bin>")
    endif()
  endforeach()

  set(ARMFVP_FLAGS ${ARMFVP_FLAGS}
    -C bp.secureflashloader.fname=${ARMFVP_BL1_FILE}
    -C bp.flashloader0.fname=${ARMFVP_FIP_FILE}
    --data cluster0.cpu0="${APPLICATION_BINARY_DIR}/zephyr/${KERNEL_BIN_NAME}"@0x88000000
    )
endif()

if (NOT CONFIG_ARMV8_A_NS)
  set(ARMFVP_FLAGS ${ARMFVP_FLAGS}
    -a ${APPLICATION_BINARY_DIR}/zephyr/${KERNEL_ELF_NAME}
    )
endif()

if(CONFIG_ARMV8_A_NS AND CONFIG_BUILD_WITH_TFM)
  foreach(filetype FIP)
    if ((NOT DEFINED ARMFVP_${filetype}_FILE) AND (EXISTS "$ENV{ARMFVP_${filetype}_FILE}"))
      set(ARMFVP_${filetype}_FILE "$ENV{ARMFVP_${filetype}_FILE}" CACHE FILEPATH
        "ARM FVP ${filetype} File specified in environment"
	)
    endif()

    if(NOT EXISTS "${ARMFVP_${filetype}_FILE}")
      string(TOLOWER ${filetype} filename)
      message(FATAL_ERROR "Please specify ARMFVP_${filetype}_FILE in environment "
        "or with -DARMFVP_${filetype}_FILE=</path/to/${filename}.bin>")
    endif()
  endforeach()
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
