<?php
	class Db_ProjProject extends Plugin_Db {
		protected $_name    = "proj_project";
		protected $_dependentTables = array('Db_ProjSeq','Db_ProjShared');
		protected $_referenceMap    = array(
						"id_status" => array(
							"columns"           => "id_status",
							"refTableClass"     => "Db_ProjStatus",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
						,
						"id_user" => array(
							"columns"           => "id_user",
							"refTableClass"     => "Db_ProjUser",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}