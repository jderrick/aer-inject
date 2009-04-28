#ifndef UTIL_H
#define UTIL_H

void error_exit(char *fmt, ...);

#define ERROR_EXIT(fmt, x...)					\
	do {							\
		error_exit(fmt, ## x);				\
	} while (0)

#define ERROR_EXIT_ON(check, fmt, x...)				\
	do {							\
		if (check)					\
			error_exit(fmt, ## x);			\
	} while (0)

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(*(x)))

#endif
