<?php

class Painel_IndexController extends Zend_Controller_Action {

    public $_data;
    public $_user;

    public function init() {

        $this->_data = $this->_request->getParams();
        $this->_user = Plugin_Auth::getInstance()->getIdentity();

        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->view->bInicio = true;
    }

    public function indexAction() {

    }

    public function excluirimgAction(){
        try {
            unlink($_SERVER['DOCUMENT_ROOT'].'/data/'.$this->_data['arquivo']);
            $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
        } catch (Exception $e) {
            $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
        }

        $this->_redirect(base64_decode($this->_data['url']));
    }

}
