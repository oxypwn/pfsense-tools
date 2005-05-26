#!/usr/bin/env php
<?php
$host = "localhost";
$port = "2601";
$descriptorspec = array(
   0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
   1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
   2 => array("pipe", "w") // stderr is a file to write to
);
$shell = proc_open("/usr/bin/telnet {$host} {$port}", $descriptorspec, $pipes);
stream_set_blocking($pipes[0], FALSE);
stream_set_blocking($pipes[1], FALSE);
stream_set_blocking($pipes[2], FALSE);
$enterstream = true;

function readstdin($pipes, $sleep = 70000) {
   $enterstream = true;
   while ($enterstream) {
      $buffer = fgets($pipes[1], 4096);
      if(!$buffer) usleep($sleep);
      if((!$buffer) and $enterstream) $enterstream = false;
      echo $buffer;
   }
   return true;
}

readstdin($pipes);
fwrite($pipes[0], "test\n");
readstdin($pipes);
fwrite($pipes[0], "?\n");
readstdin($pipes);
fwrite($pipes[0], "exit\n");
readstdin($pipes);
fclose($pipes[0]); fclose($pipes[1]); fclose($pipes[2]);
proc_close($shell);
?>
