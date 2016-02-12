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

module RunLoop = struct

  let spin_thread f x =
    let stream, push = Lwt_stream.create () in
    let return x = Lwt_preemptive.run_in_main (fun () ->
      push (Some x);
      Lwt.return_unit
    ) in
    let _thread = Thread.create (fun x -> return (f x)) x in
    Lwt_stream.next stream

  let run_thread setup = spin_thread (fun () ->
    let runloop = try Cf.RunLoop.get_current () with e -> (print_endline "exn in get_current"; exit 7) in
    setup runloop;
    Cf.RunLoop.run ();
    Cf.RunLoop.stop runloop;
    Cf.RunLoop.release runloop
  ) ()

  let run_thread_in_mode ?return_after_source_handled ?seconds mode setup =
    spin_thread (fun () ->
      let runloop = Cf.RunLoop.get_current () in
      setup runloop;
      let result =
        Cf.RunLoop.run_in_mode ?return_after_source_handled ?seconds mode
      in
      Cf.RunLoop.stop runloop;
      Cf.RunLoop.release runloop;
      result
    ) ()

end
  
