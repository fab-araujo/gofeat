<?php

class Painel_Form_Pagina extends Plugin_Form  {

    public function __construct() {
        return parent::__construct(NULL, 'div');
    }

    public function init() {
        $this->setAttrib('name', 'Página customizável');
        $this->setAttrib('id', 'formGeral');

        $this->addElement('hidden', 'id');

        $this->addElement('textarea', 'texto', array(
            'label' => 'Texto',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control ckeditor',
            'placeholder' => 'Texto'
        ));

        $this->addElement('submit', 'submit', array(
            'label' => Zend_Registry::get('lblCadastro'),
            'class' => 'btn green',
            'decorators' => $this->buttonDecorators
        ));
    }

}
