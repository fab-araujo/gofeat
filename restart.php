<?php
$sOut = shell_exec("ps aux | grep apache | awk '{print $2}'");
$vOut = explode("\n", $sOut);
foreach($vOut as $sOut){
    if($sOut){
        $procB4d = "lsof -p ".trim($sOut)." | grep 'gofeat' ";
        $sOut2 = shell_exec($procB4d);
        if($sOut2){
            $sOut3 = shell_exec("kill -9 ".trim($sOut));
        }
    }
}
$output = shell_exec("wget -bqc http://computationalbiology.ufpa.br/gofeat/index/botblast &");

$pid = explode("pid", $output);
$pid = $pid[1];
$pid = str_replace('.','',trim($pid));