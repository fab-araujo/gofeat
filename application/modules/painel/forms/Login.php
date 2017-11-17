<?php

class Painel_Form_Login extends Plugin_Form {

    public function __construct() {
        return parent::__construct(NULL, 'login');
    }

    public function init() {

        //dados gerais
        $this->addElement('text', 'email', array(
            'label' => 'Email:',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control form-control-solid placeholder-no-fix',
            'placeholder' => 'Email'
        ));
        $this->addElement('password', 'senha', array(
            'label' => 'Senha:',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control form-control-solid placeholder-no-fix',
            'placeholder' => 'Senha'
        ));


        $this->addElement('submit', 'submit', array(
            'label' => 'LOGIN',
            'class' => 'btn btn-success uppercase',
            'decorators' => $this->buttonDecorators
        ));
    }

}
