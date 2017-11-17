<?php

class Painel_PaginaController extends Zend_Controller_Action {

    protected $_db;
    protected $_form;
    protected $_data;

    public function init() {
        $this->_db = new Db_ConfPagina();
        $this->_form = new Painel_Form_Pagina();
        $this->_data = $this->_request->getParams();
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->view->bPag = true;
    }

    public function indexAction() {

        $vo = $this->_db->fetchAll();
        $this->view->voRegistro = $vo;
    }

    public function inserealteraAction() {

        if ($this->_data["id"]) {
            $oReg = $this->_db->fetchRow("id = " . $this->_data["id"]);
            $vAtrb = explode('/',$oReg->texto);
            $file = $_SERVER['DOCUMENT_ROOT']."/application/modules/".$vAtrb[1]."/views/scripts/".$vAtrb[2]."/".$vAtrb[3].".phtml";
            $conteudo = file_get_contents($file);

            $this->view->oRegistro = $oReg;
            $vReg = $oReg->toArray();
            $vReg['texto'] = $conteudo;
            $this->_form->populate($vReg);
        }

        if ($this->_request->isPost()) {
            if ($form->isValid($this->_data)) {
                try {
                    file_put_contents($file,$this->_data['texto']);
                    //$this->_dbGrupo->save($this->_data);
                    $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
                } catch (Exception $e) {
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
                $this->_redirect("/painel/pagina/");
            }
        }
        $this->view->form = $this->_form;

    }

}
