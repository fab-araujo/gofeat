<?php

class Plugin_Permissao extends Zend_Controller_Plugin_Abstract
{

    /**
     * @var Zend_Auth
     */
    protected $_auth = null;

    protected $_dbGrupo;
    protected $_dbPagina;
    protected $_dbPaginaGrupo;

    public function __construct()
    {

    }

    public function verificaLink($link)
    {

        return $link;
    }

}
