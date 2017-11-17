<?php
	class Db_PagGrupo extends Plugin_Db {
		protected $_name    = "pag_grupo";
		protected $_referenceMap    = array(
						"id_pagina" => array(
							"columns"           => "id_pagina",
							"refTableClass"     => "Db_PagPagina",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
						,
						"id_grupo" => array(
							"columns"           => "id_grupo",
							"refTableClass"     => "Db_UsuGrupo",
							"refColumns"        => "id",
							"onDelete"          => self::CASCADE_RECURSE
						)
					);
	}