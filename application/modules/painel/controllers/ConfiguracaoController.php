<?php

class Painel_ConfiguracaoController extends Zend_Controller_Action {

    protected $_dbGeral;
    protected $_dbSeo;
    protected $_data;
    protected $_imagem;
    protected $_util;
    protected $_formSeo;
    protected $_formSite;

    public function init() {
        $this->_data = $this->_request->getParams();
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->_dbGeral = new Db_ConfGeral();
        $this->_dbSeo = new Db_ConfSeo();

        $this->_util = new Plugin_Util();

        $this->view->bConfigSite = true;

        $this->_formSeo = new Painel_Form_Seo();

    }

    public function geralAction() {
        $this->view->bGeral = true;
        $vo = $this->_dbGeral->fetchAll();
        $this->view->voRegistro = $vo;
    }

    public function inserealterageralAction() {
        $this->view->bGeral = true;
        $form = new Painel_Form_Site();

        if ($this->_data["id"]) {
            $o = $this->_dbGeral->find($this->_data['id'])->current();
            $this->view->oRegistro = $o;
            $v = $o->toArray();
            $form->populate($v);
        }

        if ($this->getRequest()->isPost()) {
            if ($form->isValid($this->_data)) {
                try {
                    $this->_dbGeral->save($this->_data);
                    $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
                } catch (Exception $e) {
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
                $this->_redirect("/painel/configuracao/geral");
            }
        }

        $this->view->form = $form;
    }

    public function seoAction() {
        $this->view->bSeo = true;
        $vo = $this->_dbSeo->fetchAll();
        $this->view->voRegistro = $vo;
    }

    public function inserealteraseoAction() {
        $this->view->bSeo = true;

        if ($this->_data["id"]) {
            $o = $this->_dbSeo->find($this->_data['id'])->current();
            $this->view->oRegistro = $o;
            $v = $o->toArray();
            $this->_formSeo->populate($v);
        }

        if ($this->getRequest()->isPost()) {
            if ($this->_formSeo->isValid($this->_data)) {
                try {
                    $this->_data['url'] = str_replace('www.','',$this->_data['url']);
                    $this->_dbSeo->save($this->_data);
                    $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
                } catch (Exception $e) {
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
                $this->_redirect("/painel/configuracao/seo");
            }
        }

        $this->view->form = $this->_formSeo;
    }

    public function excluirseoAction() {

        if ($this->_data["id"]) {
            try {
                $this->_dbSeo->find($this->_data["id"])->current()->delete();
                $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
            } catch (Exception $exc) {
                $this->_helper->FlashMessenger(array('erro', $exc->getMessage()));
            }
        }
        $this->_redirect("/painel/configuracao/seo");
    }

}
