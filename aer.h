#ifndef AER_H
#define AER_H

#include <stdint.h>

struct aer_error_inj
{
	int8_t bus;
	int8_t dev;
	int8_t fn;
	int32_t uncor_status;
	int32_t cor_status;
	int32_t header_log0;
	int32_t header_log1;
	int32_t header_log2;
	int32_t header_log3;
	uint16_t domain;
};

#define  PCI_ERR_UNC_TRAIN	0x00000001	/* Training */
#define  PCI_ERR_UNC_DLP	0x00000010	/* Data Link Protocol */
#define  PCI_ERR_UNC_POISON_TLP	0x00001000	/* Poisoned TLP */
#define  PCI_ERR_UNC_FCP	0x00002000	/* Flow Control Protocol */
#define  PCI_ERR_UNC_COMP_TIME	0x00004000	/* Completion Timeout */
#define  PCI_ERR_UNC_COMP_ABORT	0x00008000	/* Completer Abort */
#define  PCI_ERR_UNC_UNX_COMP	0x00010000	/* Unexpected Completion */
#define  PCI_ERR_UNC_RX_OVER	0x00020000	/* Receiver Overflow */
#define  PCI_ERR_UNC_MALF_TLP	0x00040000	/* Malformed TLP */
#define  PCI_ERR_UNC_ECRC	0x00080000	/* ECRC Error Status */
#define  PCI_ERR_UNC_UNSUP	0x00100000	/* Unsupported Request */
#define  PCI_ERR_COR_RCVR	0x00000001	/* Receiver Error Status */
#define  PCI_ERR_COR_BAD_TLP	0x00000040	/* Bad TLP Status */
#define  PCI_ERR_COR_BAD_DLLP	0x00000080	/* Bad DLLP Status */
#define  PCI_ERR_COR_REP_ROLL	0x00000100	/* REPLAY_NUM Rollover */
#define  PCI_ERR_COR_REP_TIMER	0x00001000	/* Replay Timer Timeout */

extern void init_aer(struct aer_error_inj *err);
extern void submit_aer(struct aer_error_inj *err);
extern int parse_pci_id(const char *str, struct aer_error_inj *err);

extern char *filename;
extern int yylineno;
extern void yyerror(char const *msg, ...);
extern int yylex(void);
extern int yyparse(void);

#endif
