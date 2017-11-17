<?php
	class Db_LogTipo extends Plugin_Db {
		protected $_name    = "log_tipo";
		protected $_dependentTables = array('Db_LogOperacao');
	}