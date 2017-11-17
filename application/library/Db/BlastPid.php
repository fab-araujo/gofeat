<?php
	class Db_BlastPid extends Plugin_Db {
		protected $_name    = "blast_pid";
		protected $_referenceMap    = array(
						"id_seq" => array(
							"columns"           => "id_seq",
							"refTableClass"     => "Db_ProjSeq",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}