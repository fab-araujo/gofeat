<?php

class Painel_Form_Seo extends Plugin_Form  {

    public function __construct() {
        return parent::__construct(NULL, 'div');
    }

    public function init() {
        $this->setAttrib('name', 'Configuração SEO do site');
        $this->setAttrib('id', 'formGeral');

        $this->addElement('hidden', 'id');

        $this->addElement('text', 'url', array(
            'label' => 'URL completa',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control',
            'placeholder' => 'URL completa'
        ));

        $this->addElement('text', 'titulo', array(
            'label' => 'Título',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control',
            'placeholder' => 'Título'
        ));

        $this->addElement('textarea', 'meta', array(
            'label' => 'Meta tags',
            'required' => true,
            'filters' => array('StringTrim'),
            'class' => 'required form-control'
        ));

        $this->addElement('textarea', 'descricao', array(
            'label' => 'Descrição',
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
