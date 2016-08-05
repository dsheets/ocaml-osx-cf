#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let lwt = Conf.with_pkg "lwt"

let opams =
  let lint_deps_excluding = Some ["ctypes-foreign"] in
  [Pkg.opam_file ~lint_deps_excluding "opam"]

let () =
  Pkg.describe ~opams "osx-cf" @@ fun c ->
  let lwt = Conf.value c lwt in
  Ok [
    Pkg.mllib ~api:["Cf"] "lib/osx-cf.mllib";
    Pkg.mllib ~cond:lwt "lwt/osx-cf-lwt.mllib";
    Pkg.clib "lib/libcf_stubs.clib";
    Pkg.test "lib_test/test";
  ]
