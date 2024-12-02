package connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.swing.JOptionPane;

public class ConnectionDB {
	//private static final String DRIVER= "com.mysql.jdbc.Driver"; era el driver pero no hizo falta
	private static final String DB_URL=
			"jdbc:mysql://localhost:3304/mesaregalos";
	private static final String DB_USER = "root";
	private static final String DB_PASSWORD = "";
	private Connection CN;
	
	public ConnectionDB() {
		CN = null;
	}
	public Connection getConnection() {
		try {
			CN = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
		} catch (SQLException ex) {
			JOptionPane.showMessageDialog(null, ex.getMessage(), "Error al conectar con la Base de Datos", JOptionPane.ERROR_MESSAGE);
			System.exit(0);
		}
		return CN;
	}
	public void close () {
		try {
			CN.close();
		} catch (SQLException ex) {
			JOptionPane.showMessageDialog(null, ex.getMessage(), "Error al desconectar la Base de Datos", JOptionPane.ERROR_MESSAGE);
		}
	}
}