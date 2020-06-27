<?php
require_once 'app\core\UserHelper.php';

abstract class Controller {
    protected $model;
    protected $view;
    protected $session;

    public function __construct() {
        $this->session = new UserHelper();
    }
}