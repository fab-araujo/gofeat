<?php
	class Db_BlastResult extends Plugin_Db {
		protected $_name    = "blast_result";
		protected $_dependentTables = array('Db_BlastGo','Db_BlastInterpro','Db_BlastPfam','Db_BlastSeed');
		protected $_referenceMap    = array(
						"id_seq" => array(
							"columns"           => "id_seq",
							"refTableClass"     => "Db_ProjSeq",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}