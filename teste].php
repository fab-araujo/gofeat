<?php
/**
 * Created by PhpStorm.
 * User: fabricio
 * Date: 14/11/17
 * Time: 16:48
 */

$command = 'perl ' . 'seed_subsystem.pl ' . "P72620_SYNY3" . ' 2>&1';
$output = shell_exec($command);
$vSeed = json_decode($output, true);
var_dump($vSeed);
