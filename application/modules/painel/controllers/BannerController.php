<?php

class Painel_BannerController extends Zend_Controller_Action {

    protected $_db;
    protected $_data;
    protected $_form;

    public function init() {

        $this->_db = new Db_BanBanner();

        $this->_data = $this->_request->getParams();
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->view->bBannerH = true;

        $this->_imagem = new Plugin_Imagem();

        $this->_form = new Painel_Form_Banner();
    }

    public function indexAction() {

        $this->view->voRegistro = $this->_db->fetchAll();
    }

    public function inserealteraAction() {

        if ($this->_data["id"]) {
            $this->view->oRegistro = $this->_db->fetchRow("id = " . $this->_data["id"]);
            $this->_form->populate($this->view->oRegistro->toArray());
        }

        if ($this->_request->isPost()) {
            if ($this->_form->isValid($this->_data)) {
                try {
                    $this->_data['arquivo'] = $this->_imagem->upload();
                    if(!$this->_data['arquivo']){
                        unset($this->_data['arquivo']);
                    }
                    $this->_data['arquivo_m'] = $this->_imagem->upload('arquivo_m');
                    if(!$this->_data['arquivo_m']){
                        unset($this->_data['arquivo_m']);
                    }
                    $this->_db->save($this->_data);
                    $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
                } catch (Exception $e) {
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
                $this->_redirect("/painel/banner/");
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
        $this->_redirect("/painel/banner/");
    }

}
