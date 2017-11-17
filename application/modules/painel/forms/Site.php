<?php

class Painel_Form_Site extends Plugin_Form  {

    public function __construct() {
        return parent::__construct(NULL, 'div');
    }

    public function init() {
        $this->setAttrib('name', 'Configuração geral do site');
        $this->setAttrib('id', 'formGeral');

        $this->addElement('hidden', 'id');

        $this->addElement('textarea', 'valor', array(
            'label' => 'Valor',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control'
        ));

        $this->addElement('submit', 'submit', array(
            'label' => Zend_Registry::get('lblCadastro'),
            'class' => 'btn green',
            'decorators' => $this->buttonDecorators
        ));
    }

}
