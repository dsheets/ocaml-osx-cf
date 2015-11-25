#include <caml/mlvalues.h>
#include <caml/threads.h>
#include <CoreServices/CoreServices.h>

void osx_cf_run_loop_run() {
  caml_release_runtime_system();
  CFRunLoopRun();
  caml_acquire_runtime_system();
}

CFRunLoopRunResult osx_cf_run_loop_run_in_mode
(CFStringRef mode, CFTimeInterval seconds, Boolean returnAfterSourceHandled) {
  CFRunLoopRunResult r;
  caml_release_runtime_system();
  r = CFRunLoopRunInMode(mode, seconds, returnAfterSourceHandled);
  caml_acquire_runtime_system();
  return r;
}
