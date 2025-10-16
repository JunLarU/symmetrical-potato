package app.controllers;

import app.models.SignupModel;
import core.security.SessionManager;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;

public class SignupController {

    @FXML private TextField txtExpediente;
    @FXML private TextField txtNombre;
    @FXML private TextField txtApellidoPaterno;
    @FXML private TextField txtApellidoMaterno;
    @FXML private TextField txtCorreo;
    @FXML private TextField txtTelefono;
    @FXML private PasswordField txtNip;
    @FXML private Label lblStatus;
    @FXML private Button btnRegistrar;
    @FXML private Button btnGoLogin;

    // 🔘 RadioButtons (solo visibles para administradores)
    @FXML private RadioButton rbUsuario;
    @FXML private RadioButton rbAdministrador;
    @FXML private HBox roleBox;
    private ToggleGroup roleGroup;

    private final SignupModel signupModel = new SignupModel();

    @FXML
    public void initialize() {
        // Configurar grupo de botones de rol
        roleGroup = new ToggleGroup();
        rbUsuario.setToggleGroup(roleGroup);
        rbAdministrador.setToggleGroup(roleGroup);
        rbUsuario.setSelected(true);

        // Obtener sesión actual
        SessionManager session = SessionManager.getInstance();

        boolean isAuthenticated = session.isAuthenticated();
        boolean isAdmin = isAuthenticated && session.isAdmin();

        // Si hay sesión iniciada, ocultar el botón "Iniciar Sesión"
        btnGoLogin.setVisible(!isAuthenticated);
        btnGoLogin.setManaged(!isAuthenticated);

        // Mostrar u ocultar los radio buttons según sea admin o no
        roleBox.setVisible(isAdmin);
        roleBox.setManaged(isAdmin);
    }

    @FXML
    private void onRegistrarClicked() {
        // Validaciones básicas
        if (txtExpediente.getText().isBlank() ||
            txtNombre.getText().isBlank() ||
            txtApellidoPaterno.getText().isBlank() ||
            txtApellidoMaterno.getText().isBlank() ||
            txtCorreo.getText().isBlank() ||
            txtTelefono.getText().isBlank() ||
            txtNip.getText().isBlank()) {

            lblStatus.setText("⚠️ Todos los campos son obligatorios.");
            return;
        }

        SessionManager session = SessionManager.getInstance();
        String tipoUsuario = "Usuario";
        String expedienteAdmin = null;

        // Si el usuario autenticado es administrador
        if (session.isAuthenticated() && session.isAdmin()) {
            tipoUsuario = rbAdministrador.isSelected() ? "Administrador" : "Usuario";
            expedienteAdmin = session.get("Expediente"); // expediente del admin activo
        }

        lblStatus.setText("Enviando solicitud...");
        btnRegistrar.setDisable(true);

        final String tipoFinal = tipoUsuario;
        final String expedienteAdminFinal = expedienteAdmin;

        new Thread(() -> {
            try {
                var response = signupModel.registrarUsuario(
                        txtExpediente.getText().trim(),
                        txtNombre.getText().trim(),
                        txtApellidoPaterno.getText().trim(),
                        txtApellidoMaterno.getText().trim(),
                        txtCorreo.getText().trim(),
                        txtTelefono.getText().trim(),
                        txtNip.getText().trim(),
                        tipoFinal,
                        expedienteAdminFinal // se envía solo si no es null
                );

                System.out.println("📥 Respuesta cruda del servidor:");
                System.out.println(response.toString(4));

                Platform.runLater(() -> {
                    boolean success = response.optBoolean("success", false);
                    String message = response.optString("message", "Error desconocido");

                    if (success) {
                        lblStatus.setText("✅ " + message);
                        limpiarCampos();
                    } else {
                        lblStatus.setText("⚠️ " + message);
                    }

                    btnRegistrar.setDisable(false);
                });

            } catch (Exception e) {
                Platform.runLater(() -> {
                    lblStatus.setText("❌ Error de conexión o servidor no disponible.");
                    btnRegistrar.setDisable(false);
                });
                e.printStackTrace();
            }
        }).start();
    }

    private void limpiarCampos() {
        txtExpediente.clear();
        txtNombre.clear();
        txtApellidoPaterno.clear();
        txtApellidoMaterno.clear();
        txtCorreo.clear();
        txtTelefono.clear();
        txtNip.clear();
        rbUsuario.setSelected(true);
    }

    @FXML
    private void onGoLoginClicked() {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/app/views/Login.fxml"));
            Parent root = loader.load();
            Stage stage = (Stage) btnGoLogin.getScene().getWindow();
            stage.setScene(new Scene(root, 600, 500));
            stage.setTitle("CAFI – Inicio de Sesión");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
