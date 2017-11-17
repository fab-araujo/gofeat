<?php

class Zend_View_Helper_Permissao extends Zend_View_Helper_Abstract {

    public function Permissao($link) {
        //Zend_Registry::get('acl')->verificaLink($link);
        $acl = new Plugin_Permissao();
        return $acl->verificaLink($link);
    }

}
