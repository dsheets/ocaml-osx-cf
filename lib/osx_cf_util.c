#include <caml/mlvalues.h>
#include <caml/threads.h>
#include <CoreServices/CoreServices.h>

void osx_cf_run_loop_run() {
  caml_release_runtime_system();
  CFRunLoopRun();
  caml_acquire_runtime_system();
}
