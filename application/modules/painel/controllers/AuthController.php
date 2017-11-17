<?php

class Painel_AuthController extends Zend_Controller_Action {

    protected $_db;
    protected $_form;
    protected $_auth;
    protected $_data;

    public function init() {

        $this->_auth = new Plugin_Auth();
        $this->_data = $this->_request->getParams();

        $this->_db = new Db_UsuUsuario();

        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->_form = new Painel_Form_Login();

        $this->view->bConfig = true;
    }

    public function indexAction() {
        $this->_helper->layout->disableLayout();
        $this->view->form = $this->_form;

        if ($this->getRequest()->isPost()) {
            if ($this->_form->isValid($this->_data)) {
                $login = $this->_data["email"];
                $senha = md5($this->_data["senha"]);

                if ($this->_auth->login($login, $senha)) {
                    $this->_helper->FlashMessenger(array('sucesso', 'Login efetuado com sucesso!'));
                    $this->_redirect('/painel/');
                } else {
                    $this->_helper->FlashMessenger(array('erro', 'Usuário e senha inválidos!'));
                    $this->_redirect('/painel/auth/');
                }
            }
        }
    }

    public function logoutAction() {
        $this->_auth->logoff();
        $this->_helper->FlashMessenger(array('sucesso', 'Você foi desconectado com sucesso!'));
        $this->_redirect('/painel/auth/');
    }

    public function novasenhaAction(){
        $this->_helper->layout->disableLayout();
        $this->view->token = $this->_data['token'];

        if($this->_request->isPost()){
            if($this->_data['token'] && $this->_data['senha']){
                $oUsuario = $this->_db->fetchRow('token = "'.$this->_data['token'].'"');
                if($oUsuario->id){
                    $oUsuario->token = '';
                $oUsuario->senha = md5($this->_data['senha']);
                $this->_db->update($oUsuario->toArray(), 'id = '.$oUsuario->id);
                $this->_helper->FlashMessenger(array('sucesso', Zend_Registry::get('msgSucesso')));
            }else{
                $this->_helper->FlashMessenger(array('erro', 'Token inválido!'));
                $this->_redirect("/painel/auth/");
            }
                
            }else{
                $this->_helper->FlashMessenger(array('erro', 'Você precisa uma senha!'));
            }
             $this->_redirect("/painel/auth/");
        }

    }

    public function recuperasenhaAction(){
        if($this->_request->isPost() && $this->_data['email']){
            $oUsuario = $this->_db->fetchRow('email = "'.$this->_data['email'].'"');
            if($oUsuario->id){
            
                $token = md5($this->_data['email'].date('Y-m-dH:i:s'));
                $oUsuario->token = $token;
                $vUsuario = $oUsuario->toArray();
                $this->_db->update($vUsuario, 'id = '.$oUsuario->id);
                
                $html = "<p>Você solicitou a recuperação de senha para o seu usuário no sistema administrativo de ".Zend_Registry::get('CLIENTE')."</p>";
                $html .= "Clique <a href='http://".$_SERVER['HTTP_HOST']."/painel/auth/novasenha/token/".$token."'>aqui</a> para cadastrar uma nova senha.";

                /*$config = array('auth' => 'login',
                    'username' => 'contato-site@advjuridico.com.br',
                    'password' => 'adv@0606',
                    'ssl' => 'tls',
                    'port' => 587);

                $transport = new Zend_Mail_Transport_Smtp('smtplw.com.br', $config);

                $mail = new Zend_Mail();

                $mail->setBodyHtml($html);
                $mail->addTo('araujopa@gmail.com');
                $mail->setSubject('Contato Site - '.$this->_data['assunto']);*/
                $assunto = "Recuperação de senha - ".Zend_Registry::get('CLIENTE');
                try {
                    //$mailTransport = new Zend_Mail_Transport_Smtp($smtp, $config);

                    $mail = new Zend_Mail('UTF-8');
                    //$mail->setFrom();
                    $mail->addTo($this->_data['email']);
                    $mail->setBodyHtml($html);
                    $mail->setSubject($assunto);
                    $mail->send();

                    $this->_helper->FlashMessenger(array('sucesso', 'Uma mensagem foi enviada contendo instruções para você recuperar sua senha!'));

                    
                    

                } catch (Exception $e){
                    $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                }
            }else{
                $this->_helper->FlashMessenger(array('erro', 'Você precisa digitar um email válido para recuperar a senha!'));
            }

            $this->_redirect('/painel/auth/');
        }else{
            $this->_helper->FlashMessenger(array('erro', 'Você precisa digitar um email válido para recuperar a senha!'));
            $this->_redirect('/painel/auth/');
        }
    }



}
