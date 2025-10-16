package app.controllers.admin;

import app.models.IngredientesModel;
import core.security.SessionManager;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import org.json.JSONObject;

/**
 * Controlador del formulario de registro de ingredientes.
 * Envía los datos al endpoint /ingredients/add
 */
public class RegistroIngredienteController {

    @FXML private TextField txtNombre;
    @FXML private TextField txtDescripcion;
    @FXML private ComboBox<String> cbCategoria;
    @FXML private TextField txtCalorias;
    @FXML private CheckBox chkAlergeno;
    @FXML private Button btnRegistrar;
    @FXML private Label lblStatus;

    private final IngredientesModel model = new IngredientesModel();
    private final SessionManager session = SessionManager.getInstance();

    @FXML
    public void initialize() {
        // 🔹 Cargar categorías reales de la BD
        cbCategoria.getItems().addAll(
                "Lácteos",
                "Proteínas",
                "Vegetales",
                "Panes",
                "Aderezos",
                "Endulzantes",
                "Lácteos Vegetales"
        );
        lblStatus.setText("🧾 Completa los campos para registrar un ingrediente.");
    }

    @FXML
    private void onRegistrarClicked() {
        if (txtNombre.getText().isBlank() || cbCategoria.getValue() == null ||
            txtCalorias.getText().isBlank()) {
            lblStatus.setText("⚠️ Completa los campos requeridos (Nombre, Categoría, Calorías).");
            return;
        }

        btnRegistrar.setDisable(true);
        lblStatus.setText("⏳ Enviando solicitud...");

        new Thread(() -> {
            try {
                JSONObject response = model.agregarIngrediente(
                        session.get("Expediente"),
                        txtNombre.getText().trim(),
                        txtDescripcion.getText().trim(),
                        cbCategoria.getValue(),
                        txtCalorias.getText().trim(),
                        chkAlergeno.isSelected()
                );

                System.out.println("📥 Respuesta del servidor:");
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
                e.printStackTrace();
                Platform.runLater(() -> {
                    lblStatus.setText("❌ Error de conexión con el servidor.");
                    btnRegistrar.setDisable(false);
                });
            }
        }).start();
    }

    private void limpiarCampos() {
        txtNombre.clear();
        txtDescripcion.clear();
        cbCategoria.setValue(null);
        txtCalorias.clear();
        chkAlergeno.setSelected(false);
    }
}
