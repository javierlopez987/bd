<?php
require_once ("Router.php");
require_once ("app/controllers/EventoController.php");
require_once 'app/controllers\UserController.php';

define("BASE", 'http://'.$_SERVER["SERVER_NAME"].':'.$_SERVER["SERVER_PORT"].dirname($_SERVER["PHP_SELF"]).'/');
define("BASE_LOGIN", 'http://'.$_SERVER["SERVER_NAME"].':'.$_SERVER["SERVER_PORT"].dirname($_SERVER["PHP_SELF"]).'/user/login');
define("BASE_REGISTRACION", 'http://'.$_SERVER["SERVER_NAME"].':'.$_SERVER["SERVER_PORT"].dirname($_SERVER["PHP_SELF"]).'/user/register');

// recurso solicitado
$action = $_GET["action"];

// método utilizado
$method = $_SERVER["REQUEST_METHOD"];

// instancia el router
$router = new Router();

// ruta evento
$router->addRoute("evento", "POST", "EventoController", "create");
$router->addRoute("evento", "GET", "EventoController", "displayForm");
$router->addRoute("evento/:ID", "GET", "EventoController", "displayEvento");

$router->addRoute("user/login", "GET", "UserController", "login");

//ruta por defecto
$router->addRoute(":", "GET", "EventoController", "displayEventos");


// rutea
$router->route($action, $method);