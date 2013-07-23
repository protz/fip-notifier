all: *.ml
	ocamlbuild -use-ocamlfind fip.native
