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

module Types = Cf_types.C(Cf_types_detected)
module C = Cf_bindings.C(Cf_generated)

module CamlBytes = Bytes

module type PTR_TYP = sig

  type t

  val typ : t typ

end

module Type = struct

  let release = C.CFType.release

  let retain = C.CFType.retain

end

module VoidPtr = struct

  type t = unit ptr

  let typ = ptr void

end

let uint8_0 = Unsigned.UInt8.zero

module String = struct

  module Encoding = C.CFString.Encoding

  let ascii = Encoding.ASCII

  type t = unit ptr
  type cfstring = t

  let typ = ptr void

  module Bytes = struct

    type t = bytes

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
      let open C.CFString in
      let cf = create_with_bytes_bytes None bp n Encoding.ASCII false in
      Gc.finalise Type.release cf;
      cf

    let typ = view ~read:to_bytes ~write:of_bytes C.CFString.typ

  end

  module String = struct

    type t = string

    let to_string t = CamlBytes.to_string (Bytes.to_bytes t)

    let of_string s = Bytes.of_bytes (CamlBytes.of_string s)

    let typ = view ~read:to_string ~write:of_string C.CFString.typ

  end

end

module Array = struct

  type t = unit ptr
  type cfarray = t

  module CArray = struct

    module Make(T : PTR_TYP) = struct

      type t = T.t CArray.t

      let read t =
        let n = C.CFArray.get_count t in
        let r = { C.CFRange.location = 0; length = n } in
        let m = allocate_n T.typ ~count:n in
        C.CFArray.get_values t r (coerce (ptr T.typ) (ptr (ptr void)) m);
        CArray.from_ptr m n

      let write a =
        let n = CArray.length a in
        let p = CArray.start a in
        let open C.CFArray in
        let cf = create None (coerce (ptr T.typ) (ptr (ptr void)) p) n None in
        Gc.finalise Type.release cf;
        cf

      let typ = view ~read ~write C.CFArray.typ

    end

    module VoidPtrCArray = Make(VoidPtr)

    type t = VoidPtrCArray.t

    let to_carray = VoidPtrCArray.read

    let of_carray = VoidPtrCArray.write

    let typ = VoidPtrCArray.typ

  end

  module List = struct

    module Make(T : PTR_TYP) = struct

      type t = T.t list

      module CArrayM = CArray.Make(T)

      let read t =
        let n = Ctypes.CArray.length t in
        let list = ref [] in
        for i = 0 to n do
          list := Ctypes.CArray.get t i :: !list
        done;
        List.rev !list

      let write list =
        let count = List.length list in
        let m = allocate_n T.typ ~count in
        ignore (List.fold_left (fun p next ->
          p <-@ next;
          p +@ 1
        ) m list);
        Ctypes.CArray.from_ptr m count

      let typ = view ~read ~write CArrayM.typ

    end

    module VoidPtrList = Make(VoidPtr)

    type t = VoidPtrList.t

    let to_list cf = VoidPtrList.read (CArray.to_carray cf)

    let of_list list = CArray.of_carray (VoidPtrList.write list)

    let typ = VoidPtrList.typ

  end

end

module Index = struct

  type t = int

  let typ = C.CFIndex.t

end

module TimeInterval = struct

  type t = float

  let typ = C.CFTimeInterval.t

end

module Allocator = struct

  type retain_callback_t = unit ptr -> unit ptr
  type release_callback_t = unit ptr -> unit
  type copy_description_callback_t = unit ptr -> bytes

  let retain_callback_typ = Foreign.funptr (ptr void @-> returning (ptr void))
  let release_callback_typ = Foreign.funptr (ptr void @-> returning void)
  let copy_description_callback_typ =
    Foreign.funptr (ptr void @-> returning String.Bytes.typ)

  let allocate size =
    C.CFAllocator.allocate None size (Unsigned.ULLong.of_int 0)
end

module RunLoop = struct

  module Mode = struct
    type t =
      | Default
      | CommonModes
      | Mode of string

    let default = !@ C.CFRunLoop.Mode.default
    let common_modes = !@ C.CFRunLoop.Mode.common_modes

    let of_cfstring s =
      if s = default then Default
      else if s = common_modes then CommonModes
      else Mode (Bytes.to_string (String.Bytes.to_bytes s))

    let to_cfstring = function
      | Default -> default
      | CommonModes -> common_modes
      | Mode s -> String.Bytes.of_bytes (Bytes.of_string s)

    let typ = view ~read:of_cfstring ~write:to_cfstring String.typ

  end

  type t = unit ptr

  let typ = C.CFRunLoop.typ

  let run = C.CFRunLoop.run

  let get_current () : t =
    let cf = C.CFRunLoop.get_current () in
    let cf = Type.retain cf in
    Gc.finalise Type.release cf;
    cf

end
