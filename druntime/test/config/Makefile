TESTS:=test17421_help test17421_typo test19433 test20459 test22523
include ../common.mak

$(ROOT)/test19433.done: run_args = --DRT-dont-eat-me
$(ROOT)/test20459.done: run_args = foo bar -- --DRT-gcopts=profile:1

$(ROOT)/test22523.done: extra_dflags += -unittest
$(ROOT)/test22523.done: run_args = -- --DRT-testmode=run-main

$(ROOT)/test17421_help.done: run_args = --DRT-gcopt=help
$(ROOT)/test17421_typo.done: run_args = --DRT-gcopts=profile:1

$(ROOT)/test17421_help.done: $(ROOT)/test17421_help$(DOTEXE)
	@echo Testing test17421_help
	$(TIMELIMIT)./$< $(run_args) >$(ROOT)/test17421_help.stdout 2>$(ROOT)/test17421_help.stderr || true
	@if grep -qF "main should not run" $(ROOT)/test17421_help.stdout ; then \
		echo "main was executed unexpectedly" ; \
		exit 1 ; \
	fi
	@if ! grep -qF "GC options are specified" $(ROOT)/test17421_help.stdout ; then \
		echo "help output was not printed" ; \
		exit 1 ; \
	fi
	@touch $@

$(ROOT)/test17421_typo.done: $(ROOT)/test17421_typo$(DOTEXE)
	@echo Testing test17421_typo
	$(TIMELIMIT)./$< $(run_args) >$(ROOT)/test17421_typo.stdout 2>$(ROOT)/test17421_typo.stderr || true
	@if grep -qF "main should not run" $(ROOT)/test17421_typo.stdout ; then \
		echo "main was executed unexpectedly" ; \
		exit 1 ; \
	fi
	@if ! grep -qF "Unknown D runtime option" $(ROOT)/test17421_typo.stderr ; then \
		echo "unknown option error was not printed" ; \
		exit 1 ; \
	fi
	@touch $@
