<?php

class Zend_View_Helper_Visualizar extends Zend_View_Helper_Abstract {

    public function Visualizar($link) {
        $acl = new Plugin_Permissao();

        return '<a class="btn btn-icon-only blue tooltips" data-container="body" data-placement="top" data-original-title="' . Zend_Registry::get('lblVisualizar') . '" href="' . $acl->verificaLink($link) . '"><i class = "fa fa-desktop"></i></a>';
    }

}
