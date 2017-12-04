<?php
	class Db_OrgGenus extends Plugin_Db {
		protected $_name    = "org_genus";
		protected $_dependentTables = array('Db_OrgOrg');
	}