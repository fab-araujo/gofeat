<?php
	class Db_UsuGrupo extends Plugin_Db {
		protected $_name    = "usu_grupo";
		protected $_dependentTables = array('Db_PagGrupo','Db_UsuUsuario');
	}