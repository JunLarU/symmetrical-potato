package app.controllers;

import app.models.TestModel;
import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;

public class TestController {

    @FXML private Label lblResultado;
    @FXML private Button btnEnviar;

    private final TestModel testModel = new TestModel();

    @FXML
    private void onEnviarClicked() {
        lblResultado.setText("Enviando solicitud...");
        System.out.println("📡 Enviando solicitud a servidor...");

        // Ejecutar en un hilo separado para no congelar la UI
        new Thread(() -> {
            try {
                // Envía la solicitud y recibe respuesta JSON
                var response = testModel.sendIncrementRequest(7);

                // Mostrar en consola el objeto JSON recibido
                System.out.println("✅ Respuesta recibida del servidor:");
                System.out.println(response.toString(4)); // con indentación bonita

                // Procesar en el hilo de la interfaz
                Platform.runLater(() -> {
                    if (response.getBoolean("success")) {
                        int result = response.getInt("resultado");
                        lblResultado.setText("Resultado: " + result);
                        System.out.println("🎯 Resultado mostrado en UI: " + result);
                    } else {
                        lblResultado.setText("Error en respuesta del servidor.");
                        System.err.println("⚠️ Servidor devolvió success=false.");
                    }
                });

            } catch (Exception e) {
                // Mostrar errores en consola y en la etiqueta
                System.err.println("❌ Error durante la solicitud: " + e.getMessage());
                e.printStackTrace();
                Platform.runLater(() ->
                        lblResultado.setText("Error: " + e.getMessage()));
            }
        }).start();
    }
}
