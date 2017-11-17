<?php
	class Db_BlastGo extends Plugin_Db {
		protected $_name    = "blast_go";
		protected $_referenceMap    = array(
						"id_blast" => array(
							"columns"           => "id_blast",
							"refTableClass"     => "Db_BlastResult",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
						,
						"id_go" => array(
							"columns"           => "id_go",
							"refTableClass"     => "Db_GoLevel",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}