<?php

class Painel_Form_Grupo extends Plugin_Form  {

    public function __construct() {
        return parent::__construct(NULL, 'div');
    }

    public function init() {
        $this->setAttrib('name', 'Cadastro de grupo de usuários');
        $this->setAttrib('id', 'formGeral');

        $this->addElement('hidden', 'id');

        $this->addElement('text', 'nome', array(
            'label' => 'Grupo',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control',
            'placeholder' => 'Grupo'
        ));

        $this->addElement('submit', 'submit', array(
            'label' => Zend_Registry::get('lblCadastro'),
            'class' => 'btn green',
            'decorators' => $this->buttonDecorators
        ));
    }

}
