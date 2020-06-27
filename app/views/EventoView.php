<?php

class EventoView {
    private $formAlta;
    private $formModif;
    private $eventos;

    public function __construct() {

        // listado
        $this->eventos = 'app/templates/eventos.html';

        // formulario alta
        $this->formAlta = 'app/templates/formAlta.html';
        
        // template modificación
        $this->formModif = 'app/templates/formModif.html';
    }

    public function displayFormAlta() {
        $this->mostrarTemplate($this->formAlta);
    }

    public function displayFormModif() {
        $this->mostrarTemplate($this->formModif);
    }

    public function displayEventos() {
        $this->mostrarTemplate($this->eventos);
    }

    public function mostrarTemplate($template) {
        $file = fopen($template, 'r');
        while(!feof($file)) {
            $linea = fgets($file);
            echo $linea . PHP_EOL;
        }
        fclose($file);
    }
}
