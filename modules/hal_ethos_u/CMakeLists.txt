#
# Copyright (c) 2021 Arm Limited.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cmake_policy(SET CMP0079 NEW)

if(CONFIG_ARM_ETHOS_U AND CONFIG_MULTITHREADING)
    set(ETHOSU_TARGET_NPU_CONFIG ${CONFIG_ARM_ETHOS_U_NPU_NAME})

    add_subdirectory(${ZEPHYR_CURRENT_MODULE_DIR} ethos-u-core-driver)

    target_link_libraries(ethosu_core_driver PUBLIC
       zephyr_interface)

    zephyr_link_libraries(ethosu_core_driver)

    # Add init files
    zephyr_sources(
        init.c)
endif()
