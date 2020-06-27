<?php
require_once ("app/models/UserModel.php");
require_once ("app/views/UserView.php");
require_once 'app/core/UserHelper.php';

class UserController {
    private $model;
    private $view;
    private $session;

    public function __construct() {
        $this->model = new UserModel();
        $this->view = new UserView();
        $this->session = new UserHelper();
    }

    public function login() {
        if(isset($_POST['user']) && isset($_POST['opass'])) {
            if($_POST['user'] != null) {
                $user = $this->model->getByUser($_POST['user']);
                if ($user != null && password_verify($_POST['opass'], $user->password)){
                    $this->session->login($user);
                    $this->view->showAdmin();
                }else{
                    $this->view->registerView();
                }
            } else {
                $this->view->loginView();
            }
        } else {
            $this->view->loginView();
        }

    }

    public function logout() {
        $this->session->logout();
        header("Location: " . BASE);
    }
    
    public function registracion() {
        if(isset($_POST['user']) && $_POST['opass'] == $_POST['rpass']) {
            if(($_POST['user'])!= null && $_POST['opass'] != "" && ($_POST['opass'] == $_POST['rpass'])) {
                $user = $this->model->getByUser($_POST['user']);
                if (!$user) {
                    $pass = password_hash($_POST['opass'], PASSWORD_DEFAULT);
                    $this->model->create(array($_POST['user'], $pass));
                    $user = $this->model->getByUser($_POST['user']);
                    $this->session->login($user);
                    $this->view->showAdmin();
                } else {
                    header("Location: " . BASE_LOGIN);
                }
            } else {
                header("Location: " . BASE_REGISTRACION);
            }
        } else {
            $this->view->registerView();
        }
    }

    public function checkLogIn() {
        Session::getInstance();

        if(!isset($_SESSION['userId'])){
            header("Location: " . BASE);
            die();
        } elseif (isset($_SESSION['LAST_ACTIVITY']) && (time() - $_SESSION['LAST_ACTIVITY'] > 20000)) { 
            $this->logout();
            die();
        } 
        
        $_SESSION['LAST_ACTIVITY'] = time();
        $usuario = $_SESSION['user'];
        return $usuario;
    }

    public function checkAdmin() {
        $this->session->checkAdmin();
    }

    public function getUsers() {
        $this->checkAdmin();
        $users = $this->model->getUsers();
        $this->view->displayUsers($users);
    }

    public function setUsers() {
        if(isset($_POST)) {
            $usuarios = $_POST;
            foreach ($usuarios as $key => $value) {
                $this->model->setUsers($key, $value);
            }
        }
        $user = $this->session->getUser();
        $this->session->logout();
        $this->session->login($user);
        $this->getUsers();
    }

    public function deleteUser($id) {
        $this->checkAdmin();
        $this->model->deleteUser($id);
        header("Location: " . BASE_ADMIN);
    }
}