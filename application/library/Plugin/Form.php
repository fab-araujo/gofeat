<?php

class Plugin_Form extends Zend_Form {

    public $buttonDecorators;
    public $elementDecorators;
    public $fileDecorators;

    public function __construct($options = NULL, $decorator = 'tabela') {
        if ($decorator == 'tabela') {
            $this->buttonDecorators = array(
                'ViewHelper',
                array(array('data' => 'HtmlTag'), array('tag' => 'td', 'class' => 'element')),
                array(array('label' => 'HtmlTag'), array('tag' => 'td', 'placement' => 'prepend')),
                array(array('row' => 'HtmlTag'), array('tag' => 'tr')),
            );
            $this->elementDecorators = array(
                'ViewHelper',
                'Errors',
                array(array('data' => 'HtmlTag'), array('tag' => 'td', 'class' => 'right_columns')),
                array('Label', array('tag' => 'td')),
                array(array('row' => 'HtmlTag'), array('tag' => 'tr')),
            );
            $this->fileDecorators = array(
                'File',
                'Description',
                'Errors',
                array(array('data' => 'HtmlTag'), array('tag' => 'td')),
                array('Label', array('tag' => 'td')),
                array(array('row' => 'HtmlTag'), array('tag' => 'tr'))
            );
            $this->setDecorators(array(
                'FormElements',
                array('HtmlTag', array('tag' => 'table', 'class' => 'tabela_form')),
                'Form'
            ));

            $this->setElementDecorators(
                    array(
                        'Label',
                        array(array('labelTd' => 'HtmlTag'),
                            array('tag' => 'td', 'class' => 'itemForm')),
                        array(array('elemTdOpen' => 'HtmlTag'),
                            array('tag' => 'td', 'openOnly' => true,
                                'class' => '', 'placement' => 'append')),
                        'ViewHelper',
                        'Errors',
                        array('Description', array('tag' => 'div', 'escape' => false)),
                        array(array('elemTdClose' => 'HtmlTag'),
                            array('tag' => 'td', 'closeOnly' => true, 'placement' => 'append')),
                        array(array('row' => 'HtmlTag'), array('tag' => 'tr'))));
        } else if ($decorator == 'login') {
            $this->buttonDecorators = array(
                'ViewHelper'
            );
            /* $this->elementDecorators = array(
              'ViewHelper',
              'Errors',
              array(array('data' => 'HtmlTag'), array('tag' => 'div', 'class' => 'form-fale')),
              array('Label', array('tag' => 'td')),
              array(array('row' => 'HtmlTag'), array('tag' => '', 'placement' => 'append')),
              ); */
            $this->fileDecorators = array(
                'File',
                'Description',
                'Errors',
                array(array('data' => 'HtmlTag'), array('tag' => 'div')),
                array('Label', array('tag' => 'td')),
                array(array('row' => 'HtmlTag'), array('tag' => 'div'))
            );
            $this->setDecorators(array(
                'FormElements',
                array('HtmlTag', array('tag' => 'div', 'class' => 'login_fields')),
                'Form'
            ));

            $this->setElementDecorators(
                    array(
                        'Label',
                        'ViewHelper',
                        'Errors',
                        array('Description', array('tag' => 'div', 'escape' => false)),
                        array(array('row' => 'HtmlTag'), array('tag' => 'div', 'class' => 'field'))));
        } else if ($decorator == 'div') {
            $this->buttonDecorators = array(
                        
                        array(array('elemTdOpen' => 'HtmlTag'),
                            array('tag' => 'div', 'openOnly' => true,
                                'class' => 'col-md-offset-3 col-md-9', 'placement' => 'append')),
                               
                        array('ViewHelper'),
                        array('Errors', array('class'=>'erros')),
                        
                        array(array('elemTdClose' => 'HtmlTag'),
                            array('tag' => 'div', 'closeOnly' => true, 'placement' => 'append')),
                        array(array('row' => 'HtmlTag'), array('tag' => 'div', 'class' => 'form-actions')));
            /* $this->elementDecorators = array(
              'ViewHelper',
              'Errors',
              array(array('data' => 'HtmlTag'), array('tag' => 'div', 'class' => 'form-fale')),
              array('Label', array('tag' => 'td')),
              array(array('row' => 'HtmlTag'), array('tag' => '', 'placement' => 'append')),
              ); */
            $this->fileDecorators = array(
                'File',
                'Description',
                'Errors',
                array(array('data' => 'HtmlTag'), array('tag' => 'div', 'class' => 'col-md-9')),
                array('Label', array('class'=>'control-label col-md-3')),
                
                array(array('row' => 'HtmlTag'), array('tag' => 'div', 'class' => 'form-group'))
            );
            $this->setDecorators(array(
                'FormElements',
                array('HtmlTag', array('tag' => 'div', 'class' => 'form-body')),
                'Form'
            ));

            $this->setElementDecorators(
                    array(
                        array('Label', array('class'=>'control-label col-md-3')),
                        array(array('elemTdOpen' => 'HtmlTag'),
                            array('tag' => 'div', 'openOnly' => true,
                                'class' => 'col-md-9', 'placement' => 'append')),
                        array('ViewHelper'),
                        array('Errors', array('class'=>'erros')),
                        array('Description', array('tag' => 'div', 'escape' => false)),
                        array(array('elemTdClose' => 'HtmlTag'),
                            array('tag' => 'div', 'closeOnly' => true, 'placement' => 'append')),
                        array(array('row' => 'HtmlTag'), array('tag' => 'div', 'class' => 'form-group'))));
        }
        $this->setAttrib('class', 'form-horizontal form-row-seperated');


        parent::__construct($options);
    }

    public function populate(array $vDados) {
        if($vDados['id']){
        $this->getElement('submit')->setLabel(Zend_Registry::get('lblEdicao'));
        }
        parent::populate(($vDados));
    }

}
