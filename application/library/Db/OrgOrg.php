<?php
	class Db_OrgOrg extends Plugin_Db {
		protected $_name    = "org_org";
		protected $_referenceMap    = array(
						"id_genus" => array(
							"columns"           => "id_genus",
							"refTableClass"     => "Db_OrgGenus",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}