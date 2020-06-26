<?php
require_once 'Controller.php';
//require_once 'app\models\Model.php';
require_once 'app\views\VueloView.php';

class VueloController extends Controller{

    public function __construct() {
        parent::__construct();
        $this->view = new VueloView();
    }

    public function displayForm() {
        $this->view->displayForm();
    }

}