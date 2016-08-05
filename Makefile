.PHONY: all test clean

LWT=$(shell opam config var lwt:installed)

all:
	ocaml pkg/pkg.ml build --with-lwt $(LWT)

test:
	ocaml pkg/pkg.ml build --with-lwt $(LWT) --tests true
	ocaml pkg/pkg.ml test

clean:
	rm -rf _build
