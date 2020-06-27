<?php 
require_once ("app/db/Database.php");

class EventoModel {
    private $db;

    public function __construct () {
        // $this->db = Database::getInstance()->getConnection();
        $this->tabla = "evento";
    }

    public function get(){
        $query = $this->db->prepare('SELECT * FROM' . $this->tabla); 
        $query->execute();
        $result = $query->fetchAll(PDO::FETCH_OBJ);
        var_dump($result);die();
        return $result;
    }

    public function create($values) {
        $sentencia = $this->db->prepare('INSERT INTO ' . $this->tabla . '(nombre, duracion, genero, album, id_artista, ranking) VALUES (?, ?, ?, ?, ?, ?)');
        $sentencia->execute($values);
    }

    public function update($values) {
        $sentencia = $this->db->prepare('UPDATE ' . $this->tabla . ' SET nombre = ?, duracion = ?, genero = ?, album = ?, id_artista = ?, ranking = ? WHERE id = ?');
        $sentencia->execute($values);
    }

    public function delete($id) {
        $sentencia = $this->db->prepare('DELETE FROM ' . $this->tabla . ' WHERE id=?');
        $sentencia->execute(array($id));
    }

    public function getCanciones($artista) {
        $sentencia = $this->db->prepare('SELECT *, ' . $this->tabla .'.nombre AS cancion, artistas.nombre AS artista FROM canciones JOIN artistas ON canciones.id_artista = artistas.id WHERE artistas.id = ?');
        $sentencia->execute(array($artista));
        $result = $sentencia->fetchAll(PDO::FETCH_OBJ);
        return $result;
    }

    public function getAllCancionesConArtistas() {
        $sentencia = $this->db->prepare('SELECT *, canciones.nombre AS cancion, artistas.nombre AS artista, canciones.id AS cancion_id, canciones.ranking AS ranking_cancion FROM canciones JOIN artistas ON canciones.id_artista = artistas.id');
        $sentencia->execute();
        $result = $sentencia->fetchAll(PDO::FETCH_OBJ);
        return $result;
    }

    public function getCancionPorId($id) {
        $sentencia = $this->db->prepare('SELECT *, canciones.nombre AS cancion, artistas.nombre AS artista, canciones.id AS cancion_id, canciones.ranking AS ranking_cancion FROM canciones JOIN artistas ON canciones.id_artista = artistas.id WHERE canciones.id = ?');
        $sentencia->execute(array($id));
        $result = $sentencia->fetch(PDO::FETCH_OBJ);
        //var_dump($result);die();
        return $result;
    }
}