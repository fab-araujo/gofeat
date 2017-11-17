<?php
	class Db_ProjStatus extends Plugin_Db {
		protected $_name    = "proj_status";
		protected $_dependentTables = array('Db_ProjProject');
	}