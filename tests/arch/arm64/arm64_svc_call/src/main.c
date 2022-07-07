/*
 * Copyright (c) 2022 Arm Limited (or its affiliates). All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#include <ztest.h>

#include "zephyr/arch/arm64/arm-smccc.h"

/* SMC function IDs for Standard Service queries */
#define ARM_STD_SVC_CALL_COUNT		0x8400ff00UL
#define ARM_STD_SVC_VERSION		0x8400ff03UL
#define ARM_STD_SVC_UNKNOWN		0xffffffffUL

#define SMC_UNK				-1

typedef void (*svc_call_method_t)(unsigned long, unsigned long,
				  unsigned long, unsigned long,
				  unsigned long, unsigned long,
				  unsigned long, unsigned long,
				  struct arm_smccc_res *);

#ifdef CONFIG_SVC_CALL_USE_HVC
	svc_call_method_t svc_call = arm_smccc_hvc;
#else
	svc_call_method_t svc_call = arm_smccc_smc;
#endif

ZTEST(arm64_svc_call, test_svc_call_func)
{
	struct arm_smccc_res res;

	svc_call(ARM_STD_SVC_CALL_COUNT, 0, 0, 0, 0, 0, 0, 0, &res);
	zassert_true(res.a0 > 0, "Wrong svc call count");

	svc_call(ARM_STD_SVC_VERSION, 0, 0, 0, 0, 0, 0, 0, &res);
	zassert_true((res.a0 >= 0 && res.a1 >= 0),
		"Wrong svc call version");

	svc_call(ARM_STD_SVC_UNKNOWN, 0, 0, 0, 0, 0, 0, 0, &res);
	zassert_true(res.a0 == SMC_UNK, "Wrong return code from svc call");
}

ZTEST_SUITE(arm64_svc_call, NULL, NULL, NULL, NULL, NULL);
