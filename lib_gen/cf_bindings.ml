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

    (* typedef const struct __CFString *CFStringRef; *)
    type typ__CFString = unit ptr
    let typ__CFString: typ__CFString typ = ptr void
    let typ = ptr typ__CFString

    (* CFIndex CFStringGetLength (
         CFStringRef theString
       );
    *)
    let get_length =
      F.foreign "CFStringGetLength" (typ @-> returning CFIndex.t)

    (* CFStringRef CFSTR (
          const char *cStr
       );
    *)
    let cfstr =
      F.foreign "CFSTR" (string @-> returning typ)

    let of_string = cfstr

    (* Boolean CFStringGetCString (
        CFStringRef theString,
        char *buffer,
        CFIndex bufferSize,
        CFStringEncoding encoding
       ); *)
    let get_C_string =
      F.foreign "CFStringGetCString" (
        typ @->
        ptr char @->
        CFIndex.t @->
        Type.Encoding.t @->
        returning bool
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
    let typ : range structure typ = structure "CFRange"
    let location = field typ "location" CFIndex.t
    let length = field typ "length" CFIndex.t
    let () = seal typ

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
    type typ__CFArray = unit ptr
    let typ__CFArray: typ__CFArray typ = ptr void
    let typ = ptr typ__CFArray

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
        returning (ptr (ptr void))
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
        ptr (ptr void) @->
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
