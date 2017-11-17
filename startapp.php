<?php

exec("nohup curl http://computationalbiology.ufpa.br/gofeat/index/botsendblast > /dev/null 2>&1 &");
exec("nohup curl http://computationalbiology.ufpa.br/gofeat/index/botgetblast > /dev/null 2>&1 &");

$sOut = shell_exec("ps aux | grep curl | awk '{print $2}'");
$vOut = explode("\n", $sOut);
foreach($vOut as $sOut){
    if($sOut){
        shell_exec("kill -9 ".trim($sOut));
    }
}
?>
