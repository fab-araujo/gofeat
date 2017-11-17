<?php

class Bootstrap extends Zend_Application_Bootstrap_Bootstrap {

    protected function _initDbRegistry() {
        $this->bootstrap('multidb');
        $multidb = $this->getPluginResource('multidb');
        $multidb->init();
        Zend_Registry::set('db_default', $multidb->getDb('name1'));
        //Zend_Registry::set('db_another', $multidb->getDb('name2'));
        //Zend_Registry::set('db_dol', $multidb->getDb('name3'));

        /*if ($link = mysql_connect('localhost', 'root', 'root')) {
            //do queries
        } else {
            //use files
        }
        var_dump($link);*/
        return $multidb->getDb();
    }

    protected function _initRouter() {

        $this->bootstrap('FrontController');

        $front = $this->getResource('FrontController');
        $front->addModuleDirectory(APPLICATION_PATH . '/modules');
        $front->setControllerDirectory(
                array(
                    'site' => APPLICATION_PATH . '/modules/site/controllers',
                    'painel' => APPLICATION_PATH . '/modules/painel/controllers'
                )
        );

        $front->setDefaultModule('site');

        //If set to 'true', the ErrorController won't be activated
        $front->throwExceptions(true);

        Zend_Registry::set('CLIENTE', 'PADRÃO');

        Zend_Registry::set('lblCadastro', 'Cadastrar');
        Zend_Registry::set('lblEdicao', 'Alterar');
        Zend_Registry::set('lblExclusao', 'Excluir');
        Zend_Registry::set('msgSucesso', 'Operação efetuada com sucesso!');
        Zend_Registry::set('msgErro', 'A operação não pode ser processada!');
        Zend_Registry::set('logo', '/site/assets/img/logo.jpg');


    }

    protected function _initSetupBaseUrl() {
        $this->bootstrap('frontcontroller');
        $controller = Zend_Controller_Front::getInstance();
        $controller->setBaseUrl('/gofeat/');
        Zend_Registry::set('baseurl', '/gofeat/');
    }

    protected function _initAcl() {
        $front = $this->getResource('FrontController');
        $front->registerPlugin(new Plugin_Permissao());
    }

    protected function _initMail() {
         $config = array(
          'auth' => 'login',
          'username' => 'lpdnabioinfor@gmail.com',
          'password' => '@biotec100',
          'ssl' => 'ssl',
          'port' => '465'
          );
          $mailTransport = new Zend_Mail_Transport_Smtp('smtp.gmail.com', $config);
          Zend_Mail::setDefaultTransport($mailTransport);

    }

}