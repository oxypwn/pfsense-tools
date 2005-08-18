AC_ARG_WITH(upload_progress_meter,[],[enable_upload_progress_meter=$withval])

PHP_ARG_ENABLE(upload_progress_meter, whether to enable upload_progress_meter support,
[  --enable-upload_progress_meter        Enable upload_progress_meter support])



if test "$PHP_UPLOAD_PROGRESS_METER" != "no"; then
  AC_DEFINE(HAVE_UPLOAD_PROGRESS_METER, 1, [ ])
  PHP_NEW_EXTENSION(upload_progress_meter, upload_progress_meter.c, $ext_shared)
fi

