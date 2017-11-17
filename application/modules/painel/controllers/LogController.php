<?php

class Painel_LogController extends Zend_Controller_Action {

    protected $_db;
    protected $_data;

    public function init() {
        $this->_db = new Db_LogOperacao();
        $this->_data = $this->_request->getParams();
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->view->bConfig = true;
        $this->view->bLog = true;
    }

    public function indexAction() {

        $voLog = $this->_db->fetchAll(null, "id_operacao asc");
        $this->view->voRegistro = $voLog;
    }

    public function exibirAction() {
        if ($this->_data["id"]) {
            $oLog = $this->_db->fetchRow("id = " . $this->_data["id"]);
            $this->view->oLog = $oLog;
        }
    }

}
