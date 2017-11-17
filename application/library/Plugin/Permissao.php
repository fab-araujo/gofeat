<?php

class Plugin_Permissao extends Zend_Controller_Plugin_Abstract {

    /**
     * @var Zend_Auth
     */
    protected $_auth = null;

    protected $_dbGrupo;
    protected $_dbPagina;
    protected $_dbPaginaGrupo;

    public function __construct() {
        
    }

    public function preDispatch(Zend_Controller_Request_Abstract $request) {

        $module = $request->getModuleName();
        $controller = $request->getControllerName();
        $action = $request->getActionName();

        if ($module == 'painel' && $controller == 'db' && $action == 'index') {
            //for the db
        } else {
            $this->_dbGrupo = new Db_UsuGrupo();
            $this->_dbPagina = new Db_PagPagina();
            $this->_dbPaginaGrupo = new Db_PagGrupo();

            $this->_auth = Plugin_Auth::getInstance($module);

            if (!$this->_auth->hasIdentity() && $module == 'painel') {

                if($controller=='auth' && ($action=='index' || $action=='logout' || $action=='novasenha' || $action=='recuperasenha')){

                }else{
                    $controller = 'auth';
                    $action = 'index';
                }


            } else {

                //echo 'module = "'.$modulo.'" and controller = "'.$request->getControllerName().'" and action = "'.$request->getActionName().'"';exit;
                $oPagina = $this->_dbPagina->fetchRow('module = "' . $module . '" and controller = "' . $request->getControllerName() . '" and action = "' . $request->getActionName() . '" and restrito = 1');

                if (count($oPagina) > 0 && 1>2) {
                    if (!$this->_auth->hasIdentity()) {
                        $controller = $this->_notLoggedRoute['controller'];
                        $action = $this->_notLoggedRoute['action'];
                        $module = $this->_notLoggedRoute['module'];
                    } else if ($this->_auth->getIdentity()) {
                        $oPaginaGrupo = $this->_dbPaginaGrupo->fetchRow('id_grupo = ' . $this->_auth->getIdentity()->id_grupo . ' and id_pagina = ' . $oPagina->id);
                        if ($this->_auth->getIdentity()->id_grupo == 1) {
                            $controller = $request->getControllerName();
                            $action = $request->getActionName();
                            $module = $request->getModuleName();
                        } else if (!$oPaginaGrupo) {
                            $controller = $this->_forbiddenRoute['controller'];
                            $action = $this->_forbiddenRoute['action'];
                            $module = $this->_forbiddenRoute['module'];
                        } else {
                            $controller = $request->getControllerName();
                            $action = $request->getActionName();
                            $module = $request->getModuleName();
                        }
                    }
                }
            }


            $request->setControllerName($controller);

            $request->setActionName($action);

            $request->setModuleName($module);
        }
    }

    /* protected function _isAuthorized($resource)
      {
      $usuario = $this->_auth->getIdentity();
      //var_dump($usuario);exit;
      if($this->_acl){
      if($this->_acl->has( $resource ) || $usuario->id_grupo==1){

      $grupo = $this->_dbGrupo->fetchRow("id = ".$usuario->id_grupo);

      if (($this->_acl->has($resource) && $this->_acl->hasRole($grupo->nome) && $this->_acl->isAllowed($grupo->nome, $resource)) || $usuario->id_grupo==1){

      return true;

      }

      return false;
      }
      return true;
      }else{
      return false;
      }


      } */

    public function verificaLink($link) {
        
        $vLink = explode("/", $link);

        $modulo = $vLink[1];
        unset($vLink[1]);
        $controller = $vLink[2];
        unset($vLink[2]);

        if (isset($vLink[3]) && $vLink[3] <> '') {

            $action = $vLink[3];
        } else {
            $action = 'index';
        }
        unset($vLink[3]);


        if (isset($vLink[4])) {
            $parametros = $parametros = implode('/', $vLink);
        } else {
            $parametros = '';
        }
        unset($vLink[4]);
        $dbPagina = new Db_PagPagina();
        $dbPaginaGrupo = new Db_PagGrupo();

        $this->_auth = Plugin_Auth::getInstance($modulo);
        
        if ($this->_auth->hasIdentity()) {

            $oPagina = $dbPagina->fetchRow('module = "' . $modulo . '" and controller = "' . $controller . '" and action = "' . $action . '" and restrito = 1');
            if ($oPagina->id) {
                if($this->_auth->getIdentity()->id_grupo==1){
                    return ('/' . $modulo . '/' . $controller . '/' . $action . '' . $parametros); 
                }else{
                    $oPaginaGrupo = $dbPaginaGrupo->fetchRow('id_grupo = ' . $this->_auth->getIdentity()->id_grupo . ' and id_pagina = ' . $oPagina->id);
                    if ($oPaginaGrupo->id) {
                        return ('/' . $modulo . '/' . $controller . '/' . $action . '' . $parametros); 
                    } else {
                        return ('/' . $modulo . '/erro/erro');
                    }
                }
                
            } else {
                return ('/' . $modulo . '/' . $controller . '/' . $action . '' . $parametros);
            }
        } else {
            return '/painel/aclauth';
        }
    }

}
