<?php
	class Db_ProjUser extends Plugin_Db {
		protected $_name    = "proj_user";
		protected $_dependentTables = array('Db_ProjProject');
	}