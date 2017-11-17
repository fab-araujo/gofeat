<?php

class Zend_View_Helper_Editar extends Zend_View_Helper_Abstract {

    public function Editar($link) {
        $acl = new Plugin_Permissao();

        return '<a class="btn btn-icon-only green tooltips" data-container="body" data-placement="top" data-original-title="' . Zend_Registry::get('lblEdicao') . '" href="' . $acl->verificaLink($link) . '"><i class = "fa fa-edit"></i></a>';
    }

}
