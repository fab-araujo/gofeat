<?php

abstract class Plugin_Db extends Zend_Db_Table_Abstract {

	protected $_nome_log = null;
	protected $_oUsuario;
	protected $_dbLog;
	

	public function arrayToXml($array, $rootElement = null, $xml = null) {
		$_xml = $xml;

		if ($_xml === null) {
			$_xml = new SimpleXMLElement($rootElement !== null ? $rootElement : '<root/>');
		}

		foreach ($array as $k => $v) {
			if (is_array($v)) { //nested array
				$this->arrayToXml($v, $k, $_xml->addChild($k));
			} else {
				$_xml->addChild($k, $v);
			}
		}

		return $_xml->asXML();
	}
	
	/**
 * Fetches all rows.
 *
 * Honors the Zend_Db_Adapter fetch mode.
 *
 * @param string|array|Zend_Db_Table_Select $where  OPTIONAL An SQL WHERE clause or Zend_Db_Table_Select object.
 * @param string|array                      $order  OPTIONAL An SQL ORDER clause.
 * @param int                               $count  OPTIONAL An SQL LIMIT count.
 * @param int                               $offset OPTIONAL An SQL LIMIT offset.
 * @return Zend_Db_Table_Rowset_Abstract The row results per the Zend_Db_Adapter fetch mode.
 */
	public function fetchAll($where = null, $order = null, $count = null, $offset = null, $skipDel = false){

	    if(is_object($where)){
			if(!$skipDel){
				$where->where('deletado = 0');
			}
			
			return parent::fetchAll($where);
		}else if(is_array($where)){
            $where = $where[0];
            $where .= ' and deletado = 0';
            return parent::fetchAll($where, $order, $offset);
        }else if($where){
			$where .= ' and deletado = 0';

			return parent::fetchAll($where, $order, $count, $offset);
		}else{
			
			$where = ' deletado = 0';
			return parent::fetchAll($where, $order, $count, $offset);
		}
		
		
	}	
	
	public function fetchRow($where = null, $order = null, $offset = null, $skipDel = false){
		if(is_object($where)){
			if(!$skipDel){
				$where->where('deletado = 0');
			}
				
			return parent::fetchRow($where);
		}else if(is_array($where)){
            $where = $where[0];
            $where .= ' and deletado = 0';
            return parent::fetchRow($where, $order, $offset);
        }else if($where){
			
			$where .= ' and deletado = 0';
			return parent::fetchRow($where, $order, $offset);
			
		}else{
            $where = ' deletado = 0';
            return parent::fetchRow($where, $order, $offset);
        }
	}


	public function save(array $data, $id = 'id') {
		
		$fields = $this->info(Zend_Db_Table_Abstract::COLS);
            foreach ($data as $field => $value) {
                if($value){
                    $data[$field] = stripslashes($value);
                    if (!in_array($field, $fields)) {
                        unset($data[$field]);
                    }
                }

            }


            if (!($data[$id])) {
                try {
                    unset($data[$id]);
                    $id_inserida = $this->insert($data);
                    return $id_inserida;
                } catch (Exception $e) {
                    echo $e->getMessage();exit;
                    throw $e;

                    return false;
                }
            } else {
                $id_val = $data[$id];
                unset($data[$id]);
                try {

                	$qnt_alterada = $this->update($data, array($id . ' = ?' => $id_val));

                	return $id_val;
                    
                } catch (Exception $e) {
                    echo $e->getMessage();exit;

                    throw $e;

                    return false;
                }
            }
            return false;

	}

	public function delete($where=null) {

		if(is_array($where)){
			$where = $where[0];
		}
		$voDadoOriginal = $this->fetchAll($where);

		
		if($voDadoOriginal){
			foreach($voDadoOriginal as $oDadoOriginal){

				try {
					$vDadosOriginal = $oDadoOriginal->toArray();
					$vDadosOriginal['deletado'] = 1;

					$this->save($vDadosOriginal);

				} catch (Exception $e) {
                    echo "asd";exit;
					throw $e;
						
					return false;
				}
			}
		}
		
	}
	
	

	public function paginator($voDados,$page = 1,$qnt = 30){
		$data = Zend_Controller_Front::getInstance()->getRequest()->getParams();
		$page = ($data['pagina']) ? $data['pagina'] : $page;
		$paginator = Zend_Paginator::factory($voDados);
		$paginator->setCurrentPageNumber($page);
		$paginator->setItemCountPerPage($qnt);

		return $paginator;
	}
	
	

}