(*
 * Copyright (c) 2015 David Sheets <sheets@alum.mit.edu>
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

module CFString = struct

  let roundtrip () =
    let s = "Hello, CoreFoundation!" in
    let cfs = Cf.String.Bytes.of_bytes (Bytes.of_string s) in
    let rts = Bytes.to_string (Cf.String.Bytes.to_bytes cfs) in
    Alcotest.(check string) "roundtrip" s rts

  let tests = [
    "roundtrip", `Quick, roundtrip;
  ]
end

let test_cfarray = [

]

let tests = [
  "CFString", CFString.tests;
  "CFArray", test_cfarray;
]

;;
Alcotest.run "CoreFoundation" tests
