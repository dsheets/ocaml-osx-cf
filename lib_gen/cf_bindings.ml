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

module C(F: Cstubs.FOREIGN) = struct

  module CFIndex = struct
    (* typedef signed long CFIndex; *)
    let typ = long

    let of_int = Signed.Long.of_int

    let to_int = Signed.Long.to_int

    let t = view ~read:to_int ~write:of_int typ
  end

  module CFString = struct

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

      let to_uint32 = Type.StringEncoding.(function
          | MacRoman      -> mac_roman
          | WindowsLatin1 -> windows_latin1
          | ISOLatin1     -> iso_latin1
          | NextStepLatin -> nextstep_latin
          | ASCII         -> ascii
          | Unicode       -> unicode
          | UTF8          -> utf8
          | NonLossyASCII -> nonlossy_ascii
          | UTF16         -> utf16
          | UTF16BE       -> utf16be
          | UTF16LE       -> utf16le
          | UTF32         -> utf32
          | UTF32BE       -> utf32be
          | UTF32LE       -> utf32le
        )

      let of_uint32 i = Type.StringEncoding.(
          if i = mac_roman then MacRoman
          else if i = windows_latin1 then WindowsLatin1
          else if i = iso_latin1 then ISOLatin1
          else if i = nextstep_latin then NextStepLatin
          else if i = ascii then ASCII
          else if i = unicode then Unicode
          else if i = utf8 then UTF8
          else if i = nonlossy_ascii then NonLossyASCII
          else if i = utf16 then UTF16
          else if i = utf16be then UTF16BE
          else if i = utf16le then UTF16LE
          else if i = utf32 then UTF32
          else if i = utf32be then UTF32BE
          else if i = utf32le then UTF32LE
          else failwith "CFString.Encoding.of_uint32 unknown code"
        )

      let t = view ~read:of_uint32 ~write:to_uint32 uint32_t

    end

    (* typedef const struct __CFString *CFStringRef; *)
    let typ = typedef (ptr void) "CFStringRef"

    (* CFIndex CFStringGetLength (
         CFStringRef theString
       );
    *)
    let get_length =
      F.foreign "CFStringGetLength" (typ @-> returning CFIndex.t)

    (* Boolean CFStringGetCString (
        CFStringRef theString,
        char *buffer,
        CFIndex bufferSize,
        CFStringEncoding encoding
       ); *)
    let get_c_string ocaml_typ =
      F.foreign "CFStringGetCString" (
        typ @->
        ocaml_typ @->
        CFIndex.t @->
        Encoding.t @->
        returning bool
      )
    let get_c_string_bytes = get_c_string ocaml_bytes
    let get_c_string_string = get_c_string ocaml_string

    (* CFStringRef CFStringCreateWithBytes(
        CFAllocatorRef alloc,
        const UInt8 *bytes,
        CFIndex numBytes,
        CFStringEncoding encoding,
        Boolean isExternalRepresentation
       ); *)
    let create_with_bytes =
      F.foreign "CFStringCreateWithBytes" (
        ptr_opt void @->
        ptr uint8_t @->
        CFIndex.t @->
        Encoding.t @->
        bool @->
        returning typ
      )
  end

  module CFRange = struct

    (* struct CFRange {
         CFIndex location;
         CFIndex length;
       };
       typedef struct CFRange CFRange;
    *)
    type range
    let struct_typ : range structure typ = structure "CFRange"
    let location = field struct_typ "location" CFIndex.t
    let length = field struct_typ "length" CFIndex.t
    let () = seal struct_typ
    let typ : range structure typ = typedef struct_typ "CFRange"

    type t = {
      location: int;
      length: int;
    }

    let of_t { location = loc; length = len } =
      let t = make typ in
      setf t location loc;
      setf t length len;
      t

    let to_t t =
      let location = getf t location in
      let length = getf t length in
      { location; length }

    let t = view ~read:to_t ~write:of_t typ

  end

  module CFArray = struct

    (* typedef const struct __CFArray *CFArrayRef; *)
    let typ = typedef (ptr void) "CFArrayRef"

    (* CFIndex CFArrayGetCount (
        CFArrayRef theArray
       );
    *)
    let get_count =
      F.foreign "CFArrayGetCount" (typ @-> returning CFIndex.t)

    (* void CFArrayGetValues (
         CFArrayRef theArray,
         CFRange range,
         const void **values
       );
    *)
    let get_values =
      F.foreign "CFArrayGetValues" (
        typ @->
        CFRange.t @->
        typedef (ptr (ptr void)) "const void **" @->
        returning void
      )

    (* CFArrayRef CFArrayCreate (
         CFAllocatorRef allocator,
         const void **values,
         CFIndex numValues,
         const CFArrayCallBacks *callBacks
       );
    *)
    let create =
      F.foreign "CFArrayCreate" (
        ptr_opt void @->
        typedef (ptr (ptr void)) "const void **" @->
        CFIndex.t @->
        ptr_opt void @->
        returning typ)

  end

  module CFTimeInterval = struct

    (* typedef double CFTimeInterval; *)
    let t = double

  end

  module CFAllocate = struct

    (* typedef void ( *CFAllocatorReleaseCallBack) (
       const void *info
       );
    *)
    let release_callback = Foreign.funptr (ptr void @-> returning void)

    (* typedef const void *( *CFAllocatorRetainCallBack) (
       const void *info
       );
    *)
    let retain_callback = Foreign.funptr (ptr void @-> returning (ptr void))

    (* typedef CFStringRef ( *CFAllocatorCopyDescriptionCallBack) (
       const void *info
       );
    *)
    let copy_description_callback =
      Foreign.funptr (ptr void @-> returning CFString.typ)

  end

end
