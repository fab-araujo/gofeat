<?php

class Painel_Form_Banner extends Plugin_Form  {

    public function __construct() {
        return parent::__construct(NULL, 'div');
    }

    public function init() {
        $this->setAttrib('name', 'Cadastro de banner da home');
        $this->setAttrib('id', 'formGeral');

        $this->addElement('hidden', 'id');

        $this->addElement('text', 'titulo', array(
            'label' => 'Título',
            'filters' => array('StringTrim'),
            'class' => 'form-control',
            'placeholder' => 'Título'
        ));

        $this->addElement('text', 'subtitulo', array(
            'label' => 'Subtítulo',
            'filters' => array('StringTrim'),
            'class' => ' form-control',
            'placeholder' => 'Título'
        ));

        $this->addElement('file', 'arquivo', array(
            'label' => 'Foto:',
            'decorators' => $this->fileDecorators,
            'class' => 'form-control',
            'description' => '1170 x 555'
        ));
        $this->getElement('arquivo')->getDecorator('Description')->setEscape(false);
        $this->getElement('arquivo')->addValidator('Extension', false, 'jpg,jpeg,png,gif');

        $this->addElement('file', 'arquivo_m', array(
            'label' => 'Foto Mobile:',
            'decorators' => $this->fileDecorators,
            'class' => 'form-control',
            'description' => '768 x 768'
        ));
        $this->getElement('arquivo_m')->getDecorator('Description')->setEscape(false);
        $this->getElement('arquivo_m')->addValidator('Extension', false, 'jpg,jpeg,png,gif');

        $this->addElement('submit', 'submit', array(
            'label' => Zend_Registry::get('lblCadastro'),
            'class' => 'btn green',
            'decorators' => $this->buttonDecorators
        ));
    }

}
