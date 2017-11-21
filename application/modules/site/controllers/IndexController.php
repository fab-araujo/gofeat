<?php

class IndexController extends Zend_Controller_Action
{
    protected $_data;


    public function init()
    {
        $this->view->messages = $this->_helper->getHelper('FlashMessenger')->getMessages();
        $this->_data = $this->_request->getParams();

        $this->_imagem = new Plugin_Imagem();
        $this->_auth = new Plugin_Auth();
    }

    public function indexAction()
    {
        $this->view->bHome = true;
        $dbBanner = new Db_BanBanner();
        $this->view->voBanner = $dbBanner->fetchAll();

        if ($this->_request->isPost()) {
            ini_set('max_execution_time', 0);

            $this->_data['file'] = $this->_imagem->upload('file');
            $this->_data['file_real'] = ($_FILES['file']['name']);

            if (!$this->_data['file']) {
                unset($this->_data['file']);
            }

            if (($this->_data['file'] || $this->_data['sequences']) && $this->_data['name']) {
                //se enviou um arquivo
                if ($this->_data['file']) {
                    //verifica se ele é válido
                    $command = 'perl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/validate_fasta.pl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $this->_data['file'] . ' 2>&1';
                    exec($command, $output);
                    $output = implode('', $output);
                    if (strpos($output, "EXCEPTION: Bio::Root::Exception")) {
                        $this->_helper->FlashMessenger(array('erro', "It seems you didn't upload a valid fasta file. Please, try again."));
                        unlink($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $this->_data['file']);
                        $this->_redirect('/index/');
                    }

                }
                //se enviou sequencias
                if ($this->_data['sequences']) {
                    //salva a sequencia em um arquivo
                    $file_sequence = "sequence_" . date("Y-m-d-H-i-s") . ".fasta";
                    $this->_data['file_sequence'] = $file_sequence;
                    file_put_contents($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $file_sequence, $this->_data['sequences']);

                    //verifica se o arquivo com a sequencia é valido
                    $command = 'perl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/validate_fasta.pl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $file_sequence . ' 2>&1';
                    exec($command, $output);
                    $output = implode('', $output);
                    if (strpos($output, "EXCEPTION: Bio::Root::Exception")) {
                        $this->_helper->FlashMessenger(array('erro', "It seems you didn't enter a valid fasta sequence. Please, try again."));
                        unlink($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $file_sequence);
                        $this->_redirect('/index');
                    }
                } else {
                    unset($this->_data['sequences']);
                }

                //passou a validação do arquivo e sequencia


                $db = new Db_ProjProject();
                $this->_data['date'] = date('Y-m-d H:i:s');
                if (Plugin_Auth::getInstance()->getIdentity()->id) {
                    $this->_data['id_user'] = Plugin_Auth::getInstance()->getIdentity()->id;
                }

                $this->_data['id_status'] = 1;

                $id_pro = $db->save($this->_data);

                if ($this->_data['file']) {
                    $server = "http://computationalbiology.ufpa.br";
                    $command = 'curl ' . $server . '/gofeat/index/procfile/id/' . $id_pro . '/evalue/'.$this->_data['evalue'].' > /dev/null 2>&1 & echo $!';
                    $pid = exec($command, $output);


                }
                unset($output);
                if ($this->_data['file_sequence']) {
                    $handle = fopen($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $this->_data['file_sequence'], "r");
                    if ($handle) {
                        $i = 0;
                        $dbSeq = new Db_ProjSeq();
                        $vLine = array();
                        $title = '';
                        while (($line = fgets($handle)) !== false) {
                            $line = trim($line);
                            if (substr($line, 0, 1) == ">") {
                                $title = $line;
                            } else {
                                $vLine[$title] .= $line . "\n";
                            }
                            $i++;
                        }
                        fclose($handle);

                        foreach ($vLine as $title => $seq) {
                            $fullseq = $title . "\n" . $seq;
                            $tmp2 = 'temp_' . rand(1, 999) . '.fasta';
                            file_put_contents($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $tmp2, $fullseq);

                            $command = 'perl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/file_type.pl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $tmp2;
                            exec($command, $output);
                            unlink($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $tmp2);

                            $type = $output[0];

                            $title = utf8_encode($title);

                            $dbSeq->save(array('id_proj' => $id_pro, 'title' => $title, 'seq' => trim($seq), 'evalue' => $this->_data['evalue'], 'type' => $type, 'id_status'=>1));
                        }
                    }
                }

                if (Plugin_Auth::getInstance()->getIdentity()) {
                    $this->_helper->FlashMessenger(array('sucesso', 'Your data has been uploaded successfully and it is now running.'));
                    $this->_redirect('/index/myprojects');
                }
                else {
                    $db = new Db_ProjProject();

                    $oPro = $db->find($id_pro)->current();

                    $dbSeq = new Db_ProjSeq();
                    $voSeq = $dbSeq->fetchAll('id_proj = ' . $oPro->id);
                    foreach ($voSeq as $oSeq) {
                        $oSeq->id_status = 1;
                        $dbSeq->save($oSeq->toArray());
                    }

                    $oPro->id_status = 1;
                    $db->save($oPro->toArray());

                    $this->_helper->FlashMessenger(array('sucesso', "Your data has been uploaded succesfully and it's now running. <p>Your access key is <b>" . Plugin_Util::encrypt($id_pro) . "</b>. You can use it to check the status of your project.</p>"));
                    $this->_redirect('/index/');
                }


            } else {
                unlink($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $this->_data['file']);
                $this->_helper->FlashMessenger(array('erro', 'You must fill all options.'));
                $this->_redirect('/index');
            }
        }
    }

    public function procfileAction(){
        ini_set('memory_limit', '4096M');
        ini_set('max_execution_time', 0);
        set_time_limit(0);
        $this->_helper->layout->disableLayout();
        $this->_helper->viewRenderer->setNoRender(TRUE);
        $db = new Db_ProjProject();
        $oProj = $db->fetchRow('id = '.$this->_data['id']);
        $id_pro = $this->_data['id'];

        $handle = fopen($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $oProj->file, "r");

        if ($handle) {
            $i = 0;
            $dbSeq = new Db_ProjSeq();
            $vLine = array();
            $title = '';
            while (($line = fgets($handle)) !== false) {
                $line = trim($line);
                if (substr($line, 0, 1) == ">") {
                    $title = $line;
                } else {
                    $vLine[$title] .= $line . "\n";
                }
                $i++;
            }
            fclose($handle);

            foreach ($vLine as $title => $seq) {
                $fullseq = $title . "\n" . $seq;
                $tmp = 'temp_' . rand(1, 999) . '.fasta';
                $fullseq = (utf8_encode($fullseq));

                file_put_contents($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $tmp, $fullseq);

                $command = 'perl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/file_type.pl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $tmp;

                exec($command, $output);
                unlink($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $tmp);
                $type = $output[0];

                $title = utf8_encode($title);
                $vSeq = array('id_proj' => $id_pro, 'title' => $title, 'seq' => trim($seq), 'evalue' => $this->_data['evalue'], 'type' => $type);
                $dbSeq->save($vSeq);
            }

            $dbSeq->update(array('id_status' => '1'), array('id_proj = '.$id_pro));

            /*$voSeq = $dbSeq->fetchAll('id_proj = ' . $oProj->id);
            foreach ($voSeq as $oSeq) {
                $oSeq->id_status = 1;
                $dbSeq->save($oSeq->toArray());
            }*/
        }
    }

    public function aboutAction()
    {
        $this->view->bAbout = true;
    }

    public function contactAction()
    {
        $this->view->bContact = true;

        if ($this->_request->isPost()) {

            $mail = new Zend_Mail('UTF-8');
            $html = '<p>Nova mensagem do sistema!</p>';
            $html .= '<p>Nome: ' . $this->_data['name'] . '</p>';
            $html .= '<p>Email: ' . $this->_data['email'] . '</p>';
            $html .= '<p>Organização: ' . $this->_data['org'] . '</p>';
            $html .= '<p>Assunto: ' . $this->_data['subject'] . '</p>';
            $html .= '<p>Mensagem: ' . $this->_data['message'] . '</p>';

            $mail->setBodyHtml($html);
            $mail->setFrom('lpdnabioinfor@gmail.com', 'GO FEAT');
            $mail->addTo('araujopa@gmail.com', 'Fabricio Araujo');
            $mail->setSubject('[Contato GO FEAT] Nova mensagem');

            try {
                $mail->send();
                $this->_helper->FlashMessenger(array('sucesso', 'Your message has been send. Thank you.'));
            } catch (Exception $e) {
                $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                var_dump($e->getMessage());
                exit;
            }

            $this->_redirect('/index/contact');
        }
    }

    public function loginAction()
    {
        if ($this->_request->isPost()) {


            //check if email, pwdc and repwd are filled and pwdc == repwd
            if ($this->_data['email'] && $this->_data['pwdc'] && $this->_data['repwd'] && ($this->_data['pwdc'] == $this->_data['repwd'])) {
                //check if email already exists
                $db = new Db_ProjUser();
                $oUser = $db->fetchRow('email = "' . $this->_data['email'] . '"');
                if ($oUser->id) {
                    $this->_helper->FlashMessenger(array('erro', "Email already registered."));
                    $this->_redirect('/index/login');
                } else {
                    $this->_data['pwd'] = md5($this->_data['pwdc']);
                    $db->save($this->_data);
                    $login = $this->_data["email"];
                    $pwd = ($this->_data["pwd"]);

                    if ($this->_auth->login($login, $pwd, 'proj_user')) {
                        $this->_helper->FlashMessenger(array('sucesso', 'You are logged in.'));
                        $this->_redirect('/');
                    } else {
                        $this->_helper->FlashMessenger(array('erro', 'Invalid data.'));
                        $this->_redirect('/index/login/');
                    }
                }


            } else if ($this->_data['email'] && $this->_data['pwd']) {
                $login = $this->_data["email"];
                $pwd = md5($this->_data["pwd"]);

                if ($this->_auth->login($login, $pwd, 'proj_user')) {
                    $this->_helper->FlashMessenger(array('sucesso', 'You are logged in.'));
                    $this->_redirect('/index/myprojects');
                } else {
                    $this->_helper->FlashMessenger(array('erro', 'Invalid data.'));
                    $this->_redirect('/index/login/');
                }
            } else {
                $this->_helper->FlashMessenger(array('erro', "Invalid data."));
                $this->_redirect('/index/login');
            }
        }
    }

    public function logoutAction()
    {
        $this->_auth->logoff();
        $this->_helper->FlashMessenger(array('sucesso', 'You are now logged off.'));
        $this->_redirect('/index/');
    }

    public function newprojectAction()
    {
        if (!Plugin_Auth::getInstance()->getIdentity()) {
            $this->_helper->FlashMessenger(array('erro', "This service requires authentication. Please login or register as a new user."));
            $this->_redirect('/index/login');
        }


    }

    public function myprojectsAction()
    {
        if (!Plugin_Auth::getInstance()->getIdentity()) {
            $this->_helper->FlashMessenger(array('erro', "This service requires authentication. Please login or register as a new user."));
            $this->_redirect('/index/login');
        }
        $db = new Db_ProjProject();
        $dbShare = new Db_ProjShared();
        $vo = $db->fetchAll('id_user = ' . Plugin_Auth::getInstance()->getIdentity()->id);
        $voS = $dbShare->fetchAll('email = "' . Plugin_Auth::getInstance()->getIdentity()->email . '"');

        $vo = $vo;
        $voS = $voS;

        $voAll = array();
        foreach ($vo as $o) {
            $voAll[] = $o;
        }
        foreach ($voS as $o) {
            $oP = $db->find($o->id_project)->current();
            $voAll[] = $oP;
        }

        $this->view->vo = $voAll;

        if ($this->_request->isPost()) {

            $oProject = $db->find($this->_data['id_project'])->current();
            //check if the project was already shared
            $oProjS = $dbShare->fetchRow('id_project = ' . $this->_data['id_project'] . ' and email = "' . $this->_data['email'] . '"');

            if ($oProjS->id) {
                $this->_helper->FlashMessenger(array('erro', 'Your project "' . $oProject->name . '" is already shared with "' . $this->_data['name'] . '".'));

            } else if ($this->_data['email'] == Plugin_Auth::getInstance()->getIdentity()->email) {
                $this->_helper->FlashMessenger(array('erro', "You can't share a project with yourself!"));

            } else {

                $dbShare->save(array(
                    'id_project' => $this->_data['id_project'],
                    'name' => $this->_data['name'],
                    'email' => $this->_data['email'],
                    'message' => $this->_data['message'],
                    'data' => date('Y-m-d H:i:s')
                ));


                $mail = new Zend_Mail('UTF-8');
                $html = '<p>Greetings, ' . $this->_data['name'] . '!</p>';
                $html .= '<p>' . Plugin_Auth::getInstance()->getIdentity()->fname . " " . Plugin_Auth::getInstance()->getIdentity()->lname . ' shared the "' . $oProject->name . '" project with you on GO FEAT.</p>';
                $html .= '<p>Please <a href="http://computationalbiology.ufpa.br/gofeat/index/">log in</a> to you account to check out the results.</p>';
                if ($this->_data['message']) {
                    $html .= '<p>"' . $this->_data['message'] . '"</p>';
                }
                $html .= '<p>Best regards,</p>';
                $html .= '<p><a href="http://computationalbiology.ufpa.br/gofeat/index/">http://computationalbiology.ufpa.br/gofeat/index/</a></p>';
                $mail->setBodyHtml($html);
                $mail->setFrom('lpdnabioinfor@gmail.com', 'GO FEAT');
                $mail->addTo($this->_data['email'], $this->_data['name']);
                $mail->addBcc('araujopa@gmail.com');
                $mail->setSubject($oProject->name . ' Project Shared on GO FEAT');

                $mail->send();

                $this->_helper->FlashMessenger(array('sucesso', 'Your project was shared with "' . $this->_data['name'] . '".'));

            }
            $this->_redirect('/index/myprojects');

        }

    }

    public function deletesharingAction()
    {
        $dbShare = new Db_ProjShared();
        $dbProject = new Db_ProjProject();

        $oProject = $dbProject->find($this->_data['id'])->current();

        $email = Plugin_Auth::getInstance()->getIdentity()->email;

        if ($this->_data['email']) {
            $email = $this->_data['email'];
        }

        $oS = $dbShare->fetchRow('id_project = ' . $this->_data['id'] . ' and email = "' . $email . '"');
        $this->_helper->FlashMessenger(array('sucesso', 'Sharing removed for project "' . $oS->findParentRow('Db_ProjProject')->name . '".'));
        $oS->delete();
        $this->_redirect('/index/myprojects');
    }

    public function executeprojectAction()
    {
        $db = new Db_ProjProject();
        $dbSeq = new Db_ProjSeq();
        $oPro = $db->find($this->_data['id'])->current();

        $voSeq = $dbSeq->fetchAll('id_proj = ' . $oPro->id);
        foreach ($voSeq as $oSeq) {
            $oSeq->id_status = 1;
            $dbSeq->save($oSeq->toArray());
        }

        $oPro->id_status = 1;
        $db->save($oPro->toArray());
        $this->_helper->FlashMessenger(array('sucesso', 'Your project is now running. You will be notified when this job is finished.'));
        $this->_redirect('/index/myprojects');

    }

    /*public function viewprojectAction()
    {
        if (!Plugin_Auth::getInstance()->getIdentity()) {
            $this->_helper->FlashMessenger(array('erro', "This service requires authentication. Please login or register as a new user."));
            $this->_redirect('/index/login');
        }
        $db = new Db_ProjProject();
        $this->view->oProject = $db->find($this->_data['id'])->current();

        $this->view->page = $this->_data['page'] ? $this->_data['page'] : 1;
    }*/

    public function gotoprojectAction()
    {
        $this->_redirect('/index/viewprojectp/key/' . $this->_data['key']);
    }

    public function viewprojectpAction()
    {

        $this->_data['id'] = Plugin_Util::decrypt($this->_data['key']);

        //var_dump($this->_data['key']);exit;

        $db = new Db_ProjProject();
        $dbS = new Db_ProjSeq();

        $oProject = $db->find($this->_data['id'])->current();

        if ($oProject->id) {
            $this->view->oProject = $oProject;

            $voSeq = $dbS->fetchAll('id_proj = ' . $this->_data['id'], 'id asc');
            $pageRange = 40;

            if ($this->_data['query']) {
                $query = $this->_data['query'];
                $query = str_replace(' ', '%', $query);
                $vQuery = explode(';', $query);

                $select = $dbS->select();

                $query = "(";
                foreach ($vQuery as $index => $sQuery) {
                    if ($index > 0) {
                        $query .= ' or ';
                    }
                    $query .= 'title like "%' . $sQuery . '%"';
                }
                $query .= ")";

                $sQueryF = " " . $query . " or (";

                $query = "(";
                foreach ($vQuery as $index => $sQuery) {
                    if ($index > 0) {
                        $query .= ' or ';
                    }
                    $query .= 'r.Hit_def like "%' . $sQuery . '%"';
                }
                $query .= ")";


                $sQueryF .= " id in (select r.id_seq from blast_result as r join blast_go as g on r.id = g.id_blast where " . $query;

                $query = "(";
                foreach ($vQuery as $index => $sQuery) {
                    if ($index > 0) {
                        $query .= ' or ';
                    }
                    $query .= 'g.term like "%' . $sQuery . '%"';
                }
                $query .= ")";

                $sQueryF .= " or " . $query;

                $query = "(";
                foreach ($vQuery as $index => $sQuery) {
                    if ($index > 0) {
                        $query .= ' or ';
                    }
                    $query .= 'g.text like "%' . $sQuery . '%"';
                }
                $query .= ")";

                $sQueryF .= " or " . $query;

                $sQueryF .= " ))";


                $select->where($sQueryF);
                $select->where('id_proj = ' . $this->_data['id']);

                $voSeq = $dbS->fetchAll($select);
                $pageRange = '99999999';

            }


            if($this->_data['blast_result'] == "hit_only"){
                $voSeqN = array();
                foreach($voSeq as $index=>$oSeq){
                    if($oSeq->id_status == 3){
                        $voSeqN[] = $oSeq->id;
                    }
                }
                $voSeq = $dbS->fetchAll('id in ('.implode(',',$voSeqN).')');
            }

            if($this->_data['blast_result'] == "error_only"){
                $voSeqN = array();
                foreach($voSeq as $index=>$oSeq){
                    if($oSeq->id_status == 4){
                        $voSeqN[] = $oSeq;
                    }
                }
                $voSeq = $voSeqN;
            }

            if($this->_data['go_result'] == "hit_only"){
                $vId = array();

                foreach($voSeq as $oSeq){
                    $vId[] = $oSeq->id;
                }

                $select = $dbS->select();
                $select->where("id_proj = " . $this->_data['id']);
                $select->where("id in (select r.id_seq from blast_result as r join blast_go as g on r.id = g.id_blast)");
                $select->where("id in (".implode(',',$vId).")");

                $voSeqN = $dbS->fetchAll($select);

                $voSeq = $voSeqN;
            }

            if($this->_data['go_result'] == "null_results"){
                $vId = array();

                foreach($voSeq as $oSeq){
                    $vId[] = $oSeq->id;
                }

                $select = $dbS->select();
                $select->where("id_proj = " . $this->_data['id']);
                $select->where("id not in (select r.id_seq from blast_result as r join blast_go as g on r.id = g.id_blast)");
                $select->where("id in (".implode(',',$vId).")");

                $voSeqN = $dbS->fetchAll($select);

                $voSeq = $voSeqN;
            }


            if ($this->_data['export']) {
                $this->_forward('export', NULL, NULL, array('voSeq' => $voSeq, 'oProject' => $this->view->oProject));
            }

            if ($this->_data['exportcurrent']) {
                $paginator = Zend_Paginator::factory($voSeq);

                $page = $this->_data['page'] ? $this->_data['page'] : 1;

                // Select the second page
                $paginator->setCurrentPageNumber($page)
                    ->setItemCountPerPage($pageRange)
                    ->setPageRange($pageRange);
                $this->_forward('export', NULL, NULL, array('voSeq' => $paginator, 'oProject' => $this->view->oProject));
            }


            $paginator = Zend_Paginator::factory($voSeq);

            $page = $this->_data['page'] ? $this->_data['page'] : 1;

            // Select the second page
            $paginator->setCurrentPageNumber($page)
                ->setItemCountPerPage($pageRange)
                ->setPageRange($pageRange);

            $this->view->paginator = $paginator;
        } else {
            $this->_helper->FlashMessenger(array('erro', 'Invalid access key.'));
            $this->_redirect('/index');
        }


    }

    public function viewseqAction(){
        $this->_data['id'] = Plugin_Util::decrypt($this->_data['key']);
        $dbSeq = new Db_ProjSeq();

        header("Cache-Control: public");
        header("Content-Description: File Transfer");
        header("Content-Disposition: attachment; filename=seq_".$this->_data['key'].".fasta");
        header("Content-Type: application/octet-stream; ");
        header("Content-Transfer-Encoding: binary");

        $oSeq = $dbSeq->find($this->_data['id'])->current();
        echo $oSeq->title."\n";
        echo $oSeq->seq;
        exit;
    }

    public function viewgraphAction()
    {
        $this->_data['id_project'] = Plugin_Util::decrypt($this->_data['key']);

        $db = new Db_ProjProject();
        $dbS = new Db_ProjSeq();

        $oProject = $db->find($this->_data['id_project'])->current();

        if ($oProject->id) {
            $db = new Db_ProjProject();
            $dbS = new Db_ProjSeq();
            $dbO = new Db_BlastGo();

            $this->_data['id_project'] = $oProject->id;

            $this->view->oProject = $oProject;

            $select = $db->select()
                ->from(array('s' => 'proj_seq'))
                ->join(array('r' => 'blast_result'),
                    's.id = r.id_seq')
                ->join(array('g' => 'blast_go'),
                    'r.id = g.id_blast')
                ->setIntegrityCheck(false); // ADD This Line;

            $select->where('s.id_proj = ' . $this->_data['id_project']);

            if ($this->_data['type']) {
                $select->where('g.last_parent_id = "' . $this->_data['id'] . '"');
                $oOnt = $dbO->fetchRow('last_parent_id = "' . $this->_data['id'] . '"');

                $this->view->sOnt = $oOnt->last_parent_id . " - " . $oOnt->last_parent_name;
            } else {
                $select->where('g.term = "' . $this->_data['id'] . '"');
                $oOnt = $dbO->fetchRow('term = "' . $this->_data['id'] . '"');
                $this->view->sOnt = $oOnt->term . " - " . $oOnt->text;
            }

            $select->where('s.deletado = 0 and r.deletado = 0 and g.deletado = 0');

            //echo $select;

            $voSeq = $dbS->fetchAll($select, NULL, NULL, NULL, true);
            $this->view->voSeq = ($voSeq);
        } else {
            $this->_helper->FlashMessenger(array('erro', 'Invalid access key.'));
            $this->_redirect('/index');
        }


    }

    public function viewchartAction()
    {
        $this->_data['id'] = Plugin_Util::decrypt($this->_data['key']);

        $this->view->key = $this->_data['key'];

        $db = new Db_ProjProject();
        $dbS = new Db_ProjSeq();

        $oProject = $db->find($this->_data['id'])->current();

        if ($oProject->id) {
            $db = new Db_ProjProject();
            $dbS = new Db_ProjSeq();
            $dbC = Zend_Db_Table::getDefaultAdapter(); //Or how ever you store your DBs...
            $dbC->getConnection()->query('SET sql_mode=""');
            $dbC->getConnection()->query('SET group_concat_max_len = 18446744073709551615');

            $this->view->oProject = $db->find($this->_data['id'])->current();

            //All for pizza
            $select = $db->select()
                ->from(array('s' => 'proj_seq'), array('hits' => 'COUNT(*)'))
                ->join(array('r' => 'blast_result'),
                    's.id = r.id_seq')
                ->join(array('g' => 'blast_go'),
                    'r.id = g.id_blast')
                ->setIntegrityCheck(false); // ADD This Line;

            $select->where('s.id_proj = ' . $this->_data['id']);
            $select->where('not isnull(last_parent_id) and s.deletado = 0 and r.deletado = 0 and g.deletado = 0');
            $select->group('g.last_parent_name');
            $voSeq_all = $dbS->fetchAll($select, NULL, NULL, NULL, true);

            ////////
            $this->view->voSeq_all = ($voSeq_all);
            //$this->view->voSeq_biological_process = ($voSeq_biological_process);
            //$this->view->voSeq_cellular_component = ($voSeq_cellular_component);
            ////////

            //All molecular_function
            $select = $db->select()
                ->from(array('s' => 'proj_seq'), array('hits' => 'COUNT(*)', 'locus' => "GROUP_CONCAT(title SEPARATOR ';')"))
                ->join(array('r' => 'blast_result'),
                    's.id = r.id_seq')
                ->join(array('g' => 'blast_go'),
                    'r.id = g.id_blast')
                ->join(array('l' => 'go_level'),
                    'g.id_go = l.id')
                ->setIntegrityCheck(false); // ADD This Line;
            $select->where('s.id_proj = ' . $this->_data['id'] . ' and g.last_parent_name ="molecular_function"');
            $select->where('s.deletado = 0 and r.deletado = 0 and g.deletado = 0 and l.deletado = 0');
            $select->group('g.id_go');
            $select->order('hits');


            $this->view->voSeq_molecular_function_detailed = $dbS->fetchAll($select, NULL, NULL, NULL, true);


            //All biological_process
            $select = $db->select()
                ->from(array('s' => 'proj_seq'), array('hits' => 'COUNT(*)', 'locus' => "GROUP_CONCAT(title SEPARATOR ';')"))
                ->join(array('r' => 'blast_result'),
                    's.id = r.id_seq')
                ->join(array('g' => 'blast_go'),
                    'r.id = g.id_blast')
                ->join(array('l' => 'go_level'),
                    'g.id_go = l.id')
                ->setIntegrityCheck(false); // ADD This Line;
            $select->where('s.id_proj = ' . $this->_data['id'] . ' and g.last_parent_name ="biological_process"');
            $select->where('s.deletado = 0 and r.deletado = 0 and g.deletado = 0 and l.deletado = 0');
            $select->group('g.id_go');
            $select->order('hits');

            $this->view->voSeq_biological_process_detailed = $dbS->fetchAll($select, NULL, NULL, NULL, true);

            //All cellular_component
            $select = $db->select()
                ->from(array('s' => 'proj_seq'), array('hits' => 'COUNT(*)', 'locus' => "GROUP_CONCAT(title SEPARATOR ';')"))
                ->join(array('r' => 'blast_result'),
                    's.id = r.id_seq')
                ->join(array('g' => 'blast_go'),
                    'r.id = g.id_blast')
                ->join(array('l' => 'go_level'),
                    'g.id_go = l.id')
                ->setIntegrityCheck(false); // ADD This Line;
            $select->where('s.id_proj = ' . $this->_data['id'] . ' and g.last_parent_name ="cellular_component"');
            $select->where('s.deletado = 0 and r.deletado = 0 and g.deletado = 0 and l.deletado = 0');
            $select->group('g.id_go');
            $select->order('hits');

            $this->view->voSeq_cellular_component_detailed = $dbS->fetchAll($select, NULL, NULL, NULL, true);
        } else {
            $this->_helper->FlashMessenger(array('erro', 'Invalid access key.'));
            $this->_redirect('/index');
        }


    }

    public function viewchartajaxAction()
    {
        $this->_helper->layout()->disableLayout();
        $this->_helper->viewRenderer->setNoRender(true);

        $db = new Db_ProjProject();
        $dbS = new Db_ProjSeq();

        $select = $db->select()
            ->from(array('s' => 'proj_seq'), array('hits' => 'COUNT(*)'))
            ->join(array('r' => 'blast_result'),
                's.id = r.id_seq')
            ->join(array('g' => 'blast_go'),
                'r.id = g.id_blast')
            ->join(array('l' => 'go_level'),
                'g.term = l.acc')
            ->setIntegrityCheck(false); // ADD This Line;
        $select->where('s.id_proj = ' . $this->_data['id'] . ' and g.last_parent_name ="' . $this->_data['type'] . '"');
        $select->where('s.deletado = 0 and r.deletado = 0 and g.deletado = 0 and l.deletado = 0');
        $select->group(array('g.id',
            'g.id_blast',
            'g.term', 'g.text',
            'g.name',
            'g.def',
            'g.synonym',
            'g.tree_top',
            'g.last_parent_name',
            'g.last_parent_id',
            'g.deletado',
            'l.id',
            'l.acc', 'l.name', 'l.term_type', 'l.max', 'l.min', 'l.deletado'
        ));

        echo $select;
        exit;

        $vo = $dbS->fetchAll($select, NULL, NULL, NULL, true)->toArray();
        echo json_encode($vo);

    }

    public function ajaxchartAction()
    {
        $term = $this->_data['term'];
        $url = "http://www.ebi.ac.uk/QuickGO/services/ontology/go/terms/" . $term . "/chart";

        echo $url;exit;

        if (!($term && file_exists($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . str_replace(":", "", $term) . '.png'))) {
            $client = new Zend_Http_Client($url);
            $response = $client->request();
            $output = ($response->getBody());

            echo base64_decode($output);exit;

            file_put_contents($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . str_replace(":", "", $term) . '.png', base64_decode($output));
        }

        echo Zend_Registry::get('baseurl') . '/data/' . str_replace(":", "", $term) . '.png';
        exit;
    }

    public function exportAction()
    {
        $voSeq = $this->_data['voSeq'];

        header("Content-type: text/csv");
        header("Content-Disposition: attachment; filename=project_" . $this->_data['oProject']->id . ".csv");
        header("Pragma: no-cache");
        header("Expires: 0");

        // disable layout and view
        $this->view->layout()->disableLayout();

        $this->view->voSeq = $voSeq;
    }

    public function deleteprojectAction()
    {
        if ($this->_data["id"]) {
            try {
                $db = new Db_ProjProject();
                $db->find($this->_data["id"])->current()->delete();
                $this->_helper->FlashMessenger(array('sucesso', 'You project was deleted.'));
            } catch (Exception $e) {
                $this->_helper->FlashMessenger(array('erro', $e->getMessage()));
                var_dump($e->getMessage());
                exit;
            }
        }
        $this->_redirect("/index/myprojects");
    }

    public function botblastAction()
    {
        $this->_helper->layout->disableLayout();
        $this->_helper->viewRenderer->setNoRender(TRUE);

        $db = new Db_BlastPid();
        $dbSeq = new Db_ProjSeq();
        $dbPid = new Db_BlastPid();

        $this->echopausedbot("Starting bot... \n");
        $nMax = 30;
        $nMin = 3;
        $sleep = 60;
        $server = "http://computationalbiology.ufpa.br";


        while (true) {
            $voJobs = $db->fetchAll();
            $nNow = count($voJobs);
            $this->echopausedbot("There are " . $nNow . " jobs running now. \n");

            $this->checkfinished();


            if ($nNow < $nMax) {
                //check for all seqs with status = 1, grouped by project ($nProj)
                $select = $dbSeq->select()->from('proj_seq', 'id_proj');
                $select->where('id_status = 1');
                $select->group("id_proj");
                $select->order("id_proj asc");
                //echo ;exit;
                //$this->echopausedbot($select."\n");
                $voSeqsProj = $dbSeq->fetchAll($select);
                if (count($voSeqsProj) > 0) {
                    unset($vProj);
                    foreach ($voSeqsProj as $oSeqP) {
                        $vProj[] = $oSeqP->id_proj;
                    }
                    $nProj = count($vProj);

                    if ($nProj > 0) {
                        //divide $nMax by the number of seqs from above = $nThreads
                        $nThreads = $nMax / $nProj;
                        $nThreads = floor($nThreads);

                        //var_dump($vProj);

                        //if the result is less then $nMin, divide again by $nProj-1
                        while ($nThreads <= $nMin) {
                            array_pop($vProj);
                            $nProj = count($vProj);
                            $nThreads = $nMax / $nProj;
                            $nThreads = floor($nThreads);
                        }


                        //else
                        if ($nThreads >= $nMin) {
                            if(is_array($vProj)){
                                foreach ($vProj as $idProj) {
                                    //check the threats alredy in process
                                    $voSeqProjA = $dbPid->fetchAll('id_seq in (select id from proj_seq where id_status = 1 and id_proj = ' . $idProj . ')');

                                    $nSeqProjA = count($voSeqProjA);
                                    //if the active threads is smaller then $nThreats


                                    if ($nSeqProjA < $nThreads) {
                                        for ($i = 0; $i < ($nThreads - $nSeqProjA); $i++) {
                                            $oSeq = $dbSeq->fetchRow('id_status = 1 and id_proj = ' . $idProj . ' and id not in (select id_seq from blast_pid where deletado = 0)', 'id asc');
                                            $voJobs = $db->fetchAll();
                                            $nNow = count($voJobs);
                                            if ($nNow <= 30) {
                                                if ($oSeq->id) {
                                                    $oSeqPid = $dbPid->fetchRow('id_seq = ' . $oSeq->id);
                                                    if (!$oSeqPid->id) {
                                                        $id = $oSeq->id;
                                                        $command = 'curl ' . $server . '/gofeat/index/doblast/id/' . $id . ' > /dev/null 2>&1 & echo $!';

                                                        $pid = exec($command, $output);
                                                        $this->echopausedbot("Running blast of seq " . $oSeq->id . " (" . $pid . ") running now. \n");
                                                        $db->save(array('pid' => $pid, 'id_seq' => $oSeq->id));

                                                    }

                                                }
                                            } else {

                                                $this->echopausedbot("There are no blast pending... \n");
                                                $this->checkfinished();
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    } else {

                        $this->echopausedbot("There are no blast pending... \n");
                        $this->checkfinished();
                        sleep($sleep);
                    }
                } else {
                    sleep($sleep);
                }


            } else {
                $this->echopausedbot("Max limit of active jobs reached. \n");
                $this->checkfinished();
                sleep($sleep);
            }

        }

    }

    public function echopausedbot($string)
    {
        $string = str_replace("<br>", "\n", $string);
        $string = "[" . date('Y-m-d H:i:s') . "] " . $string;
        $size = file_put_contents($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/log_bot.txt', $string, FILE_APPEND);
        @ob_flush();
        flush();
        sleep(1);
    }

    public function checkfinished($msg = "")
    {
        if ($msg) {
            $this->echopausedbot($msg);
        }
        $db = new Db_BlastPid();
        $dbSeq = new Db_ProjSeq();
        $voJobs = $db->fetchAll();
        $this->echopausedbot("Checking for finished jobs... \n");
        foreach ($voJobs as $oJob) {
            if (!posix_getpgid($oJob->pid)) {
                //check if job is really finished
                $oSeq = $dbSeq->find($oJob->id_seq)->current();
                if ($oSeq->id_status != 3 && $oSeq->id_status != 4) {
                    $oSeq->id_status = 1;
                    if($oSeq->id){
                        $dbSeq->save($oSeq->toArray());
                    }

                }
                $this->echopausedbot("Deleting job " . $oJob->id . " (PID: " . $oJob->pid . ")... \n");
                $db->delete('id = ' . $oJob->id);
            }
        }

    }

    public function doblastAction()
    {
        ini_set('memory_limit', '4096M');
        ini_set('max_execution_time', 0);
        set_time_limit(0);
        $this->_helper->layout->disableLayout();
        $this->_helper->viewRenderer->setNoRender(TRUE);

        $dbSeq = new Db_ProjSeq();
        $dbBlast = new Db_BlastResult();
        $dbGo = new Db_GoLevel();
        $dbBlastGo = new Db_BlastGo();
        $dbInterpro = new Db_BlastInterpro();
        $dbPfam = new Db_BlastPfam();
        $dbSeed = new Db_BlastSeed();

        $oSeq = $dbSeq->find($this->_data['id'])->current();

        //if($oSeq->id_status == 1){
        if (1) {
            $this->echopausedbot("Running blast on seq " . $oSeq->id . "... \n");

            if ($oSeq->id) {
                $this->echopausedbot("Sending blast of seqID: " . $oSeq->id . "\n");
                $this->echopausedbot("Connecting to EBI...\n");

                $seq = trim(str_replace("\n", '', $oSeq->seq));
                $seq = str_replace(" ", '', $seq);

                $this->echopausedbot("Connected! Processing...\n");

                $vParam['seq'] = $seq;
                $vParam['type'] = $oSeq->type;
                $vParam['evalue'] = $oSeq->evalue;

                if ($oSeq->blast_rid) {
                    $rid = $oSeq->blast_rid;
                } else {
                    $rid = $this->sendBlastEBI($vParam);
                }
                //$rid = "ncbiblast-R20170317-191136-0897-52124633-oy";


                if (strpos($rid, 'ncbiblast-') === false) {
                    $this->echopausedbot("Error on sending blast SEQ: " . $oSeq->id . "\n");
                    $oSeq->blast_start = date('Y-m-d H:i:s');
                    $oSeq->blast_end = date('Y-m-d H:i:s');
                    $oSeq->id_status = 4;
                    $dbSeq->save($oSeq->toArray());
                    $this->echopausedbot("Saved blast error on SEQ: " . $oSeq->id . "\n");

                    $this->checkprojectstarted($oSeq);
                    $this->checkprojectfinished($oSeq);
                }
                else {
                    $this->echopausedbot("RID: " . $rid . "\n");
                    $oSeq->blast_rid = $rid;
                    $oSeq->blast_start = date('Y-m-d H:i:s');
                    $oSeq->id_status = 2;

                    $this->echopausedbot("Saving data...\n");
                    $dbSeq->save($oSeq->toArray());

                    //check if all seq from project are running
                    $this->checkprojectstarted($oSeq);

                    $status = $this->getStatusBlastEBI($oSeq->blast_rid);

                    if ($status == 'NOT_FOUND') {
                        $oSeq->id_status = 1;
                        $oSeq->blast_rid = '';
                        $dbSeq->save($oSeq->toArray());
                        return false;
                    }

                    if (!$status) {
                        $this->echopausedbot("Empty status on " . $oSeq->id . "\n");
                        $this->echopausedbot("Trying again!\n");
                        sleep(300);
                        $oSeq->id_status = 1;
                        $oSeq->blast_rid = '';
                        $dbSeq->save($oSeq->toArray());
                        return false;

                    } else {

                        $nErro = 0;

                        while ($status != 'FINISHED') {
                            $this->echopausedbot("Blast of seq " . $oSeq->id . " is " . $status . "!\n");

                            $status = $this->getStatusBlastEBI($oSeq->blast_rid);
                            if ($status == 'FAILURE') {
                                //$bFailure = true;
                                //break;
                                $this->echopausedbot("FAILURE error!\n");
                                $nErro++;
                                sleep(300);
                            }
                            if ($status == 'ERROR') {
                                //$bFailure = true;
                                //break;
                                $this->echopausedbot("ERROR error!\n");
                                $nErro++;
                                sleep(300);
                            }

                            if($nErro>=5){
                                $bFailure = true;
                                break;
                            }

                        }

                        if (!$bFailure) {
                            try {
                                $this->echopausedbot("Getting blast result on seqID: " . $oSeq->id . "\n");
                                $this->echopausedbot("Checking result...\n");

                                $root = $_SERVER['DOCUMENT_ROOT'];
                                $root = str_replace(' ', '\ ', $root);

                                $this->echopausedbot("Saving Blast XML...\n");
                                $this->getResultBlastEBI($oSeq->blast_rid);

                                $xml = simplexml_load_file($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $oSeq->blast_rid . '.out.txt');

                                unlink($_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/data/' . $oSeq->blast_rid . '.out.txt');

                                $json = json_encode($xml);
                                $vSeq = json_decode($json, TRUE);

                                $oSeq->blast_end = date('Y-m-d H:i:s');
                                $oSeq->id_status = 3;
                                $this->echopausedbot("Updating blast record...\n");
                                $dbSeq->save($oSeq->toArray());

                                $this->echopausedbot("Getting detailed info...\n");

                                //$vHits = ($vSeq->BlastOutput2[0]->report->results->search->hits);
                                $vHits = $vSeq['BlastOutput_iterations']['Iteration']['Iteration_hits']['Hit'][0];

                                $Hit_id = $vHits['Hit_id'];
                                $vId = explode(':', $Hit_id);
                                $idUniprot = $vId[1];


                                if (!$idUniprot) {
                                    $this->echopausedbot("NO UNIPROT!!! \n");
                                } else {
                                    $this->echopausedbot("ID Uniprot: " . $idUniprot . "\n");
                                    $oBlast = $dbBlast->fetchRow('uniprot_id = "' . $idUniprot . '" and id_seq = ' . $oSeq->id);
                                }


                                if ($oBlast->id) {
                                    $dbBlast->delete('id = ' . $oBlast->id);
                                    unset($oBlast);
                                }
                                //check if blast has been detailed
                                if (!$oBlast->id) {

                                    $vFinal['id_seq'] = $oSeq->id;
                                    $vFinal['Hit_def'] = $vHits['Hit_def'];
                                    $vFinal['Hit_len'] = $vHits['Hit_len'];
                                    $vFinal['Hsp_bit_score'] = $vHits['Hit_hsps']['Hsp']['Hsp_bit-score'];
                                    $vFinal['Hsp_bit_score'] = $vHits['Hit_hsps']['Hsp']['Hsp_bit-score'];
                                    $vFinal['Hsp_score'] = $vHits['Hit_hsps']['Hsp']['Hsp_score'];
                                    $vFinal['Hsp_evalue'] = $vHits['Hit_hsps']['Hsp']['Hsp_evalue'];
                                    $vFinal['Hsp_query_from'] = $vHits['Hit_hsps']['Hsp']['Hsp_query-from'];
                                    $vFinal['Hsp_query_to'] = $vHits['Hit_hsps']['Hsp']['Hsp_query-to'];
                                    $vFinal['Hsp_hit_from'] = $vHits['Hit_hsps']['Hsp']['Hsp_hit-from'];
                                    $vFinal['Hsp_hit_to'] = $vHits['Hit_hsps']['Hsp']['Hsp_hit-to'];
                                    $vFinal['Hsp_identity'] = $vHits['Hit_hsps']['Hsp']['Hsp_identity'];
                                    $vFinal['Hsp_positive'] = $vHits['Hit_hsps']['Hsp']['Hsp_positive'];
                                    $vFinal['Hsp_align_len'] = $vHits['Hit_hsps']['Hsp']['Hsp_align-len'];
                                    $vFinal['json_hit'] = json_encode($vHits);

                                    $id_blast = $dbBlast->save($vFinal);

                                    if ($idUniprot) {
                                        $gi = "";
                                        $idKegg = "";
                                        $idKeggEc = "";
                                        $idEmbl = "";
                                        $defUniprot = "";

                                        //get ncbi id
                                        $command = 'perl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/uniprot.pl ACC P_GI  ' . $idUniprot . ' 2>&1';

                                        $output = shell_exec($command);

                                        if (($output)) {
                                            $sResultado = ($output);

                                            $vResultado = explode("\n", $sResultado);
                                            unset($vResultado[0]);
                                            unset($vResultado[count($vResultado)]);

                                            $gi = "";
                                            foreach ($vResultado as $sResultado) {
                                                $vResultadoT = explode("\t", $sResultado);
                                                if ($vResultadoT[1] > $gi) {
                                                    $gi = $vResultadoT[1];
                                                }
                                            }
                                            $this->echopausedbot("ID NCBI: " . $gi . "\n");
                                        }

                                        //EXTRAS
                                        //////////////////////////////////////////////////////////////
                                        $ch = curl_init();
                                        curl_setopt($ch, CURLOPT_URL, "http://www.uniprot.org/uniprot/" . $idUniprot . "&format=xml");
                                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                                        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
                                        $output = curl_exec($ch);

                                        curl_close($ch);
                                        $xmluniprot = simplexml_load_string($output);

                                        $jsonuniprot = json_encode($xmluniprot);
                                        $vSeqUniprot = json_decode($jsonuniprot, TRUE);

                                        $defUniprot = $vSeqUniprot['entry']['protein']['submittedName']['fullName'];

                                        $oBlast = $dbBlast->find($id_blast)->current();
                                        $vBlast = $oBlast->toArray();



                                        foreach ($vSeqUniprot['entry']['dbReference'] as $vRef) {
                                            //KEGG
                                            if ($vRef['@attributes']['type'] == 'KEGG') {
                                                $idKegg = $vRef['@attributes']['id'];
                                                $this->echopausedbot("ID KEGG: " . $idKegg . "\n");
                                                $pKegg = file_get_contents("http://www.kegg.jp/dbget-bin/www_bget?" . $idKegg);
                                                $vPKegg = explode("[EC:", $pKegg);
                                                $idKeggEc = "";
                                                if ($vPKegg[1]) {
                                                    $sKegg = $vPKegg[1];
                                                    $vPKegg = explode("</a>]", $sKegg);
                                                    $sKegg = $vPKegg[0];
                                                    $vPKegg = explode(">", $sKegg);
                                                    $sKegg = $vPKegg[1];
                                                    $idKeggEc = $sKegg;
                                                    $this->echopausedbot("ID KEGG EC: " . $idKeggEc . "\n");
                                                }
                                            }
                                            //EMBL
                                            if ($vRef['@attributes']['type'] == 'EMBL') {
                                                $idEmbl = $vRef['@attributes']['id'];
                                                $this->echopausedbot("ID EMBL: " . $idEmbl . "\n");

                                            }
                                            //INTERPRO
                                            if ($vRef['@attributes']['type'] == 'InterPro') {
                                                $idinterproAux = $vRef['@attributes']['id'];
                                                $this->echopausedbot("ID InterPro: " . $idinterproAux . "\n");
                                                $dbInterpro->save(array('id_blast'=>$id_blast,'id_interpro'=>$idinterproAux));


                                            }
                                            //PFAM
                                            if ($vRef['@attributes']['type'] == 'Pfam') {
                                                $idpfamAux = $vRef['@attributes']['id'];
                                                $this->echopausedbot("ID Pfam: " . $idpfamAux . "\n");
                                                $dbPfam->save(array('id_blast'=>$id_blast,'id_pfam'=>$idpfamAux));


                                            }
                                            //GO
                                            if ($vRef['@attributes']['type'] == 'GO') {

                                                $go = $vRef['@attributes']['id'];
                                                $this->echopausedbot("ID GO: " . $go . "\n");

                                                if (trim($go)) {
                                                    $term = trim($go);
                                                    $url = "http://www.ebi.ac.uk/QuickGO/services/ontology/go/terms/" . $term;
                                                    $client = new Zend_Http_Client($url);
                                                    $response = $client->request();
                                                    $output = ($response->getBody());
                                                    $output = trim($output);
                                                    $vOutput = json_decode($output, true);



                                                    $synonym = array();

                                                    $sName = $vOutput['results'][0]['name'];
                                                    $sDef = $vOutput['results'][0]['definition']['text'];
                                                    if(is_array($vOutput['results'][0]['synonyms'])){
                                                        foreach($vOutput['results'][0]['synonyms'] as $vSym){
                                                            $sSym = $vSym['name'];
                                                            $synonym[] = $sSym;
                                                        }
                                                    }

                                                    /*var_dump($sName);
                                                    var_dump($sDef);
                                                    var_dump($synonym);
                                                    exit;

                                                    foreach ($vOutput as $linha) {
                                                        if (substr($linha, 0, 4) == "name") {
                                                            $vName = explode(":", $linha);
                                                            $sName = trim($vName[1]);
                                                        }
                                                        if (substr($linha, 0, 3) == "def") {
                                                            $vDef = explode(":", $linha);
                                                            $sDef = trim($vDef[1]);
                                                        }
                                                        if (substr($linha, 0, 7) == "synonym") {
                                                            $vSym = explode(":", $linha);
                                                            $sSym = trim($vSym[1]);
                                                            $synonym[] = $sSym;
                                                        }
                                                    }*/

                                                    //$vTree = $this->getTreeTop($term);
                                                    $vTree = array();
                                                    $oGo = $dbGo->fetchRow('acc = "' . trim($go) . '"');
                                                    if ($oGo->id) {
                                                        $id_go = $oGo->id;
                                                        $last_parent_name = $oGo->term_type;
                                                        if ($last_parent_name == 'biological_process') {
                                                            $last_parent_id = "GO:0008150";
                                                        } else if ($last_parent_name == 'cellular_component') {
                                                            $last_parent_id = "GO:0005575";
                                                        } else if ($last_parent_name == 'molecular_function') {
                                                            $last_parent_id = "GO:0003674";
                                                        }
                                                    }

                                                    $vGoTerm = array(
                                                        'id_blast' => $id_blast,
                                                        'id_go' => $id_go,
                                                        'term' => trim($go),
                                                        'text' => trim($sName),
                                                        'name' => $sName,
                                                        'def' => $sDef,
                                                        'synonym' => implode(",", $synonym),
                                                        'tree_top' => json_encode($vTree),
                                                        'last_parent_name' => $last_parent_name,
                                                        'last_parent_id' => $last_parent_id
                                                    );
                                                    $dbBlastGo->save($vGoTerm);
                                                }

                                            }

                                        }

                                        $vBlast['gi_id'] = $gi;
                                        $vBlast['kegg_id'] = $idKegg;
                                        $vBlast['kegg_ec'] = $idKeggEc;
                                        $vBlast['uniprot_id'] = $idUniprot;
                                        $vBlast['embl_id'] = $idEmbl;
                                        $vBlast['uniprot_def'] = $defUniprot;

                                        //SEED
                                        $this->echopausedbot("Checking SEED!\n");
                                        $command = 'perl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/seed_subsystem.pl ' . $idUniprot . ' 2>&1';
                                        $output = shell_exec($command);
                                        $vSeed = json_decode($output, true);

                                        if(is_array($vSeed)){
                                            $this->echopausedbot("SEED exist!\n");
                                            foreach($vSeed as $subsystem=>$vTreeSubsystem){
                                                $vSeed = array();
                                                $vSeed['id_blast'] = $id_blast;
                                                $vSeed['lvl3'] = $subsystem;
                                                $vSeed['lvl1'] = $vTreeSubsystem[0];
                                                if($vTreeSubsystem[1]){
                                                    $vSeed['lvl2'] = $vTreeSubsystem[1];
                                                }else{
                                                    $vSeed['lvl2'] = $vTreeSubsystem[0];
                                                }
                                                $this->echopausedbot("Saving SEED!\n");
                                                $dbSeed->save($vSeed);

                                            }
                                        }else{
                                            $this->echopausedbot("SEED not exist!\n");
                                        }

                                        $dbBlast->save($vBlast);

                                    }

                                    $this->echopausedbot("Data saved!\n");
                                }

                                //check if all seq from project are done
                                $this->checkprojectfinished($oSeq);


                            } catch
                            (Exception $e) {
                                $this->echopausedbot("ERROR: " . $e->getMessage() . "!\n");
                                if ($e->getLine() == '555') {
                                    $this->echopausedbot("Mensagem: " . $e->getMessage() . "!\n");
                                    $this->echopausedbot("Linha: " . $e->getLine() . "!\n");
                                    $this->echopausedbot("Stack: \n" . $e->getTraceAsString() . "\n-----------\n");
                                }
                            }
                        }
                        else {
                            $this->echopausedbot("Error on getting blast status SEQ: " . $oSeq->id . "\n");
                            //$oSeq->blast_start = date('Y-m-d H:i:s');
                            $oSeq->blast_end = date('Y-m-d H:i:s');
                            $oSeq->id_status = 4;
                            $dbSeq->save($oSeq->toArray());
                            $this->echopausedbot("Saved blast error on SEQ: " . $oSeq->id . "\n");

                            $this->checkprojectstarted($oSeq);
                            $this->checkprojectfinished($oSeq);

                        }
                    }
                }


            }
        }
    }

    public function sendBlastEBI($vParam)
    {
        $command = 'perl ' . $_SERVER['DOCUMENT_ROOT'] . Zend_Registry::get('baseurl') . '/ncbiblast_lwp.pl --async --email araujopa@gmail.com ';
        if ($vParam['type'] == 'protein') {
            $command .= '-p blastp ';
        } else {
            $command .= '-p blastx ';
        }
        $command .= '-D uniprotkb ';
        if ($vParam['evalue']) {
            $command .= '-E ' . $vParam['evalue'] . ' ';
        }
        $command .= '--stype ' . $vParam['type'] . ' ';


        $command .= $vParam['seq'];

        //$this->echopausedbot("COMMAND FOR BLAST: " . $command . "!\n");

        $output = shell_exec($command);
        return trim($output);
    }

    public function checkprojectstarted($oSeq)
    {
        //check if all seq from project are running
        $oProj = $oSeq->findParentRow('Db_ProjProject');
        $isBlastOver = true;
        $voSeq = $oProj->findDependentRowset('Db_ProjSeq');
        foreach ($voSeq as $oSeqAux) {
            if ($oSeqAux->id_status == 1) {
                $isBlastOver = false;
            }
        }
        if ($isBlastOver) {
            $oProj->id_status = 2;
            $db = new Db_ProjProject();
            $db->save($oProj->toArray());
        }
    }

    public function checkprojectfinished($oSeq)
    {
        //check if all seq from project are done
        $oProj = $oSeq->findParentRow('Db_ProjProject');
        $isBlastOver = true;
        if($oProj->id){
            $voSeq = $oProj->findDependentRowset('Db_ProjSeq');
            if(count($voSeq)>0){
                foreach ($voSeq as $oSeqAux) {
                    if ($oSeqAux->id_status < 3) {
                        $isBlastOver = false;
                    }
                }
            }

        }

        if ($isBlastOver) {
            $oUsuario = $oProj->findParentRow('Db_ProjUser');
            $oProj->id_status = 3;
            $db = new Db_ProjProject();
            $db->save($oProj->toArray());
            $mail = new Zend_Mail('UTF-8');
            $html = '<p>Greetings!</p>';
            $html .= '<p>Your GO FEAT job (#' . $oProj->id . ') is finished.</p>';
            if ($oProj->email) {
                $html .= '<p>Click <a href="http://computationalbiology.ufpa.br/gofeat/index/viewprojectp/key/' . Plugin_Util::encrypt($oProj->id) . '">here</a> to view the results.</p>';

            } else {
                $html .= '<p>Please <a href="http://computationalbiology.ufpa.br/gofeat/index/">log in</a> to you account to check out the results.</p>';

            }
            $html .= '<p>Best regards,</p>';
            $html .= '<p><a href="http://computationalbiology.ufpa.br/gofeat/index/">http://computationalbiology.ufpa.br/gofeat/index/</a></p>';
            $mail->setBodyHtml($html);
            $mail->setFrom('lpdnabioinfor@gmail.com', 'GO FEAT');
            if ($oProj->email) {
                $mail->addTo($oProj->email);
            } else {
                $mail->addTo($oUsuario->email, $oUsuario->fname);
            }

            $mail->addBcc('araujopa@gmail.com');
            $mail->setSubject('GO FEAT Job (#' . $oProj->id . ') Finished');
            $mail->send();
        }
    }

    public function getStatusBlastEBI($id)
    {
        $root = $_SERVER['DOCUMENT_ROOT'];
        $root = str_replace(' ', '\ ', $root);
        $command = 'perl ' . $root . Zend_Registry::get('baseurl') . '/ncbiblast_lwp.pl --status --jobid ' . $id;
        $output = shell_exec($command);
        sleep(60);
        return trim($output);
    }

    public function getResultBlastEBI($id)
    {
        $root = $_SERVER['DOCUMENT_ROOT'];
        $root = str_replace(' ', '\ ', $root);
        $command = 'perl ' . $root . Zend_Registry::get('baseurl') . '/ncbiblast_lwp.pl --outformat out --outfile ' . $root . Zend_Registry::get('baseurl') . '/data/' . $id . ' --polljob --jobid ' . $id;
        shell_exec($command);

    }

    public function getTreeTop($term)
    {
        $url = "http://www.ebi.ac.uk/QuickGO/GTerm?id=" . $term . "&format=obo";
        $client = new Zend_Http_Client($url);
        $response = $client->request();
        $output = ($response->getBody());
        $output = trim($output);
        $vOutput = explode("\n", $output);

        $bIsRoot = true;

        foreach ($vOutput as $linha) {
            if (substr($linha, 0, 4) == "name") {
                $vName = explode(":", $linha);
                $sName = trim($vName[1]);
                $vTerm[$term]['name'] = $sName;
            }

            if (substr($linha, 0, 4) == "is_a") {
                $vIsa = explode("!", $linha);
                $sParent = str_replace("is_a:", "", $vIsa[0]);
                $sParent = trim($sParent);
                $vTreeTop = $this->getTreeTop($sParent);

                foreach ($vTreeTop as $t => $v) {
                    if ($v['root']) {
                        $vTerm[$term]['root'] = $v['root'];
                        unset($vTreeTop[$t]['root']);
                    }
                }
                $vTerm[$term]["parent"][] = $vTreeTop;
                $bIsRoot = false;
            }
        }

        if ($bIsRoot) {
            $vTerm[$term]['root'] = array($sName, $term);
        }


        return $vTerm;
    }

    public function requestpasswordAction()
    {
        if ($this->_request->isPost()) {
            $email = $this->_data['email'];

            $dbUser = new Db_ProjUser();

            $oUser = $dbUser->fetchRow('email = "' . $email . '"');

            if ($oUser->id) {
                $token = md5(date('YmdHis' . $email));
                $oUser->token = $token;
                $dbUser->save($oUser->toArray());

                $mail = new Zend_Mail('UTF-8');
                $html = '<p>Greetings!</p>';
                $html .= '<p>You requested a new password in our system.</p>';
                $html .= '<p>Please <a href="http://computationalbiology.ufpa.br/gofeat/index/newpassword?token=' . $token . '">click here</a> to reset your password.</p>';
                $html .= '<p>Best regards,</p>';
                $html .= '<p><a href="http://computationalbiology.ufpa.br/gofeat/index/">http://computationalbiology.ufpa.br/gofeat/index/</a></p>';
                $mail->setBodyHtml($html);
                $mail->setFrom('lpdnabioinfor@gmail.com', 'GO FEAT');
                $mail->addTo($email);
                $mail->addBcc('araujopa@gmail.com');
                $mail->setSubject('New password requested GO FEAT');
                $mail->send();
                $this->_helper->FlashMessenger(array('sucesso', "An email was send to you with information on how to reset your password."));
            } else {
                $this->_helper->FlashMessenger(array('erro', "User not found. Try again."));
            }
            $this->_redirect("/index/requestpassword");

        }
    }

    public function newpasswordAction()
    {
        $token = $this->_data['token'];
        $dbUser = new Db_ProjUser();

        $oUser = $dbUser->fetchRow('token = "' . $token . '"');

        if ($oUser->id) {
            if ($this->_request->isPost()) {

                $oUser->pwd = md5($this->_data['pwdc']);
                $oUser->token = "";
                $dbUser->save($oUser->toArray());

                $this->_helper->FlashMessenger(array('sucesso', "Your password was reseted. You can log in now."));
                $this->_redirect("/index");
            }


        } else {
            $this->_helper->FlashMessenger(array('erro', "User not found. Try again."));
            $this->_redirect("/index/requestpassword");
        }
    }


}

