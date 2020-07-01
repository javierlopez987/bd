<?php 
class Database {
    private $connection;
    private static $instance;
    private $server_addr;
    private $server_port;
    private $db_name;
    private $user;
    private $pass;

    private function __construct() {
        $this->server_addr = $_SERVER["SERVER_ADDR"];
        $this->server_port = '5432';
        $this->db_name = 'cursada';
        $this->user = 'unc_249695';
        $this->pass = '17Urbano';

        try {
        $this->connection = new PDO('pgsql:host=' . $this->server_addr . ';port=' . $this->server_port . ';dbname=' . $this->db_name . ';user=' . $this->user . ';password=' . $this->pass);
        } catch (PDOException $e) {
            echo 'Falló la conexión: ' . $e->getMessage();
            die;
        }
    }

    public static function getInstance() {
        if(!self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->connection;
    }
}

$db = Database::getInstance()->getConnection();
$query = $db->prepare('SELECT * FROM cant_eventos_distrito'); 
$query->execute();
$eventos = $query->fetchAll(PDO::FETCH_OBJ);

$html =
'<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Publicidad</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
</head>
<!-- BODY WEBSITE -->
<body>
    <main class="row">
        <section class="col-md-12">
        <table class="table table-striped">
        <thead>
            <tr>
                <th scope="col">Ciudad</th>
                <th scope="col">Provincia</th>
                <th scope="col">País</th>
                <th scope="col">Cantidad de Eventos</th>
            </tr>
        </thead>
        <tbody>';

        foreach ($eventos as $evento) {
            $html .= '<tr>' . 
                '<td>' . $evento->nombre_distrito . '</td>' . 
                '<td>' . $evento->nombre_pais . '</td>' .
                '<td>' . $evento->nombre_provincia . '</td>' .
                '<td>' . $evento->cant_eventos . '</td>' .
                '</tr>';
        }

        $html .= '
        </tbody>
        </table>
        </section>
        </main>
        <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>
        </body>
        </html>';

        echo $html;
?>

