<?php
	class Db_ProjShared extends Plugin_Db {
		protected $_name    = "proj_shared";
		protected $_referenceMap    = array(
						"id_project" => array(
							"columns"           => "id_project",
							"refTableClass"     => "Db_ProjProject",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}