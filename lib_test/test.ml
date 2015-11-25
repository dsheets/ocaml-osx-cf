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

module CFArray = struct
  let tests = [
  ]
end

module CFRunLoop = struct
  open Cf.RunLoop

  module RunResult = struct
    type t = RunResult.t

    let pp fmt t =
      Format.pp_print_string fmt (RunResult.to_string t)

    let equal = (=)
  end
  let run_result =
    (module RunResult : Alcotest.TESTABLE with type t = RunResult.t)

  module ObserverActivity = struct
    type t = Observer.Activity.t

    let pp fmt t =
      Format.pp_print_string fmt (Observer.Activity.to_string t)

    let equal = (=)
  end
  let observer_activity =
    (module ObserverActivity : Alcotest.TESTABLE
      with type t = ObserverActivity.t)

  let observe_empty () =
    let expected = Observer.Activity.(ref [
        Entry;
        BeforeTimers;
        BeforeSources;
        Exit;
      ]) in
    let callback runloop activity =
      let next = List.hd !expected in
      expected := List.tl !expected;
      Alcotest.(check observer_activity)
        ("checked next activity is "^(Observer.Activity.to_string next))
        next activity
    in
    let obs = Observer.(create Activity.All callback) in
    let rl = get_current () in
    let () = add_observer rl obs Mode.Default in
    let result = run_in_mode Mode.Default in
    Alcotest.(check run_result) "run_in_mode successfully timed out"
      Cf.RunLoop.RunResult.TimedOut
      result

  let tests = [
    "observe_empty", `Quick, observe_empty;
  ]
end

let tests = [
  "CFString", CFString.tests;
  "CFArray", CFArray.tests;
  "CFRunLoop", CFRunLoop.tests;
]

;;
Alcotest.run "CoreFoundation" tests
