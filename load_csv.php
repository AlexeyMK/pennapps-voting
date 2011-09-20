<?php
$row = 0;
$str_len = 140;
$csv = fopen("teams.csv", "r");
$out = fopen("out.txt", "w");
if($csv and $out){
  while(($data = fgetcsv($csv, 1000, ","))){
    if($row){
      $video = explode("watch?v=", $data[4]);
      fwrite($out, "teams.save\n");
      fwrite($out, "  id: $row\n");
      fwrite($out, "  votes: 0\n");
      fwrite($out, "  name: \"$data[1]\"\n");
      fwrite($out, "  url: \"$data[3]\"\n");
      fwrite($out, "  video: \"$video[1]\"\n");
      fwrite($out, "  description: \"\"\"".substr($data[2], 0, $str_len)."\"\"\"\n");
      fwrite($out, "\n");
    }
    $row++;
  }
}
else {
  echo "You did not provide teams.csv or a text file could not be created.";
}
fclose($out);
fclose($csv);

?>
