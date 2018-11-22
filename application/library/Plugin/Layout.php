<?php
class Plugin_Layout extends Zend_Layout_Controller_Plugin_Layout{

	public function preDispatch (Zend_Controller_Request_Abstract $request){
		$this->_setupLayout($request->getModuleName());
	}

	protected function _setupLayout ($moduleName){
		$this->getLayout()->setLayout($moduleName);
		Zend_Registry::set('module', $moduleName);
	}
	
	public function getObjetoAcl(){
		$dbAcl = new Db_AclPaginaGrupo();
		return $dbAcl;
		
	}

}

