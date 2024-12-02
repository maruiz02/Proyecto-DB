package consultas;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class PruebaInsert {
    public static void main(String[] args) {
    	String url = "jdbc:mysql://localhost:3304/mesaregalos"; 
        String user = "root"; 
        String pass = "pass"; 
        
        String clientes = "clientes";
        String nomCli = "nomCli"; 
        String dirCli = "dirCli"; 
        
        String nom = "Nombre"; 
        String dir = "Direccion"; 
        try (Connection conexion = DriverManager.getConnection(url, user, pass)) {
            System.out.println("La conexión fue exitosa");
            String sql = "insert into " + clientes + " (" + nomCli + ", " + dirCli + ") values (?, ?)";
            try (PreparedStatement statement = conexion.prepareStatement(sql)) {
                statement.setString(1, nom);
                statement.setString(2, dir);
                System.out.println("Se insertaron los datos");
            }
        } catch (SQLException e) {
            System.out.println("Error al insertar");
            e.printStackTrace();
        }
    }
}

