<?php
	class Db_BlastPfam extends Plugin_Db {
		protected $_name    = "blast_pfam";
		protected $_referenceMap    = array(
						"id_blast" => array(
							"columns"           => "id_blast",
							"refTableClass"     => "Db_BlastResult",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}