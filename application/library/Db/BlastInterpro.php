<?php
	class Db_BlastInterpro extends Plugin_Db {
		protected $_name    = "blast_interpro";
		protected $_referenceMap    = array(
						"id_blast" => array(
							"columns"           => "id_blast",
							"refTableClass"     => "Db_BlastResult",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}