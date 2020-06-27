<?php
require_once 'Session.php';

class UserHelper {

    public function __construct() {

    }

    public function login($user) {
        Session::getInstance();
        $_SESSION['userId'] = $user->id;
        $_SESSION['user'] = $user->user;
        $_SESSION['admin'] = $user->administrador;
    }

    public function logout() {
        Session::getInstance();
        session_destroy();
    }

    public function checkLogin() {
        Session::getInstance();
        if (!isset($_SESSION['userId'])) {
            header('Location: ' . BASE_LOGIN);
            die();
        }       
    }

    public function getLoggedUserName() {
        if (session_status() != PHP_SESSION_ACTIVE) {
            Session::getInstance();
        }
        return $_SESSION['user'];
    }

    public function getUserType() {
        if (session_status() != PHP_SESSION_ACTIVE) {
            Session::getInstance();
        }
        return $_SESSION['admin'];
    }

    public function getUser() {
        if (session_status() != PHP_SESSION_ACTIVE) {
            Session::getInstance();
        }
        return $_SESSION;
    }

    public function checkAdmin() {
        Session::getInstance();

        if(!isset($_SESSION['userId'])){
            header("Location: " . BASE);
            die();
        } elseif ($this->getUserType() != 1) { 
            $this->logout();
            header("Location: " . BASE);
            die();
        } 
    }
}