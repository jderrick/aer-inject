/*
 * Inject PCIE AER error into Linux kernel for testing
 *
 * Copyright 2009 Intel Corporation.
 *     Huang Ying <ying.huang@intel.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; version 2 of the
 * License.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include "aer.h"
#include "util.h"

#define AER_DEV "/dev/aer_inject"

void init_aer(struct aer_error_inj *aerr)
{
	memset(aerr, 0, sizeof(struct aer_error_inj));
}

void submit_aer(struct aer_error_inj *err)
{
	int fd, ret;

	fd = open(AER_DEV, O_WRONLY);
	ERROR_EXIT_ON(fd <= 0, "Failed to open device file: %s", AER_DEV);
	ret = write(fd, err, sizeof(struct aer_error_inj));
	ERROR_EXIT_ON(ret != sizeof(struct aer_error_inj), "Failed to write");
	close(fd);
}
