.. _fvp_base_revc_2xaemv8a:

ARM Corstone 1000 Fixed Virtual Platforms
############################################

Overview
********

This board configuration will use ARM Fixed Virtual Platforms(FVP) to emulate
a Corstone 1000 hardware platform.

This configuration provides support for a Cortex-A35 Armv8-A 64-bit CPU and
these devices:

* GICv3 interrupt controller
* ARM architected (Generic) timer
* PL011 UART controller

Hardware
********

Supported Features
==================

The following hardware features are supported:

+-----------------------+------------+----------------------+
| Interface             | Controller | Driver/Component     |
+=======================+============+======================+
| GICv3                 | on-chip    | interrupt controller |
+-----------------------+------------+----------------------+
| PL011 UART            | on-chip    | serial port          |
+-----------------------+------------+----------------------+
| ARM GENERIC TIMER     | on-chip    | system clock         |
+-----------------------+------------+----------------------+

The kernel currently does not support other hardware features on this platform.

Devices
========

System Clock
------------

This board configuration uses a system clock frequency of 100 MHz.

Serial Port
-----------

This board configuration uses a single serial communication channel with the
UART0.

Known Problems or Limitations
==============================

Programming and Debugging
*************************

Use this configuration to build basic Zephyr applications and kernel tests in the
ARM FVP emulated environment, for example, with the :ref:`synchronization_sample`:

.. zephyr-app-commands::
   :zephyr-app: samples/synchronization
   :host-os: unix
   :board: fvp_corstone1000_a35
   :goals: build

This will build an image with the synchronization sample app.

To run with FVP, ARMFVP_BIN_PATH must be set before running:

e.g. export ARMFVP_BIN_PATH=<path/to/fvp/dir>

Debugging
=========

Refer to the detailed overview about :ref:`application_debugging`.

Boot Flow
=========

This platorm has a non-trivial boot flow, including system firmware running
at EL3 on the host processor, TF-A, and Secure Enclave(SE) firmware, TF-M.
All needed firmware is built as part of the application build.

For the sake of disambiguation, we will write all firmware names prefixed
with the processor they run on.
For example, se-bl2 refers to the application known as bl2 on the secure
enclave and host-bl31 refers to the TF-A component bl31 (runtime firmware)
running on the host processor.

This platform first boots a ROM bootloader on the SE, se-bl1.
se-bl1 authenticates and loads se-bl2, and may bank-switch it.
se-bl2 auths and loads the following images:
  * se-tfm
  * host-bl2
  * host-fip
se-bl2 starts se-tfm and host-bl2 simaltaniously.
se-tfm is the runtime firmware of the SE.
host-bl2 extracts host-bl31 and host-bl33, the zephyr app, from the fip
and then starts host-bl31.
host-bl31 starts the zephyr app running at EL1.

References
**********

1. (ID070919) Arm® Architecture Reference Manual - Armv8, for Armv8-A architecture profile
2. AArch64 Exception and Interrupt Handling
3. https://developer.arm.com/tools-and-software/simulation-models/fixed-virtual-platforms
