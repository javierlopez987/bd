<?php
require_once("Router.php");
require_once("app/controllers/EventoController.php");
require_once("app/controllers/PatrocinanteController.php");

define("BASE", 'http://'.$_SERVER["SERVER_NAME"].':'.$_SERVER["SERVER_PORT"].dirname($_SERVER["PHP_SELF"]).'/');
define("BASE_EVENTO", 'http://'.$_SERVER["SERVER_NAME"].':'.$_SERVER["SERVER_PORT"].dirname($_SERVER["PHP_SELF"]).'/evento');

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
// ruta patrocinante
$router->addRoute("patrocinante", "GET", "PatrocinanteController", "displayForm");

//ruta por defecto
$router->addRoute(":", "GET", "EventoController", "displayEventos");


// rutea
$router->route($action, $method);