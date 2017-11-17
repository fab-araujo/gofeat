<?php
	class Db_UsuUsuario extends Plugin_Db {
		protected $_name    = "usu_usuario";
		protected $_dependentTables = array('Db_LogOperacao');
		protected $_referenceMap    = array(
						"id_grupo" => array(
							"columns"           => "id_grupo",
							"refTableClass"     => "Db_UsuGrupo",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}