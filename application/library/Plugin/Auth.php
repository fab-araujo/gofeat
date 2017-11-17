<?php

class Plugin_Auth extends Zend_Auth
{

    protected static $_instance = null;
    public $_data = null;


    function __construct($modulo = NULL)
    {
        //echo $modulo;exit;
        $this->setModule($modulo);
    }

    public static function getInstance($modulo = NULL)
    {
        if (null === self::$_instance) {
            //echo "aqui";exit;
            self::$_instance = new self ($modulo);
        }
        return self::$_instance;
    }

    function login($login, $senha, $tabela = 'usu_usuario')
    {

        if($tabela == 'usu_usuario'){
            $senha_field = 'senha';
        }else{
            $senha_field = 'pwd';
        }

        $dbAdapter = Zend_Db_Table::getDefaultAdapter();
        //Inicia o adaptador Zend_Auth para banco de dados
        $authAdapter = new Zend_Auth_Adapter_DbTable($dbAdapter);
        $authAdapter->setTableName($tabela)
            ->setIdentityColumn('email')
            ->setCredentialColumn($senha_field);
        //->setCredentialTreatment('SHA1(?)');
        //Define os dados para processar o login
        $authAdapter->setIdentity($login)
            ->setCredential($senha);
        //Efetua o login
        
        $result = $this->authenticate($authAdapter);

        //Verifica se o login foi efetuado com sucesso
        //var_dump($result->isValid());exit;
        if ($result->isValid()) {
            //Armazena os dados do usuário em sessão, apenas desconsiderando
            //a senha do usuário

            $info = $authAdapter->getResultRowObject(null, $senha_field);
            //$auth->setStorage(new Zend_Auth_Storage_Session('Zend_Auth_A')); 

            $this->getStorage()->write($info);
            if ($tabela == 'acl_usuario') {
                //$aclSetup = new Core_Acl($info->id);
            }


            //Redireciona para o Controller protegido
            return true;
        } else {
            //Dados inválidos
            return false;
        }
    }

    function logoff()
    {

        $auth = $this->getInstance();
        $auth->clearIdentity();


    }

    protected function setModule($modulo)
    {
        if (!$modulo) {

            $data = Zend_Controller_Front::getInstance()->getRequest()->getParams();
            $modulo = $data['module'];
        }

        $this->setStorage(new Zend_Auth_Storage_Session($modulo));
    }

    public function getIdentity()
    {
        $this->setModule(NULL);
        return parent::getIdentity();
    }

    public function hasIdentity()
    {
        $this->setModule(NULL);
        return parent::hasIdentity();
    }

}