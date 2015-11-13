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

module C(F: Cstubs.Types.TYPE) = struct

  module Encoding = struct
    type t =
      | MacRoman
      | WindowsLatin1
      | ISOLatin1
      | NextStepLatin
      | ASCII
      | Unicode
      | UTF8
      | NonLossyASCII
      | UTF16
      | UTF16BE
      | UTF16LE
      | UTF32
      | UTF32BE
      | UTF32LE

    (* typedef UInt32 CFStringEncoding; *)
    let encoding = F.int64_t

    let mac_roman      = F.constant "kCFStringEncodingMacRoman" encoding
    let windows_latin1 = F.constant "kCFStringEncodingWindowsLatin1" encoding
    let iso_latin1     = F.constant "kCFStringEncodingISOLatin1" encoding
    let nextstep_latin = F.constant "kCFStringEncodingNextStepLatin" encoding
    let ascii          = F.constant "kCFStringEncodingASCII" encoding
    let unicode        = F.constant "kCFStringEncodingUnicode" encoding
    let utf8           = F.constant "kCFStringEncodingUTF8" encoding
    let nonlossy_ascii = F.constant "kCFStringEncodingNonLossyASCII" encoding
    let utf16          = F.constant "kCFStringEncodingUTF16" encoding
    let utf16be        = F.constant "kCFStringEncodingUTF16BE" encoding
    let utf16le        = F.constant "kCFStringEncodingUTF16LE" encoding
    let utf32          = F.constant "kCFStringEncodingUTF32" encoding
    let utf32be        = F.constant "kCFStringEncodingUTF32BE" encoding
    let utf32le        = F.constant "kCFStringEncodingUTF32LE" encoding

    let t = F.enum "CFStringBuiltInEncodings" [
      MacRoman, mac_roman;
      WindowsLatin1, windows_latin1;
      ISOLatin1, iso_latin1;
      NextStepLatin, nextstep_latin;
      ASCII, ascii;
      Unicode, unicode;
      UTF8, utf8;
      NonLossyASCII, nonlossy_ascii;
      UTF16, utf16;
      UTF16BE, utf16be;
      UTF16LE, utf16le;
      UTF32, utf32;
      UTF32BE, utf32be;
      UTF32LE, utf32le;
    ]

  end

end
