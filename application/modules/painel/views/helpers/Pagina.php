<?php

class Zend_View_Helper_Pagina extends Zend_View_Helper_Abstract {

    public function Pagina() {
        $dbPagina = new Db_PagPagina();
        $modulo = Zend_Controller_Front::getInstance()->getRequest()->getModuleName();
        $controller = Zend_Controller_Front::getInstance()->getRequest()->getControllerName();
        $action = Zend_Controller_Front::getInstance()->getRequest()->getActionName();
        $oPagina = $dbPagina->fetchRow('module = "' . $modulo . '" and controller = "' . $controller . '" and action = "' . $action . '"');
        if ($oPagina->id) {
            $vPagina = array('titulo' => $oPagina->titulo, 'subtitulo' => $oPagina->subtitulo);
        } else {
            $vPagina = array('titulo' => 'Sem título', 'subtitulo' => 'Sem subtítulo');
        }
        return $vPagina;
    }

}
