package app.controllers.admin;

import app.models.IngredientesModel;
import core.security.SessionManager;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.stage.Modality;
import javafx.stage.Stage;
import javafx.beans.property.SimpleStringProperty;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Controlador de la vista de Ingredientes.
 * - Envía solicitudes a /api/ingredients/all y /api/ingredients/search
 * - Muestra los resultados en una tabla dinámica
 */
public class IngredientesController {

    @FXML private TextField txtBuscar;
    @FXML private Button btnRecargar;
    @FXML private TableView<JSONObject> tablaIngredientes;
    @FXML private TableColumn<JSONObject, String> colId;
    @FXML private TableColumn<JSONObject, String> colNombre;
    @FXML private TableColumn<JSONObject, String> colCategoria;
    @FXML private TableColumn<JSONObject, String> colDescripcion;
    @FXML private TableColumn<JSONObject, String> colCalorias;
    @FXML private TableColumn<JSONObject, String> colAlergeno;
    @FXML private Label lblEstado;

    private final IngredientesModel model = new IngredientesModel();
    private final SessionManager session = SessionManager.getInstance();

    @FXML
    public void initialize() {
        configurarTabla();
        cargarIngredientes();

        // Evento al escribir en el campo de búsqueda
        txtBuscar.textProperty().addListener((obs, oldVal, newVal) -> {
            if (newVal.isBlank()) {
                cargarIngredientes();
            } else {
                buscarIngredientes(newVal);
            }
        });
    }

    private void configurarTabla() {
        colId.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().optString("ID")));
        colNombre.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().optString("Nombre")));
        colCategoria.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().optString("Categoria")));
        colDescripcion.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().optString("Descripcion")));
        colCalorias.setCellValueFactory(data -> new SimpleStringProperty(data.getValue().optString("Calorias")));
        colAlergeno.setCellValueFactory(data -> {
            int val = data.getValue().optInt("Alergeno", 0);
            return new SimpleStringProperty(val == 1 ? "Sí" : "No");
        });
    }

    // ============================
    // 🟢 Cargar todos los ingredientes
    // ============================
    @FXML
    private void cargarIngredientes() {
        lblEstado.setText("Cargando ingredientes...");
        tablaIngredientes.getItems().clear();

        new Thread(() -> {
            try {
                JSONObject response = model.obtenerTodos(session.get("Expediente"));

                if (response.optBoolean("success", false)) {
                    JSONArray arr = response.optJSONArray("ingredientes");
                    Platform.runLater(() -> {
                        if (arr != null) {
                            for (int i = 0; i < arr.length(); i++) {
                                tablaIngredientes.getItems().add(arr.getJSONObject(i));
                            }
                            lblEstado.setText("✅ Se cargaron " + arr.length() + " ingredientes.");
                        }
                    });
                } else {
                    String msg = response.optString("message", "Error desconocido");
                    Platform.runLater(() -> lblEstado.setText("⚠️ " + msg));
                }
            } catch (Exception e) {
                e.printStackTrace();
                Platform.runLater(() -> lblEstado.setText("❌ Error al conectar con el servidor."));
            }
        }).start();
    }

    // ============================
    // 🔍 Buscar ingrediente
    // ============================
    private void buscarIngredientes(String query) {
        lblEstado.setText("Buscando \"" + query + "\"...");
        tablaIngredientes.getItems().clear();

        new Thread(() -> {
            try {
                JSONObject response = model.buscar(session.get("Expediente"), query);

                if (response.optBoolean("success", false)) {
                    JSONArray arr = response.optJSONArray("ingredientes");
                    Platform.runLater(() -> {
                        if (arr != null) {
                            for (int i = 0; i < arr.length(); i++) {
                                tablaIngredientes.getItems().add(arr.getJSONObject(i));
                            }
                            lblEstado.setText("🔍 " + arr.length() + " resultado(s) para \"" + query + "\"");
                        }
                    });
                } else {
                    String msg = response.optString("message", "Error en búsqueda");
                    Platform.runLater(() -> lblEstado.setText("⚠️ " + msg));
                }
            } catch (Exception e) {
                e.printStackTrace();
                Platform.runLater(() -> lblEstado.setText("❌ Error al realizar búsqueda."));
            }
        }).start();
    }

    @FXML
    private void onRecargarClicked() {
        txtBuscar.clear();
        cargarIngredientes();
    }

    @FXML
    private void onNuevoIngredienteClicked() {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/app/views/admin/RegistroIngrediente.fxml"));
            Parent root = loader.load();

            Stage stage = new Stage();
            stage.setTitle("Registrar nuevo ingrediente");
            stage.setScene(new Scene(root));
            stage.initModality(Modality.APPLICATION_MODAL);
            stage.setResizable(false);
            stage.showAndWait();

            // ✅ Al cerrar el formulario, recargar lista
            cargarIngredientes();

        } catch (Exception e) {
            e.printStackTrace();
            lblEstado.setText("❌ No se pudo abrir el formulario de registro.");
        }
    }


}
