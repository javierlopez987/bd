<?php

class Database {
    private $connection;
    private static $instance;

    private function __construct() {
        try {
        $this->connection = new PDO('mysql:host=localhost;dbname=db_cancionero;charset=utf8', 'root', '');
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