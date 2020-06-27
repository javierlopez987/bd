<?php
require_once ("app/db/Database.php");

class UserModel {
    private $db;

    function __construct() {
        $this->db = Database::getInstance()->getConnection();
        $this->query = new QuerySQL();
        $this->tabla = "usuario";
    }

    public function getPassword($user){
        $query = $this->db->prepare($this->query->selectByColumn($this->tabla,"user"));
        $query->execute(array($user));
        $password = $sentencia->fetch(PDO::FETCH_OBJ);
        return $password;
    }

    public function getByUser($value) {
        $query = $this->db->prepare('SELECT * FROM usuarios WHERE user = ?'); 
        $query->execute(array($value));
        $result = $query->fetch(PDO::FETCH_OBJ);
        return $result;
    }

    public function create($values) {
        $query = $this->db->prepare("INSERT INTO usuarios (user, password) VALUES (?, ?)");
        $query->execute($values);
    }

    public function getUsers() {
        $query = $this->db->prepare('SELECT id, user, administrador FROM usuarios');
        $query->execute();
        $result = $query->fetchAll(PDO::FETCH_OBJ);
        return $result;
    }

    public function setUsers($userId, $admin) {
        $query = $this->db->prepare("UPDATE usuarios SET administrador = ? WHERE id = ?");
        $query->execute(array($admin, $userId));
    }

    public function deleteUser($id) {
        $query = $this->db->prepare("DELETE FROM usuarios WHERE id=?");
        $query->execute(array($id));
    }
}