{application, common,
 [{description, "Library modules for the cluster"},
  {vsn, "0.1"},
  {modules, [dispatcher, statistician, io_module, fs_io_module]},
  {registered, [dispatcher, statistician, io_module]},
  {applications, [kernel, stdlib]}
 ]}.
