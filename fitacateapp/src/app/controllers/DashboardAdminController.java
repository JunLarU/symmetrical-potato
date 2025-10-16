package app.controllers;

import core.security.SessionManager;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

public class DashboardAdminController {

    @FXML private Label lblWelcome;
    @FXML private AnchorPane contentArea;
    @FXML private Button btnProductos;
    @FXML private Button btnMenus;
    @FXML private Button btnBebidas;
    @FXML private Button btnIngredientes;
    @FXML private Button btnAvisos;
    @FXML private Button btnAdministradores;
    @FXML private Button btnCerrarSesion;

    private final SessionManager session = SessionManager.getInstance();

    @FXML
    public void initialize() {
        // Mostrar nombre del admin
        String nombre = session.get("Nombre");
        String apellido = session.get("ApellidoPaterno");
        lblWelcome.setText("👋 Bienvenido, " + nombre + " " + apellido);

        // Cargar vista inicial
        cargarVista("Productos");
    }

    // --- Navegación entre secciones ---
    @FXML private void onProductosClicked() { cargarVista("Productos"); }
    @FXML private void onMenusClicked() { cargarVista("Menus"); }
    @FXML private void onBebidasClicked() { cargarVista("Bebidas"); }
    @FXML private void onIngredientesClicked() { cargarVista("Ingredientes"); }
    @FXML private void onAvisosClicked() { cargarVista("Avisos"); }

    // 🔹 Nueva vista para administradores
    @FXML private void onAdministradoresClicked() { cargarVista("Administradores"); }

    @FXML
    private void onCerrarSesionClicked() {
        session.closeSession();
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/app/views/Login.fxml"));
            Parent root = loader.load();
            Stage stage = (Stage) btnCerrarSesion.getScene().getWindow();
            stage.setScene(new Scene(root, 600, 500));
            stage.setTitle("CAFI – Inicio de Sesión");
            stage.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // --- Método central de carga dinámica ---
    private void cargarVista(String nombreVista) {
    try {
        var loader = new FXMLLoader(getClass().getResource("/app/views/admin/" + nombreVista + ".fxml"));
        var vista = loader.load();

        // Borra contenido anterior y ajusta tamaños
        contentArea.getChildren().clear();
        contentArea.getChildren().add((javafx.scene.Node) vista);
        AnchorPane.setTopAnchor((javafx.scene.Node) vista, 0.0);
        AnchorPane.setBottomAnchor((javafx.scene.Node) vista, 0.0);
        AnchorPane.setLeftAnchor((javafx.scene.Node) vista, 0.0);
        AnchorPane.setRightAnchor((javafx.scene.Node) vista, 0.0);

    } catch (Exception e) {
        e.printStackTrace();
        Label error = new Label("❌ Error cargando vista: " + nombreVista);
        contentArea.getChildren().setAll(error);
    }
}

}
