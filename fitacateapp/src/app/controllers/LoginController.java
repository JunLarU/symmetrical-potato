package app.controllers;

import app.models.LoginModel;
import core.security.SessionManager;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.stage.Stage;
import org.json.JSONObject;

public class LoginController {

    @FXML private TextField txtExpediente;
    @FXML private PasswordField txtNip;
    @FXML private Button btnLogin;
    @FXML private Button btnGoSignup;
    @FXML private Label lblStatus;

    private final LoginModel loginModel = new LoginModel();

    @FXML
    private void onLoginClicked() {
        String expediente = txtExpediente.getText().trim();
        String nip = txtNip.getText().trim();

        if (expediente.isEmpty() || nip.isEmpty()) {
            lblStatus.setText("⚠️ Complete ambos campos.");
            return;
        }

        lblStatus.setText("Verificando credenciales...");
        btnLogin.setDisable(true);

        new Thread(() -> {
            try {
                JSONObject response = loginModel.iniciarSesion(expediente, nip);
                System.out.println("📥 Respuesta del servidor:\n" + response.toString(4));

                Platform.runLater(() -> {
                    boolean success = response.optBoolean("success", false);
                    String message = response.optString("message", "Error desconocido");

                    if (success) {
                        lblStatus.setText("✅ " + message);

                        // Obtener el objeto "usuario"
                        JSONObject usuario = response.optJSONObject("usuario");
                        if (usuario != null) {
                            SessionManager.getInstance().startSession(usuario);
                            abrirVentanaPrincipal();
                        } else {
                            lblStatus.setText("⚠️ Respuesta inválida: falta información del usuario.");
                        }

                    } else {
                        lblStatus.setText("⚠️ " + message);
                    }

                    btnLogin.setDisable(false);
                });

            } catch (Exception e) {
                Platform.runLater(() -> {
                    lblStatus.setText("❌ Error de conexión: " + e.getMessage());
                    btnLogin.setDisable(false);
                });
                e.printStackTrace();
            }
        }).start();
    }

    @FXML
    private void onGoSignupClicked() {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/app/views/Signup.fxml"));
            Parent root = loader.load();
            Stage stage = (Stage) btnGoSignup.getScene().getWindow();
            stage.setScene(new Scene(root, 600, 500));
            stage.setTitle("CAFI – Registro de Usuario");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void abrirVentanaPrincipal() {

        if (SessionManager.getInstance().isAdmin()) {
            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/app/views/DashboardAdmin.fxml"));
                Parent root = loader.load();
                Stage stage = (Stage) btnLogin.getScene().getWindow();
                stage.setScene(new Scene(root, 1000, 650));
                stage.setTitle("CAFI – Panel Administrador");
                stage.show();
            } catch (Exception e) {
                e.printStackTrace();
            }
            
        }
    }
}
