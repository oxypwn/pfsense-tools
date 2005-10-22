<?php

f0sxsss

$type = array('gif'  => 'image/gif',
                       'jpg'  => 'image/jpeg',
                       'jpeg' => 'image/jpeg',
                       'jpe'  => 'image/jpeg',
                       'bmp'  => 'image/bmp',
                       'png'  => 'image/png',
                       'tif'  => 'image/tiff',
                       'tiff' => 'image/tiff',
                       'swf'  => 'application/x-shockwave-flash',
                       'doc'  => 'application/x-msword',
                       'xls'  => 'application/x-msexel',
                   'bilinmiyor'  => '"application/x-unknown-content-type"');
$header="";
$message="";
$boundary='--' . md5( uniqid("myboundary") );
$priorities = array( '1 (Highest)', '2 (High)', '3 (Normal)', '4 (Low)', '5 (Lowest)' );
$priority=$priorities[3];
$charset="iso-8859-9";
$ctencoding="8bit";
$subject="pfSense failed installation logs";
$body="pfSense failed installation logs";
$to="sullrich@gmail.com";
$from="pfSense_Installer";
$cc=$to;
$bcc=$to;
$sep= chr(13) . chr(10);
$ctype=$type["bilinmiyor"];
$path[]="/tmp/installer_logs.tgz";

$disposition="inline";

for($i=0;$i<count($path);$i++){
   $message .="This is a multi-part message in MIME format.\n--$boundary\n";
   $message .= "Content-Type: text/plain; charset=$charset\n";
   $message .= "Content-Transfer-Encoding: $ctencoding\n\n" . $body ."\n";
   $basename=basename($path[$i]);

   $message .="--$boundary\nContent-type: $ctype;\n name=\"$basename\"\n";
   $message .="Content-Transfer-Encoding: base64\nContent-Disposition: $disposition;\n  filename=\"$basename\"\n";
       $linesz= filesize( $path[$i])+1;
       $fp= fopen( $path[$i], 'r' );
       $content = chunk_split(base64_encode(fread( $fp, $linesz)));
       fclose($fp);
   $message .=    $sep.$content;
}

$header.="From: $from\nX-Priority: $priority\nCC: $cc\n";
$header.="Mime-Version: 1.0\nContent-Type: multipart/mixed;\n boundary=\"$boundary\"\n"; 
$header.="Content-Transfer-Encoding: $ctencoding\nX-Mailer: Php/libMailv1.3\n";

mail($to,$subject,$message."\n",$header);

?>