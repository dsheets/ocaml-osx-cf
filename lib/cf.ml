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

let uint8_0 = Unsigned.UInt8.zero

module Allocator = struct
  let allocate size =
    C.CFAllocator.allocate None size (Unsigned.ULLong.of_int 0)
end

module String = struct

  module Encoding = C.CFString.Encoding

  type t = unit ptr

  let ascii = Encoding.ASCII

  let to_bytes t =
    let n = C.CFString.get_length t in
    let r = C.CFRange.({ location = 0; length = n }) in
    let size_ptr = allocate_n C.CFIndex.t ~count:1 in
    let size = Some size_ptr in
    let chars = C.CFString.get_bytes_ptr t r ascii uint8_0 false None 0 size in
    if chars = 0
    then failwith "Cf.String.to_bytes failed"
    else
      let size = !@size_ptr in
      let b = Bytes.create size in
      let bp = ocaml_bytes_start b in
      let _ =
        C.CFString.get_bytes_bytes t r ascii uint8_0 false bp size None
      in
      b

  let of_bytes b =
    let n = Bytes.length b in
    let bp = ocaml_bytes_start b in
    C.CFString.create_with_bytes_bytes None bp n Encoding.ASCII false

  let bytes = view ~read:to_bytes ~write:of_bytes C.CFString.typ

end

module Array = struct

  type t = unit ptr

  let to_carray t =
    let n = C.CFArray.get_count t in
    let r = { C.CFRange.location = 0; length = n } in
    let m = allocate_n (ptr void) ~count:n in
    C.CFArray.get_values t r m;
    CArray.from_ptr m n

  let of_carray a =
    let n = CArray.length a in
    C.CFArray.create None (CArray.start a) n None

  let carray = view ~read:to_carray ~write:of_carray C.CFArray.typ
end
