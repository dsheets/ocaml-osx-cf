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

  let to_chars t =
    let n = C.CFString.get_length t in
    let a = CArray.make char n in
    let _bool = C.CFString.get_C_string t (CArray.start a) n ascii in
    a

  let string_of_chars a =
    (* XXX: how can we do better ? *)
    let n = Array.length a in
    let s = String.create n in
    for i = 0 to n - 1 do s.[i] <- (Array.get a i) done;
    s

  let to_string t =
    string_of_chars (to_chars t)

  let t =
    view ~read:to_string ~write:of_string _t

  let string_of_ptr p =
    let t = !@ (from_voidp _t p) in
    to_string t

end

module Array = struct

  let to_array t =
    let n = get_count t in
    let r = { CFRange.location = 0; length = n } in
    Array.from_ptr (get_values t r) n

    let of_array a =
      let n = Array.length a in
      create None (Array.start a) n None

end
