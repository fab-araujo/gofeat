<?php

class Painel_PermissaoController extends Zend_Controller_Action {

    protected $_data;
    protected $_dbPagina;
    protected $_dbGrupo;
    protected $_dbPaginaGrupo;

    public function init() {
        $this->_data = $this->_request->getParams();
        $this->_dbPagina = new Db_PagPagina();
        $this->_dbGrupo = new Db_UsuGrupo();
        $this->_dbPaginaGrupo = new Db_PagGrupo();
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->view->bConfig = true;
        
    }

    public function paginaAction() {
        $this->view->bPag = true;
        $this->view->estrutura = $this->getArvore();
    }

    public function ajaxpermissaoAction() {
        $this->_helper->viewRenderer->setNoRender(TRUE);
        $this->_helper->layout->disableLayout();
        //deleta todas as permissoes
        $voPaginas = $this->_dbPagina->fetchAll();
        //limpa as permissoes
        foreach ($voPaginas as $oPagina) {
            unset($vPagina);
            $vPagina = $oPagina->toArray();
            $vPagina['restrito'] = "0";
            $this->_dbPagina->save($vPagina);
        }
        if ($this->_data["paginas"]) {
            foreach ($this->_data["paginas"] as $sPagina) {
                unset($module);
                unset($controller);
                unset($action);
                $vPagina = explode(",", $sPagina);
                $module = $vPagina[0];
                $controller = $vPagina[1];
                $action = $vPagina[2];
                if ($module && $controller && $action) {
                    $oPagina = $this->_dbPagina->fetchRow('module = "' . $module . '" and controller = "' . $controller . '" and action = "' . $action . '"');
                    if (!$oPagina->id) {
                        $this->_dbPagina->save(array('restrito' => '1', 'module' => $module, 'controller' => $controller, 'action' => $action));
                    } else {
                        $vPagina = $oPagina->toArray();
                        $vPagina['restrito'] = "1";
                        $this->_dbPagina->save($vPagina);
                    }
                }
            }
        }
    }

    public function permissaogrupoAction() {
        $this->view->bPerPag = true;
        $this->view->voGrupo = $this->_dbGrupo->fetchAll();
        if (isset($this->_data["id_grupo"])) {
            $this->view->estrutura = $this->getArvore("permissao", $this->_data["id_grupo"]);
        }
    }

    public function ajaxpermissaogrupoAction() {
        $this->_helper->viewRenderer->setNoRender(TRUE);
        $this->_helper->layout->disableLayout();
        if($this->_data['id_grupo']){
            $voPaginasGrupo = $this->_dbPaginaGrupo->fetchAll('id_grupo = '.$this->_data["id_grupo"]);
            foreach($voPaginasGrupo as $oPaginaGrupo){
                $oPaginaGrupo->delete();
            }
        }
        if ($this->_data["paginas"] && $this->_data["id_grupo"]) {
            
            foreach ($this->_data["paginas"] as $sPagina) {
                unset($module);
                unset($controller);
                unset($action);
                $vPagina = explode(",", $sPagina);
                $module = $vPagina[0];
                $controller = $vPagina[1];
                $action = $vPagina[2];
                if ($module && $controller && $action) {
                    $oPagina = $this->_dbPagina->fetchRow('module = "' . $module . '" and controller = "' . $controller . '" and action = "' . $action . '"');
                    $oPaginaGrupo = $this->_dbPaginaGrupo->fetchRow("id_pagina = " . $oPagina->id . " and id_grupo = " . $this->_data["id_grupo"]);

                    if (!$oPaginaGrupo->id) {
                        $this->_dbPaginaGrupo->save(array('id_pagina'=>$oPagina->id,'id_grupo'=>$this->_data['id_grupo']));
                    } 
                }
            }
        }
        
    }

    public function getArvore($tipo = null, $id_grupo = null) {
        $front = $this->getFrontController();
        $paginas = array();

        foreach ($front->getControllerDirectory() as $module => $path) {
            foreach (scandir($path) as $file) {
                if (strstr($file, "Controller.php") !== false) {
                    include_once $path . DIRECTORY_SEPARATOR . $file;
                    foreach (get_declared_classes() as $class) {
                        if (is_subclass_of($class, 'Zend_Controller_Action')) {

                            $controller = strtolower(substr($class, 0, strpos($class, "Controller")));

                            $controller = explode('_', $controller);
                            $controller = (count($controller) > 1) ? $controller[1] : $controller[0];
                            $actions = array();
                            foreach (get_class_methods($class) as $action) {
                                if (strstr($action, "Action") !== false) {
                                    $action = str_replace('Action', '', $action);
                                    $oPagina = $this->_dbPagina->fetchRow('restrito = 1 and module = "' . $module . '" and controller = "' . $controller . '" and action = "' . $action . '"');
                                    if ($oPagina) {
                                        $permissao = 1;
                                    } else {
                                        $permissao = 0;
                                    }
                                    if ($tipo == "permissao") {
                                        if ($permissao == 1) {
                                            $oPermissao = $this->_dbPaginaGrupo->fetchRow('id_pagina = ' . $oPagina->id . ' and id_grupo = ' . $id_grupo);
                                            if ($oPermissao) {
                                                $permissao = 1;
                                            } else {
                                                $permissao = 0;
                                            }

                                            $actions[] = array('action' => $action, 'permissao' => $permissao);
                                        }
                                    } else {
                                        $actions[] = array('action' => $action, 'permissao' => $permissao);
                                    }
                                }
                            }
                        }
                    }


                    $paginas[$module][$controller] = $actions;
                }
            }
        }
        $actions = array();
        $oPagina = $this->_dbPagina->fetchRow('restrito = 1 and module = "painel" and controller = "aclpermissao" and action = "pagina"');
        if ($oPagina->id) {
            $permissao = 1;
        } else {
            $permissao = 0;
        }
        if ($tipo == "permissao") {
            if ($permissao == 1) {
                $oPermissao = $this->_dbPaginaGrupo->fetchRow('id_pagina = ' . $oPagina->id . ' and id_grupo = ' . $id_grupo);
                if ($oPermissao) {
                    $permissao = 1;
                } else {
                    $permissao = 0;
                }

                $actions[] = array('action' => 'pagina', 'permissao' => $permissao);
            }
        } else {
            $actions[] = array('action' => 'pagina', 'permissao' => $permissao);
        }

        $oPagina = $this->_dbPagina->fetchRow('restrito = 1 and module = "painel" and controller = "aclpermissao" and action = "permissaogrupo"');
        if ($oPagina) {
            $permissao = 1;
        } else {
            $permissao = 0;
        }
        if ($tipo == "permissao") {
            if ($permissao == 1) {
                $oPermissao = $this->_dbPaginaGrupo->fetchRow('id_pagina = ' . $oPagina->id . ' and id_grupo = ' . $id_grupo);
                if ($oPermissao) {
                    $permissao = 1;
                } else {
                    $permissao = 0;
                }

                $actions[] = array('action' => 'permissaogrupo', 'permissao' => $permissao);
            }
        } else {
            $actions[] = array('action' => 'permissaogrupo', 'permissao' => $permissao);
        }

        $paginas['painel']['aclpermissao'] = $actions;
        return $paginas;
    }

}
