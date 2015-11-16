(*
 * Copyright (c) 2015 David Sheets <sheets@alum.mit.edu>
 * Copyright (c) 2014 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

open Ctypes

module Type = Cf_types.C(Cf_types_detected)
module C = Cf_bindings.C(Cf_generated)

module String = struct

  module Encoding = C.CFString.Encoding

  let to_bytes t =
    let n = C.CFString.get_length t in
    let b = Bytes.create n in
    let bp = ocaml_bytes_start b in
    let ok = C.CFString.get_c_string_bytes t bp n Encoding.ASCII in
    if ok then b else failwith "Cf.String.to_bytes failed"

  let of_bytes b =
    let n = Bytes.length b in
    let bp = coerce ocaml_bytes (ptr uint8_t) (ocaml_bytes_start b) in
    C.CFString.create_with_bytes None bp n Encoding.ASCII false

  let bytes = view ~read:to_bytes ~write:of_bytes C.CFString.typ

end

module Array = struct

  let to_carray t =
    let n = C.CFArray.get_count t in
    let r = { C.CFRange.location = 0; length = n } in
    let m = allocate_n (ptr void) ~count:n in
    C.CFArray.get_values t r m;
    CArray.from_ptr m n

  let of_carray a =
    let n = CArray.length a in
    C.CFArray.create None (CArray.start a) n None

end
