import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class Main extends Application {

    private static final String APP_NAME = "CAFI";

    @Override
    public void start(Stage primaryStage) throws Exception {
        String viewName = "Login";
        String fxmlPath = "/app/views/" + viewName + ".fxml";

        FXMLLoader loader = new FXMLLoader(getClass().getResource(fxmlPath));
        Parent root = loader.load();

        Scene scene = new Scene(root, 600, 500);
        scene.getStylesheets().add(getClass().getResource("/app/assets/css/app.css").toExternalForm());

        primaryStage.getIcons().add(
            new javafx.scene.image.Image(getClass().getResourceAsStream("/app/assets/img/CAFI_LOGO.png"))
        );

        primaryStage.setTitle(APP_NAME + " – " + getWindowTitle(viewName));
        primaryStage.setResizable(false);
        primaryStage.setScene(scene);
        primaryStage.show();

        System.out.println("✅ Ventana iniciada: " + primaryStage.getTitle());
    }

    private String getWindowTitle(String viewName) {
        return switch (viewName.toLowerCase()) {
            case "signup" -> "Registro de Usuario";
            case "login" -> "Inicio de Sesión";
            case "test" -> "Prueba de Conexión";
            default -> "Ventana";
        };
    }

    public static void main(String[] args) {
        launch(args);
    }
}
