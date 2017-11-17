<?php

class Painel_UsuarioController extends Zend_Controller_Action {

    protected $_db;
    protected $_data;
    protected $_imagem;
    protected $_util;
    protected $_formSenha;
    protected $_formUsuario;

    public function init() {
        $this->_data = $this->_request->getParams();
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->_db = new Db_UsuUsuario();

        $this->_util = new Plugin_Util();

        $this->view->bUsu = true;

        $this->_formSenha = new Painel_Form_Senha();
        $this->_formUsuario = new Painel_Form_Usuario();

        $this->_imagem = new Plugin_Imagem();
    }

    public function indexAction() {

        $voUsuario = $this->_db->fetchAll(NULL, 'nome asc');
        $this->view->voRegistro = $voUsuario;
    }

    public function inserealteraAction() {

        if ($this->_data["id"]) {
            $oUsuario = $this->_db->fetchRow("id = " . $this->_data["id"]);
            $this->view->oRegistro = $oUsuario;
            $vUsuario = $oUsuario->toArray();
            $this->_formUsuario->populate($vUsuario);
        }

        if ($this->getRequest()->isPost()) {
            if ($this->_formUsuario->isValid($this->_data)) {
                try {
                    $this->_data['senha'] = md5($this->_data['senha']);
                    $this->_data['arquivo'] = $this->_imagem->upload();
                    if(!$this->_data['arquivo']){
                        unset($this->_data['arquivo']);
                    }
                    $this->_db->save($this->_data);
                    $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
                } catch (Exception $e) {
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
                $this->_redirect("/painel/usuario/");
            }
        }

        $this->view->form = $this->_formUsuario;
    }

    public function excluirAction() {

        if ($this->_data["id"]) {
            try {
                $this->_db->find($this->_data["id"])->current()->delete();
                $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
            } catch (Exception $exc) {
                $this->_helper->FlashMessenger(array('erro', $exc->getMessage()));
            }
        }
        $this->_redirect("/painel/usuario/");
    }

    public function alterasenhaAction() {
        $this->_formSenha->populate(array('id'=>Plugin_Auth::getInstance()->getIdentity()->id));
        $this->view->form = $this->_formSenha;
        if ($this->_request->isPost()) {
            if ($this->_formSenha->isValid($this->_data)) {
                $oUsuario = Plugin_Auth::getInstance()->getIdentity();
                $oDbUsuario = $this->_db->fetchRow("id = " . $oUsuario->id);
                try {
                    $oDbUsuario->senha = md5($this->_data["nova_senha"]);
                    $this->_db->save($oDbUsuario->toArray());

                    $this->_helper->FlashMessenger(array('sucesso', 'Senha alterada com sucesso!'));
                } catch (Exception $e) {
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
                $this->_redirect('/painel/');
            }
        }
    }

}
