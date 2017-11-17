<?php

class Zend_View_Helper_Excluir extends Zend_View_Helper_Abstract {

    public function Excluir($link) {
        $acl = new Plugin_Permissao();

        return '<a data-toggle="modal" class="btn btn-icon-only red tooltips excluir" data-container="body" data-placement="top" data-original-title="' . Zend_Registry::get('lblExclusao') . '" href="' . $acl->verificaLink($link) . '"><i class = "fa fa-trash-o"></i></a>';
    }

}
