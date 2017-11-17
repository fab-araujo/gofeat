<?php
	class Db_LogOperacao extends Plugin_Db {
		protected $_name    = "log_operacao";
		protected $_referenceMap    = array(
						"id_operacao" => array(
							"columns"           => "id_operacao",
							"refTableClass"     => "Db_LogTipo",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
						,
						"id_usuario" => array(
							"columns"           => "id_usuario",
							"refTableClass"     => "Db_UsuUsuario",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}