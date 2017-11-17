<?php
	class Db_ProjSeq extends Plugin_Db {
		protected $_name    = "proj_seq";
		protected $_dependentTables = array('Db_BlastPid','Db_BlastResult');
		protected $_referenceMap    = array(
						"id_proj" => array(
							"columns"           => "id_proj",
							"refTableClass"     => "Db_ProjProject",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}