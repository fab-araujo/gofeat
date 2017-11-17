<?php

class Painel_Form_Usuario extends Plugin_Form  {

    public function __construct() {
        return parent::__construct(NULL, 'div');
    }

    public function init() {
        $this->setAttrib('name', 'Cadastro de usuário');
        $this->setAttrib('id', 'formGeral');

        $this->addElement('hidden', 'id');

        $this->addElement('text', 'nome', array(
            'label' => 'Nome',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control'
        ));

        $this->addElement('text', 'email', array(
            'label' => 'Login (email)',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control email'
        ));

        $this->addElement('password', 'senha', array(
            'label' => 'Senha',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control'
        ));

        $this->addElement('textarea', 'descricao', array(
            'label' => 'Descrição',
            'filters' => array('StringTrim'),
            'class' => 'required form-control ckeditor'
        ));

        $this->addElement('file', 'arquivo', array(
            'label' => 'Foto:',
            'decorators' => $this->fileDecorators,
            'class' => 'form-control'
        ));
        $this->getElement('arquivo')->getDecorator('Description')->setEscape(false);
        $this->getElement('arquivo')->addValidator('Extension', false, 'jpg,jpeg,png,gif');

        $this->addElement('select', 'id_grupo', array(
            'label' => 'Grupo',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control select2',
            'multiOptions' => $this->recuperaGrupos()
        ));

        $this->addElement('submit', 'submit', array(
            'label' => Zend_Registry::get('lblCadastro'),
            'class' => 'btn green',
            'decorators' => $this->buttonDecorators
        ));
    }

    function recuperaGrupos() {
        $db = new Db_UsuGrupo();
        $vo = $db->fetchAll();
        $v = array();
        foreach ($vo as $o) {
            $v[$o->id] = $o->nome;
        }
        return $v;
    }

}
