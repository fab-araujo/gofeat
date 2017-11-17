<?php

class Plugin_Imagem {

    public function upload($upload = 'arquivo') {
        //var_dump($form);
        
        $sPath = $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') .'/data/';
        $adapter = new Zend_File_Transfer_Adapter_Http();
        //echo $sPath;exit;
        $adapter->setDestination($sPath);
        $files = $adapter->getFileInfo();

        foreach ($files as $file => $info) {
            if ($info["name"] <> '') {
                if($file==$upload){

                    $nome = md5(uniqid(time(), true)) . "." . end(explode('.', $info["name"]));

                    $adapter->addFilter('Rename', $sPath . $nome, $file);

                    if ($adapter->isUploaded($file) && $adapter->isValid($file)) {
                        $adapter->receive($file);
                        $pont = fopen($sPath . $nome, "r");
                        $dados = (fread($pont, filesize($sPath . $nome)));
                        fclose($pont);
                        $this->_data["arquivo"] = addslashes($dados);
                        $this->_data["formato"] = $info["type"];

                        $arquivo = $nome;
                        //$this->_dbSitePaginaArquivo->save(array('ID_PAGINA'=>$id_pagina,'NOME_ARQUIVO'=>$nome));
                    }
                }

            }
        }
        if ($arquivo) {
            return $arquivo;
        } else {
            return false;
        }
    }
    
    public function resize($imagem,$largura = NULL,$altura = NULL,$path_tamanho = ''){
    	$img_origem = $imagem;
    	//$pasta_destino = ($path_tamanho) ? $this->pasta.$path_tamanho."/" : $this->pasta;
    	$iFotoOriginal = $img = imagecreatefromjpeg( $img_origem );
    	$nLargura = imagesx( $img );
    	$nAltura = imagesy( $img );
    
    	if($nLargura > $nAltura) {
    		$nMaior = $nLargura;
    		$nMenor = $nAltura;
    		$nProporcao = 100 - (100 * $largura / $nMaior);
    		$nMenor = floor($nMenor - ($nMenor * $nProporcao / 100));
    		$vDimensao['largura'] = $largura;
    		$vDimensao['altura'] = $nMenor;
    	}else{
    		$nMaior = $nAltura;
    		$nMenor = $nLargura;
    		$nProporcao = 100 - (100 * $altura / $nMenor);
    		$nMenor = floor($nMaior - ($nMaior * $nProporcao / 100));
    		$vDimensao['largura'] = $nMenor;
    		$vDimensao['altura'] = $altura;
    	}
    
    	$iFotoFinal = imagecreatetruecolor($vDimensao['largura'],$vDimensao['altura']);
    	imagecopyresampled($iFotoFinal,$iFotoOriginal,0,0,0,0,$vDimensao['largura'],$vDimensao['altura'],$nLargura,$nAltura);
    	imagejpeg($iFotoFinal,$img_origem,100);
    }
}