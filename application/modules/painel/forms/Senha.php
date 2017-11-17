<?php

class Painel_Form_Senha extends Plugin_Form {

    public function __construct() {
        return parent::__construct(NULL, 'div');
    }

    public function init() {
        $this->setAttrib('name', 'Alterar senha');
        $this->setAttrib('id', 'formGeral');

//        $this->addElement('password', 'senha', array(
//            'label' => 'Senha:',
//            'required' => true,
//            'filters' => array('StringTrim'),
//            'class' => 'required form-control'
//        ));
        $this->addElement('password', 'nova_senha', array(
            'label' => 'Nova senha:',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control'
        ));
        $this->addElement('password', 'repete_senha', array(
            'label' => 'Repita a nova senha:',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control'
        ));
        $this->getElement('repete_senha')->addValidator('Identical', false, array('token' => 'nova_senha'));


        $this->addElement('submit', 'submit', array(
            'label' => Zend_Registry::get('lblCadastro'),
            'class' => 'btn green',
            'decorators' => $this->buttonDecorators
        ));
    }

}
