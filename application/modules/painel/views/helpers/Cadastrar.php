<?php

class Zend_View_Helper_Cadastrar extends Zend_View_Helper_Abstract {

    public function Cadastrar($link) {
        $acl = new Plugin_Permissao();
        $return = '<div class="row">';
        $return .= '<div class="col-md-12"><div class="btn-group pull-right btn-cadastro">';
        $return .= '<a href="' . $acl->verificaLink($link) . '" class="btn blue">';
        $return .= '<i class="icon-plus"></i> ';
        $return .= Zend_Registry::get('lblCadastro');
        $return .= '</div></a></div></div>';
        return $return;
    }

}
