<?php

class Painel_GrupoController extends Zend_Controller_Action {

    protected $_db;
    protected $_form;
    protected $_data;

    public function init() {
        $this->_db = new Db_UsuGrupo();

        $this->_form = new Painel_Form_Grupo();

        $this->_data = $this->_request->getParams();
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->view->bGrupo = true;
    }

    public function indexAction() {

        $this->view->voRegistro = $this->_db->fetchAll(NULL, 'nome asc');
    }

    public function inserealteraAction() {
        if ($this->_data["id"]) {
            $this->_form->populate($this->_db->fetchRow("id = " . $this->_data["id"])->toArray());
        }

        if ($this->_request->isPost()) {
            if ($this->_form->isValid($this->_data)) {
                try {
                    $this->_db->save($this->_data);
                    $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
                } catch (Exception $e) {
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
                $this->_redirect("/painel/grupo/");
            }
        }
        $this->view->form = $this->_form;
    }

    public function excluirAction() {

        if ($this->_data["id"]) {
            try {
                $this->_db->find($this->_data["id"])->current()->delete();
                $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
            } catch (Exception $e) {
                $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                var_dump($e->getMessage());exit;
            }
        }
        $this->_redirect("/painel/grupo/");
    }

}
