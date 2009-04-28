CFLAGS := -g -Wall
LDFLAGS += -lpthread

OBJ := aer-inject.o util.o aer.tab.o lex.yy.o
GENSRC := aer.tab.c aer.tab.h lex.yy.c
SRC := aer-inject.c util.c
CLEAN := ${OBJ} ${GENSRC} aer-inject .gdb_history .depend
DISTCLEAN := .depend .gdb_history

.PHONY: clean depend

aer-inject: ${OBJ}

lex.yy.c: aer.lex aer.tab.h
	flex aer.lex

aer.tab.c aer.tab.h: aer.y
	bison -d aer.y

clean:
	rm -f ${CLEAN}

distclean: clean
	rm -f ${DISTCLEAN} *~

depend: .depend

.depend: ${SRC} ${GENSRC}
	${CC} -MM -DDEPS_RUN -I. ${SRC} ${GENSRC} > .depend.X && \
		mv .depend.X .depend

Makefile: .depend

include .depend
