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
#include <getopt.h>
#include "aer.h"
#include "util.h"

#define AER_DEV "/dev/aer_inject"

#define CMDLINE_PCI_ID	0x0001

const char *prg_name;

static struct aer_error_inj aerr_cmdline;
static unsigned int cmdline_flags = 0;

void usage(const char *prgname)
{
       fprintf(stderr,
"Usage: %s [-s|--id=PCI_ID] [FILE]\n"
"  or:  %s -v|--version\n"
"  or:  %s -h|--help\n"
"Inject an error into a PCIe device\n"
"\n"
"  PCI_ID       The [<domain>:]<bus>:<slot>.<func> of the device in\n"
"               hex (same as lspci)\n"
"  FILE         Error data file (use stdin if ommitted)\n"
	       , prgname, prgname, prgname);
}

void version(const char *prgname)
{
       fprintf(stderr,
"%s %s\n"
"Copyright 2009 Intel Corporation.\n"
"Huang Ying <ying.huang@intel.com>\n"
"\n"
"This program is free software; you can redistribute it and/or\n"
"modify it under the terms of the GNU General Public License as\n"
"published by the Free Software Foundation; version 2 of the\n"
"License.\n"
	       , prgname, AER_VERSION);
}

void init_aer(struct aer_error_inj *aerr)
{
	memset(aerr, 0, sizeof(struct aer_error_inj));
}

void submit_aer(struct aer_error_inj *err)
{
	int fd, ret;

	if (cmdline_flags & CMDLINE_PCI_ID) {
		err->domain = aerr_cmdline.domain;
		err->bus = aerr_cmdline.bus;
		err->dev = aerr_cmdline.dev;
		err->fn = aerr_cmdline.fn;
	}
	fd = open(AER_DEV, O_WRONLY);
	ERROR_EXIT_ON(fd <= 0, "Failed to open device file: %s", AER_DEV);
	ret = write(fd, err, sizeof(struct aer_error_inj));
	ERROR_EXIT_ON(ret != sizeof(struct aer_error_inj), "Failed to write");
	close(fd);
}

int parse_options(int argc, char ***argv)
{
	int ret;
	int c, opt_index;
	struct option long_options[] = {
		{"version", 0, 0, 'v'},
		{"help", 0, 0, 'h'},
		{"id", 1, 0, 's'},
		{0, 0, 0, 0}
	};

	prg_name = basename(*argv[0]);

	while (1) {
		c = getopt_long(argc, *argv, "vhs:", long_options, &opt_index);
		if (c == -1)
			break;
		switch (c) {
		case 0:
			break;
		case 'v':
			version(prg_name);
			return 1;
		case 's':
			ret = parse_pci_id(optarg, &aerr_cmdline);
			ERROR_EXIT_ON(ret, "Can not parse PCI_ID: %s\n",
				      optarg);
			cmdline_flags |= CMDLINE_PCI_ID;
			break;
		case 'h':
		case '?':
			usage(prg_name);
			return 1;
		default:
			usage(prg_name);
			break;
		}
	}

	(*argv) += optind;
	return 0;
}

int main(int argc, char **argv)
{
	init_aer(&aerr_cmdline);
	if (parse_options(argc, &argv))
		exit(1);
	return parse_data(argv);
}
