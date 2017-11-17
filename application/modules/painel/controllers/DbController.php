<?php

class Painel_DbController extends Zend_Controller_Action {

    protected $_data;
    protected $_user;

    public function init() {

        $this->_data = $this->_request->getParams();

        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();

        $this->view->bInicio = true;
    }

    public function indexAction() {
        $this->_helper->viewRenderer->setNoRender(TRUE);

        $oDb = Zend_Db_Table::getDefaultAdapter();
        $vDb = $oDb->getConfig();

        //Lista todas as tabelas
        $vTabelas = $oDb->listTables();

        unset($vTabelasDependentes);
        unset($vDependentes);

        //Pra cada tabela verifica as dependencias
        foreach ($vTabelas as $tabela) {

            //lista todas as tabelas dependentes de $tabela
            $sql = 'SELECT
    				CONSTRAINT_SCHEMA,
    				CONSTRAINT_NAME,
    				TABLE_SCHEMA,
    				TABLE_NAME,
    				COLUMN_NAME,
    				REFERENCED_TABLE_SCHEMA,
					REFERENCED_TABLE_NAME,
    				REFERENCED_COLUMN_NAME
				FROM
    				INFORMATION_SCHEMA.KEY_COLUMN_USAGE
				WHERE
    				REFERENCED_TABLE_NAME="' . $tabela . '"
    				AND CONSTRAINT_SCHEMA = "' . $vDb['dbname'] . '"';

            $stmt = $oDb->query($sql);
            $rows = $stmt->fetchAll();

            foreach ($rows as $row) {
                //Lista as tabelas dependentes
                $vTabelasDependentes[$row['REFERENCED_TABLE_NAME']][] = $row['TABLE_NAME'];
                //Lista as dependencias no formato tabela, coluna da tabela e coluna referenciada
                $vDependentes[$row['TABLE_NAME']][] = array($row['REFERENCED_TABLE_NAME'], $row['COLUMN_NAME'], $row['REFERENCED_COLUMN_NAME']);
            }
        }

        //escreve os arquivos
        foreach ($vTabelas as $tabela) {

            $arquivo = explode('_', $tabela);
            $classDb = 'Db_';
            $arquivoTb = 'Db_';
            $arquivoDb = '';
            foreach ($arquivo as $index => $arq) {
                $arquivoDb .= ucfirst($arq);
                $arquivoTb .= ucfirst($arq);
                $classDb .= ucfirst($arq);
            }
            $arquivoDb .= '.php';


            unset($conteudo);

            $conteudo = "<?php\n";
            $conteudo .= "\tclass " . $classDb . " extends Plugin_Db {\n";

            $conteudo .= "\t\t" . 'protected $_name    = "' . $tabela . '";' . "\n";

            if (is_array($vTabelasDependentes[$tabela])) {
                $conteudo .= "\t\t" . 'protected $_dependentTables = array(' . "";
                foreach ($vTabelasDependentes[$tabela] as $index => $tabelaDependente) {
                    if ($index > 0) {
                        $conteudo .= ',';
                    }
                    $arquivoX = explode('_', $tabelaDependente);
                    $tabelaDependenteX = '';
                    foreach ($arquivoX as $arqX) {
                        $tabelaDependenteX .= ucfirst($arqX);
                    }
                    $conteudo .= "'Db_" . $tabelaDependenteX . "'";
                }
                $conteudo .= ");\n";
            }
            if (is_array($vDependentes[$tabela])) {
                $conteudo .= "\t\t" . 'protected $_referenceMap    = array(' . "\n";
                foreach ($vDependentes[$tabela] as $index => $dependencia) {
                    if ($index > 0) {
                        $conteudo .= "\t\t\t\t\t\t" . ',' . "\n";
                    }
                    $ref = explode('_', $dependencia[0]);
                    $refClass = '';
                    foreach ($ref as $arq) {

                        $refClass .= ucfirst($arq);
                    }

                    $conteudo .= "\t\t\t\t\t\t" . '"' . $dependencia[1] . '" => array(' . "\n";
                    $conteudo .= "\t\t\t\t\t\t\t" . '"columns"           => "' . $dependencia[1] . '",' . "\n";
                    $conteudo .= "\t\t\t\t\t\t\t" . '"refTableClass"     => "Db_' . $refClass . '",' . "\n";
                    $conteudo .= "\t\t\t\t\t\t\t" . '"refColumns"        => "' . $dependencia[2] . '",' . "\n";
                    $conteudo .= "\t\t\t\t\t\t\t" . '"onDelete"          => self::CASCADE_RECURSE' . "\n";
                    $conteudo .= "\t\t\t\t\t\t" . ')' . "\n";
                }
                $conteudo.= "\t\t\t\t\t" . ");\n";
            }



            $conteudo .= "\t}";



            $file = $_SERVER[DOCUMENT_ROOT] . Zend_Registry::get('baseurl'). '/application/library/Db/' . $arquivoDb;
            $handle = fopen($file, 'w');
            fwrite($handle, trim($conteudo));
            fclose($handle);
        }
    }

}
