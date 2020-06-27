<?php
require_once 'Controller.php';
require_once 'app\models\EventoModel.php';
require_once 'app\views\EventoView.php';

class EventoController extends Controller{

    public function __construct() {
        parent::__construct();
        $this->model = new EventoModel();
        $this->view = new EventoView();
    }

    public function displayFormAlta() {
        $this->view->displayFormAlta();
    }
    
    public function displayFormModif() {
        $this->view->displayFormModif();
    }

    public function displayEventos() {
        $this->view->displayEventos();
    }

    public function create() {
        if($this->session->checkLogin()) {
            if(
                isset($_POST) && 
                isset($_POST['nombre']) && 
                isset($_POST['fecha_inicio']) && 
                isset($_POST['fecha_fin']) && 
                isset($_POST['destino']) && 
                isset($_POST['descripcion']) &&
                isset($_POST['check_in_horario']) &&
                isset($_POST['check_out_horario']) &&
                isset($_POST['codigo_confirm']) &&
                isset($_POST['cant_noches']) &&
                isset($_POST['cant_habitaciones']) &&
                isset($_POST['cant_personas'])
                ) 
                
                {
                $hotel = $_POST;

                //Verifica si existe un viaje en esa fecha
                if(!$this->existeViaje($hotel)) {
                    $this->model->createViaje($viaje);
                }
                $this->model->createHotel($hotel);
            }
            header("Location: " . BASE_HOTEL);
        }
    }

    private function existeViaje($hotel) {
        $existeViaje = false;

        $viaje = $this->model->getViaje($hotel['fecha_inicio']); // Se espera que el modelo devuelva información del viaje o null si no existe
        if($viaje =! null) {
            $existeViaje = true;
        }
        return $existeViaje;
    }
}